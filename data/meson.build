i18n.merge_file(
    input: 'xr.appdata.xml.in',
    output: 'io.elementary.wingpanel.xr.appdata.xml',
    po_dir: join_paths(meson.source_root (), 'po', 'extra'),
    install_dir: join_paths(datadir, 'metainfo'),
    install: true
)

install_data(
    'gschema.xml',
    rename: 'io.elementary.desktop.wingpanel.xr.gschema.xml',
    install_dir: join_paths(datadir, 'glib-2.0', 'schemas')
)
