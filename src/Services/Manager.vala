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

    public bool retrieve_finished { get; private set; default = false; }
    private GLib.DBusObjectManagerClient object_manager;

    public bool is_enabled { get; private set; default = false; }

    construct {
        create_manager.begin ();
    }

    private async void create_manager () {
        try {
            object_manager = yield new GLib.DBusObjectManagerClient.for_bus.begin (
                BusType.SYSTEM,
                GLib.DBusObjectManagerClientFlags.NONE,
                "io.elementary.pantheon.XRDesktopService",
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

    //TODO: Do not rely on this when it is possible to do it natively in Vala
    [CCode (cname="xr_indicator_services_xrdesktopservice_proxy_get_type")]
    extern static GLib.Type get_xrdesktopservice_proxy_type ();

    private GLib.Type object_manager_proxy_get_type (DBusObjectManagerClient manager, string object_path, string? interface_name) {
        if (interface_name == null)
            return typeof (GLib.DBusObjectProxy);

        switch (interface_name) {
            case "io.elementary.pantheon.XRDesktopService":
                return get_xrdesktopservice_proxy_type ();
            default:
                return typeof (GLib.DBusProxy);
        }
    }

    private void on_interface_added (GLib.DBusObject object, GLib.DBusInterface iface) {
        if (iface is XRIndicator.Services.XRDesktopService) {
            unowned XRIndicator.Services.XRDesktopService xr = (XRIndicator.Services.XRDesktopService) iface;

            ((DBusProxy) xr).g_properties_changed.connect ((changed, invalid) => {
                var enabled = changed.lookup_value ("enabled", new VariantType ("b"));
                if (enabled != null && enabled != is_enabled) {
                    is_enabled = enabled.get_boolean ();

                    global_state_changed (is_enabled);
                }
            });
        }
    }

    private void on_interface_removed (GLib.DBusObject object, GLib.DBusInterface iface) {
        if (iface is XRIndicator.Services.XRDesktopService) {
            if (is_enabled) {
                is_enabled = false;
                global_state_changed (is_enabled);
            }
        }
    }

    public bool get_global_state () {
        return is_enabled;
    }

    public async void set_global_state (bool state) {
        if (state != is_enabled) {
            is_enabled = state;
            global_state_changed (is_enabled);
        }
    }
}
