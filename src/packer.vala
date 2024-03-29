/* packer.vala
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

namespace GtkPacker {
    public class GtkPacker {
        string file_path;
        string outdir;
        string mingw_path = null;
        static Regex msys2_dep_regex = /.*[\/\\](usr|ucrt64|clang(32|64|arm64)|mingw(32|64))[\/\\]/i;
        static Regex ignore_dep_regex = /^$|^not$|.*[\/\\](WINDOWS)[\/\\]/mi;
        static Regex ignore_res_regex = /.*\.(a|xml|dtd)$/i;
        //string parent_dir;
        GenericSet<string> dependencies = new GenericSet<string> (str_hash, str_equal);
        bool always_copy_themes;
        bool copy_locale_files;
        bool lazy_copy_locale;
    
        /*
            * @param file_path: the path of the executable file
            * @param outdir: the output directory
            * @param always_copy_themes: whether to copy themes even if the executable file is not a GTK application
            * @param copy_locale_files: whether to copy locale files
            * @param lazy_copy_locale: whether to copy locale files only when the locale file is needed
         */
        public GtkPacker (string file_path, string outdir,
                          bool always_copy_themes, bool copy_locale_files,
                          bool lazy_copy_locale) {
            this.file_path = file_path;
            this.outdir = outdir;
            this.always_copy_themes = always_copy_themes;
            this.copy_locale_files = copy_locale_files;
            this.lazy_copy_locale = lazy_copy_locale;
            //parent_dir = Path.get_dirname (file_path).down ();
        }
    
        
        /*
            * Copy the executable file and its dependencies to the output directory
         */
        void copy_bin_files () throws Error {
            string deps_info;
    
            Process.spawn_command_line_sync (@"ntldd -R '$(this.file_path)'", out deps_info);
            var bin_path = Path.build_filename (this.outdir, "bin");
            DirUtils.create_with_parents (bin_path, 0644);
            
            var file = File.new_for_path (this.file_path);
            var target = File.new_for_path (Path.build_filename (bin_path, file.get_basename ()));
            file.copy (target, FileCopyFlags.OVERWRITE);
            
            var deps_info_array = deps_info.split ("\n");
            foreach (unowned var i in deps_info_array) {
                var item = (i._strip ()).split (" ");
                if ((item.length == 4) && (!(item[0] in this.dependencies))) {
                    bool condition = false;
                    if (this.mingw_path == null) {
                        MatchInfo match_info;
                        condition = msys2_dep_regex.match (item[2], 0, out match_info);
                        this.mingw_path = match_info.fetch (0);
                    }
                    if (!condition && item[2] != null) {
                        if (!ignore_dep_regex.match (item[2])) {
                            condition = true;
                        }
                    }
                    if (condition) {
                        this.dependencies.add (item[0]);
                        file = File.new_for_path (item[2]);
                        target = File.new_for_path (Path.build_filename (bin_path, item[0]));
                        file.copy (target, FileCopyFlags.OVERWRITE);
                    }
                }
            }
        }
    
        /*
            * Recursively copy method
         */
        static bool copy_recursive (File src, File dest, FileCopyFlags flags = FileCopyFlags.NONE, Cancellable? cancellable = null) throws Error {
            FileType src_type = src.query_file_type (FileQueryInfoFlags.NONE, cancellable);
            if (src_type == FileType.DIRECTORY) {
                string src_path = src.get_path ();
                string dest_path = dest.get_path ();
                DirUtils.create_with_parents (dest_path, 0644);
                src.copy_attributes (dest, flags, cancellable);
            
                FileEnumerator enumerator = src.enumerate_children (FileAttribute.STANDARD_NAME, FileQueryInfoFlags.NONE, cancellable);
                for (FileInfo? info = enumerator.next_file (cancellable) ; info != null ; info = enumerator.next_file (cancellable)) {
                    copy_recursive (
                    File.new_for_path (Path.build_filename (src_path, info.get_name ())),
                    File.new_for_path (Path.build_filename (dest_path, info.get_name ())),
                    flags,
                    cancellable);
                }
            } else if (src_type == FileType.REGULAR) {
                src.copy (dest, flags, cancellable);
            }

            return true;
        }
    
        /*
            * Copy the resources of the executable file to the output directory
         */
        inline void copy_resources () throws Error {
            string[] gtk3_only_resources = {
                Path.build_filename ("share", "themes", "default", "gtk-3.0"),
                Path.build_filename ("share", "themes", "emacs", "gtk-3.0"),
                Path.build_filename ("share", "icons", "hicolor")
            };

            string[] gtk_resources = {
                Path.build_filename ("share", "glib-2.0", "schemas"),
                Path.build_filename ("lib", "gdk-pixbuf-2.0")
            };

            if (always_copy_themes
            || "libgtk-3-0.dll" in this.dependencies
            || "libgtk-4-1.dll" in this.dependencies) {
                if (always_copy_themes || "libgtk-3-0.dll" in this.dependencies) {
                    foreach (unowned var item in gtk3_only_resources) {
                        var resource = File.new_for_path (
                            Path.build_filename (
                                this.mingw_path,
                                item
                            )
                        );
                        var target = File.new_for_path (
                            Path.build_filename (
                                this.outdir,
                                item
                            )
                        );
                        copy_recursive (resource, target, FileCopyFlags.OVERWRITE);
                    }
                }

                // Ignore statically linked files and xml or dtd that have compiled
                foreach (unowned var item in gtk_resources) {
                    var resource = File.new_for_path (
                        Path.build_filename (
                            this.mingw_path,
                            item
                        )
                    );
                    var target = File.new_for_path (
                        Path.build_filename (
                            this.outdir,
                            item
                        )
                    );
                    copy_regex_match (resource, target, ignore_res_regex, true, FileCopyFlags.OVERWRITE);
                }
            }
        }

        static void copy_regex_match (File src, File dest, Regex re, bool reverse = false, FileCopyFlags flags = FileCopyFlags.NONE, Cancellable? cancellable = null) throws Error {
            FileType src_type = src.query_file_type (FileQueryInfoFlags.NONE, cancellable);
            string src_path = src.get_path ();
            if (src_type == FileType.DIRECTORY) {
                string dest_path = dest.get_path ();
                FileEnumerator enumerator = src.enumerate_children (FileAttribute.STANDARD_NAME, FileQueryInfoFlags.NONE, cancellable);
                for (FileInfo? info = enumerator.next_file (cancellable) ; info != null ; info = enumerator.next_file (cancellable)) {
                    copy_regex_match (
                    File.new_for_path (Path.build_filename (src_path, info.get_name ())),
                    File.new_for_path (Path.build_filename (dest_path, info.get_name ())),
                    re,
                    reverse,
                    flags,
                    cancellable);
                }
            } else if (src_type == FileType.REGULAR
            && ((reverse) ? (!re.match (src_path)) : re.match (src_path))) {
                var dest_parent = dest.get_parent ();
                if (dest_parent.query_file_type (FileQueryInfoFlags.NONE, cancellable) != FileType.DIRECTORY) {
                    DirUtils.create_with_parents (dest_parent.get_path (), 0644);
                    (src.get_parent ()).copy_attributes (dest_parent, flags, cancellable);
                }
                src.copy (dest, flags, cancellable);
            }
        }

        /*
            * Copy the locale files to the output directory
         */
        inline void copy_locale () throws Error {
            var resource = File.new_for_path (
                Path.build_filename (
                    this.mingw_path,
                    "share",
                    "locale"
                )
            );
            var target = File.new_for_path (
                Path.build_filename (
                    this.outdir,
                    "share",
                    "locale"
                )
            );
            Regex re;
            if ("libadwaita-1-0.dll" in this.dependencies) {
                re = /.*(libadwaita|gtk40|glib20)\.mo$/i;
            } else if ("libgtk-4-1.dll" in this.dependencies) {
                re = /.*(gtk40|glib20)\.mo$/i;
            } else if ("libgtk-3-0.dll" in this.dependencies) {
                re = /.*(gtk30(-properties)?|glib20)\.mo$/i;
            } else {
                re = /.*glib20.mo$/i;
            }
            copy_regex_match (resource, target, re, false, FileCopyFlags.OVERWRITE);
        }

        public inline void run () throws Error {
            this.copy_bin_files ();
            this.copy_resources ();
            if (copy_locale_files) {
                copy_locale ();
            }
        }
    }
}
