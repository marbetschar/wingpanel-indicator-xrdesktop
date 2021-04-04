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

public class XRIndicator.Widgets.DisplayWidget : Gtk.Spinner {
    public XRIndicator.Services.ObjectManager object_manager { get; construct; }

    private unowned Gtk.StyleContext style_context;

    public DisplayWidget (XRIndicator.Services.ObjectManager object_manager) {
        Object (object_manager: object_manager);
    }

    construct {
        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("io/elementary/wingpanel/xr/indicator.css");

        style_context = get_style_context ();
        style_context.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        style_context.add_class ("xr-icon");
        style_context.add_class ("disabled");

        object_manager.global_state_changed.connect ((state, connected) => {
            set_icon ();
        });

        if (object_manager.retrieve_finished) {
            set_icon ();
        } else {
            object_manager.notify["retrieve-finished"].connect (set_icon);
        }

        button_press_event.connect ((e) => {
            if (e.button == Gdk.BUTTON_MIDDLE) {
                object_manager.set_global_state.begin (!object_manager.get_global_state ());
                return Gdk.EVENT_STOP;
            }

            return Gdk.EVENT_PROPAGATE;
        });
    }

    private void set_icon () {
        if (get_realized ()) {
            update_icon ();
        } else {
            /* When called from constructor usually not realized */
            realize.connect_after (update_icon);
        }
    }

    private void update_icon () {
        var enabled = object_manager.is_enabled;
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
