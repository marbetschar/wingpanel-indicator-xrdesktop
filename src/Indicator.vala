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

public class XRIndicator.Indicator : Wingpanel.Indicator {
    public bool is_in_session { get; construct; default = false; }

    private Widgets.PopoverWidget popover_widget;
    private Widgets.DisplayWidget dynamic_icon;
    private Services.ObjectManager object_manager;

    public Indicator (bool is_in_session) {
        Object (
            code_name: "xr",
            is_in_session: is_in_session
        );
    }

    construct {
        object_manager = new XRIndicator.Services.ObjectManager ();
    }

    public override Gtk.Widget get_display_widget () {
        if (dynamic_icon == null) {
            dynamic_icon = new Widgets.DisplayWidget (object_manager);
        }

        return dynamic_icon;
    }

    public override Gtk.Widget? get_widget () {
        if (popover_widget == null) {
            popover_widget = new Widgets.PopoverWidget (object_manager, is_in_session);
        }

        return popover_widget;
    }


    public override void opened () {
    }

    public override void closed () {
    }
}

public Wingpanel.Indicator get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    debug ("Activating XR Indicator");
    var indicator = new XRIndicator.Indicator (server_type == Wingpanel.IndicatorManager.ServerType.SESSION);

    return indicator;
}
