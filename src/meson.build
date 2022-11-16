gtkpacker_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
  'packer.vala'
]

gtkpacker_deps = [
  dependency('gtk4'),
  dependency('gee-0.8'),
  dependency('gio-2.0'),
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
]

gtkpacker_sources += gnome.compile_resources('gtkpacker-resources',
  'gtkpacker.gresource.xml',
  c_name: 'gtkpacker'
)

executable('gtkpacker', gtkpacker_sources,
  dependencies: gtkpacker_deps,
       install: true,
)
