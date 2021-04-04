# Wingpanel XR Desktop Indicator

![Screenshot](data/screenshot.png?raw=true)

## Building and Installation

You'll need the following dependencies:

    gobject-introspection
    libglib2.0-dev
    libgranite-dev >= 6.0.0
    libnotify-dev
    libwingpanel-dev
    meson
    valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install
