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

public class XRIndicator.Widgets.PopoverWidget : Gtk.Box {
    public XRIndicator.Services.ObjectManager object_manager { get; construct; }
    public bool is_in_session { get; construct; }

    private Granite.SwitchModelButton main_switch;

    public PopoverWidget (XRIndicator.Services.ObjectManager object_manager, bool is_in_session) {
        Object (
            object_manager: object_manager,
            is_in_session: is_in_session
        );
    }

    construct {
        orientation = Gtk.Orientation.VERTICAL;

        main_switch = new Granite.SwitchModelButton (_("Mirror to XR")) {
            active = object_manager.get_global_state ()
        };
        main_switch.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        add (main_switch);

        main_switch.active = object_manager.get_global_state ();

        update_ui_state (object_manager.get_global_state ());
        show_all ();

        main_switch.notify["active"].connect (() => {
            object_manager.set_global_state.begin (main_switch.active);
        });

        object_manager.global_state_changed.connect ((state) => {
            update_ui_state (state);
        });
    }

    private void update_ui_state (bool state) {
        if (main_switch.active != state) {
            main_switch.active = state;
        }
    }
}
