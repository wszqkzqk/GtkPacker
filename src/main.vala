/* main.vala
 *
 * Copyright 2022-2023 wszqkzqk (周乾康) <wszqkzqk@qq.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

/* Configs for vala
 * const to use, define in C's `-D` arguement
 */
extern const string GETTEXT_PACKAGE;

namespace GtkPacker {    
    public class CLI {
        static bool show_version = false;
        static string? file_path = null;
        static string? outdir = null;
        static bool always_copy_themes = false;
        static bool copy_locale_files = true;
        static bool lazy_copy_locale = true;
        static string? user_locale_file_dir = null;
        static string[]? supported_langs = null;
        static OptionEntry[] options = {
            { "version", 'v', OptionFlags.NONE, OptionArg.NONE, ref show_version, _("Display version number"), null },
            { "input", 'i', OptionFlags.NONE, OptionArg.FILENAME, ref file_path, _("Input executable FILE"), "FILENAME" },
            { "output", 'o', OptionFlags.NONE, OptionArg.FILENAME, ref outdir, _("Place output in DIRECTORY"), "DIRECTORY" },
            { "always-copy-themes", '\0', OptionFlags.NONE, OptionArg.NONE, ref always_copy_themes, _("Force to copy the theme files of GTK"), null },
            { "ignore-builtin-locale", '\0', OptionFlags.REVERSE, OptionArg.NONE, ref copy_locale_files, _("Do NOT copy the locale file of dependency libraries"), null },
            { "full-copy-locale", '\0', OptionFlags.REVERSE, OptionArg.NONE, ref lazy_copy_locale, _("Copy all locale file of dependency libraries instead of only the needed files"), null },
            { "set-supported-lang", 'a', OptionFlags.NONE, OptionArg.STRING_ARRAY, ref supported_langs, _("Manually set supported language of the application, can be used more than one times"), "LANG" },
            { "locale-dir", 'l', OptionFlags.NONE, OptionArg.FILENAME, ref user_locale_file_dir, _("The locale DIRECTORY of you application"), "DIRECTORY" },
            null
        };
        OptionContext opt_context = new OptionContext ("A tool to pack GTK applications in Windows");

        public inline CLI () {
            opt_context.set_help_enabled (true);
            opt_context.add_main_entries (options, null);
        }

        public inline void parse (ref weak string[] args)
        throws OptionError {
            opt_context.parse (ref args);
        }

        public static int main (string[] args) {
            Intl.setlocale ();

            try {
                var cli = new CLI ();
                cli.parse (ref args);
            } catch (OptionError e) {
                printerr (_("error: %s\n"), e.message);
                return 1;
            }

            if (show_version) {
                print ("GtkPacker CLI v%s\n", VERSION);
                return 0;
            }

            if (file_path == null) {
                printerr (_("error: The executable file to copy is not set.\n"));
                return 1;
            }
            if (outdir == null) {
                printerr (_("error: The output directory is not set.\n"));
                return 1;
            }

            var packer = new GtkPacker (
                file_path,
                outdir,
                always_copy_themes,
                copy_locale_files,
                lazy_copy_locale
            );
            try {
                packer.run ();
            } catch (Error e) {
                printerr (_("error: %s\n"), e.message);
                return 1;
            }

            return 0;
        }
    }
}
