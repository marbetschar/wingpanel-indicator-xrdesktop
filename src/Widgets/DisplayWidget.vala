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

public class XRDesktopIndicator.Widgets.DisplayWidget : Gtk.Spinner {
    public XRDesktopIndicator.Services.DBusService dbus_service { get; construct; }

    private unowned Gtk.StyleContext style_context;

    public DisplayWidget (XRDesktopIndicator.Services.DBusService dbus_service) {
        Object (dbus_service: dbus_service);
    }

    construct {
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("io/elementary/wingpanel/xrdesktop/indicator.css");

        style_context = get_style_context ();
        style_context.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        style_context.add_class ("xrdesktop-icon");
        style_context.add_class ("disabled");

        dbus_service.notify["enabled"].connect (update_icon);
    }

    private void update_icon () {
        var enabled = dbus_service.enabled;
        string description;
        string context;

        if (enabled) {
            style_context.remove_class ("disabled");
            description = _("Mirroring to XR is enabled");
            context = _("Middle-click to disable mirroring to XR");
        } else {
            style_context.add_class ("disabled");
            description = _("Mirroring to XR is disabled");
            context = _("Middle-click to enable mirroring to XR");
        }

        tooltip_markup = "%s\n%s".printf (
            description, Granite.TOOLTIP_SECONDARY_TEXT_MARKUP.printf (context)
        );
    }
}
