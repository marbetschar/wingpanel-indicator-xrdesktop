/*-
 * Copyright (c) 2021 elementary LLC. (https://elementary.io)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public class XRIndicator.Services.ObjectManager : Object {
    public signal void global_state_changed (bool enabled);

    public bool has_object { get; private set; default = false; }
    public bool retrieve_finished { get; private set; default = false; }
    private Settings settings;
    private GLib.DBusObjectManagerClient object_manager;

    public bool is_enabled {get; private set; default = false; }

    construct {
        settings = new Settings ("io.elementary.desktop.wingpanel.xr");
        create_manager.begin ();
    }

    private async void create_manager () {
        try {
            object_manager = yield new GLib.DBusObjectManagerClient.for_bus.begin (
                BusType.SYSTEM,
                GLib.DBusObjectManagerClientFlags.NONE,
                "org.bluez",
                "/",
                object_manager_proxy_get_type,
                null
            );
            object_manager.get_objects ().foreach ((object) => {
                object.get_interfaces ().foreach ((iface) => on_interface_added (object, iface));
            });
            object_manager.interface_added.connect (on_interface_added);
            object_manager.interface_removed.connect (on_interface_removed);
            object_manager.object_added.connect ((object) => {
                object.get_interfaces ().foreach ((iface) => on_interface_added (object, iface));
            });
            object_manager.object_removed.connect ((object) => {
                object.get_interfaces ().foreach ((iface) => on_interface_removed (object, iface));
            });
        } catch (Error e) {
            critical (e.message);
        }

        retrieve_finished = true;
    }

    private void on_interface_added (GLib.DBusObject object, GLib.DBusInterface iface) {
        if (iface is XRIndicator.Services.Device) {
            unowned XRIndicator.Services.Device device = (XRIndicator.Services.Device) iface;

            if (device.paired) {
                device_added (device);
            }

            ((DBusProxy) device).g_properties_changed.connect ((changed, invalid) => {
                var connected = changed.lookup_value ("Connected", new VariantType ("b"));
                if (connected != null) {
                    check_global_state ();
                }

                var paired = changed.lookup_value ("Paired", new VariantType ("b"));
                if (paired != null) {
                    if (device.paired) {
                        device_added (device);
                    } else {
                        device_removed (device);
                    }

                    check_global_state ();
                }
            });

            check_global_state ();
        } else if (iface is XRIndicator.Services.Adapter) {
            unowned XRIndicator.Services.Adapter adapter = (XRIndicator.Services.Adapter) iface;
            has_object = true;

            ((DBusProxy) adapter).g_properties_changed.connect ((changed, invalid) => {
                var enabled = changed.lookup_value ("enabled", new VariantType ("b"));
                if (enabled != null) {
                    check_global_state ();
                }
            });
        }
    }

    public void check_global_state () {
        /* As this is called within a signal handler, it should be in a Idle loop  else
         * races occur */
        Idle.add (() => {
            var enabled = get_global_state ();

            /* Only signal if actually changed */
            if (enabled != is_enabled) {
                is_enabled = enabled;
                global_state_changed (is_enabled);
            }
            return false;
        });
    }

    public bool get_global_state () {
        return false;
    }

    public async void set_global_state (bool state) {
        /* `is_enabled` property will be set by the check_global state () callback.
        Do not set now so that global_state_changed signal will be emitted. */

        settings.set_boolean ("xr-enabled", state);
    }

    public async void set_last_state () {
        bool last_state = settings.get_boolean ("xr-enabled");

        if (get_global_state () != last_state) {
            yield set_global_state (last_state);
        }

        check_global_state ();
    }
}
