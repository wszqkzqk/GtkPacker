version_file = vcs_tag(
   command: ['git', 'describe', '--tags'],
     input: 'version.vala.in',
    output: 'version.vala'
)

gtkpacker_sources = [
  'main.vala',
  'application.vala',
  'mainwindow.vala',
  'packer.vala',
  version_file
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
 win_subsystem: 'windows'
)
