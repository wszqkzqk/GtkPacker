version_file = vcs_tag(
   command: ['git', 'describe', '--tags'],
     input: 'version.vala.in',
    output: 'version.vala'
)

gtkpacker_sources = [
  'main.vala',
  'packer.vala',
  version_file
]

gtkpacker_deps = [
  glib,
  gio,
  gobject
]

executable('gtkpacker', gtkpacker_sources,
  dependencies: gtkpacker_deps,
       install: true,
 win_subsystem: 'windows'
)
