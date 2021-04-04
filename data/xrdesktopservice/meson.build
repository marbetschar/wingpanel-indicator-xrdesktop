dbus_dep = dependency('dbus-1')
dbus_interfaces_dir = dbus_dep.get_pkgconfig_variable('interfaces_dir', define_variable: ['datadir', datadir])

install_data(
    'io.elementary.pantheon.XRDesktopService.xml',
    install_dir: dbus_interfaces_dir
)