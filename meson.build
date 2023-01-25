project('gtkpacker', ['c', 'vala'],
          version: run_command('git', 'describe', '--tags').stdout().strip(),
    meson_version: '>= 0.59.0',
  default_options: [ 'warning_level=2', 'werror=false', ],
)

add_project_arguments('-DGETTEXT_PACKAGE="{}"'.format(meson.project_name()), language: 'c')

i18n = import('i18n')
gnome = import('gnome')

gtk4 = dependency('gtk4')
gio = dependency('gio-2.0')
glib = dependency('glib-2.0')
gobject = dependency('gobject-2.0')

subdir('data')
subdir('src')
subdir('po')

gnome.post_install(
     glib_compile_schemas: true,
    gtk_update_icon_cache: true,
)
