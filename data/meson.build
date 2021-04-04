i18n.merge_file(
    input: 'xr.appdata.xml.in',
    output: 'io.elementary.wingpanel.xr.appdata.xml',
    po_dir: join_paths(meson.source_root (), 'po', 'extra'),
    install_dir: join_paths(datadir, 'metainfo'),
    install: true
)

# XRService DBus interface
subdir('xrservice')