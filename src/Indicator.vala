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

public class XRDesktopIndicator.Indicator : Wingpanel.Indicator {
    public bool is_in_session { get; construct; default = false; }

    private Widgets.PopoverWidget popover_widget;
    private Widgets.DisplayWidget dynamic_icon;

    private Services.DBusService dbus_service;
    private uint dbus_service_registration_id = 0;

    public Indicator (bool is_in_session) {
        Object (
            code_name: "xrdesktop",
            is_in_session: is_in_session
        );
    }

    construct {
        this.dbus_service = new Services.DBusService ();

        Bus.own_name (
            BusType.SESSION,
            "io.elementary.pantheon.XRDesktop",
            BusNameOwnerFlags.NONE,
            (connection, name) => {
                debug ("Aquired DBus connection named '%s'", name);
                try {
                    this.dbus_service_registration_id = connection.register_object ("/io/elementary/pantheon/xrdesktop", this.dbus_service);
                } catch (GLib.IOError e) {
                    critical ("IOError while aquiring DBus connection named '%s': %s", name, e.message);
                }
            },
            () => {},
            (connection, name) => {
                if (this.dbus_service_registration_id != 0) {
                    connection.unregister_object (this.dbus_service_registration_id);
                    this.dbus_service_registration_id = 0;

                }
                warning ("Could not aquire DBus connection named '%s', or the connection was closed.", name);
            }
        );

        weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
        default_theme.add_resource_path ("/io/elementary/wingpanel/xrdesktop");
    }

    public override Gtk.Widget get_display_widget () {
        if (dynamic_icon == null) {
            dynamic_icon = new Widgets.DisplayWidget (dbus_service);
        }
        this.visible = true;
        return dynamic_icon;
    }

    public override Gtk.Widget? get_widget () {
        if (popover_widget == null) {
            popover_widget = new Widgets.PopoverWidget (dbus_service, is_in_session);
        }

        return popover_widget;
    }


    public override void opened () {
    }

    public override void closed () {
    }
}

public Wingpanel.Indicator get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating XR Desktop Indicator");
    var indicator = new XRDesktopIndicator.Indicator (server_type == Wingpanel.IndicatorManager.ServerType.SESSION);

    return indicator;
}
