gtkpacker_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
  'packer.vala'
]

gtkpacker_deps = [
  gtk4,
  glib,
  gio,
  gobject
]

gtkpacker_sources += gnome.compile_resources('gtkpacker-resources',
  'gtkpacker.gresource.xml',
  c_name: 'gtkpacker'
)

executable('gtkpacker', gtkpacker_sources,
  dependencies: gtkpacker_deps,
       install: true,
)
