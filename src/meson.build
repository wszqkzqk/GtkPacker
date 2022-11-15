gtkpacker_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
]

gtkpacker_deps = [
  dependency('gtk4'),
]

gtkpacker_sources += gnome.compile_resources('gtkpacker-resources',
  'gtkpacker.gresource.xml',
  c_name: 'gtkpacker'
)

executable('gtkpacker', gtkpacker_sources,
  dependencies: gtkpacker_deps,
       install: true,
)
