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

public class XRDesktopIndicator.Widgets.PopoverWidget : Gtk.Box {
    public XRDesktopIndicator.Services.DBusService dbus_service { get; construct; }
    public bool is_in_session { get; construct; }

    private Granite.SwitchModelButton main_switch;

    public PopoverWidget (XRDesktopIndicator.Services.DBusService dbus_service, bool is_in_session) {
        Object (
            dbus_service: dbus_service,
            is_in_session: is_in_session
        );
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;

        main_switch = new Granite.SwitchModelButton (_("Mirror Desktop to XR")) {
            active = dbus_service.enabled
        };
        main_switch.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);
        main_switch.bind_property ("active", dbus_service, "enabled", GLib.BindingFlags.BIDIRECTIONAL);

        add (main_switch);
        show_all ();
    }
}
