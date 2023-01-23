/* packer.vala
 *
 * Copyright 2022-2023 wszqkzqk (周乾康) <wszqkzqk@stu.pku.edu.cn>
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
    public class GtkPacker : Object {
        public string file_path;
        public string outdir;
        string mingw_path = null;
        static Regex msys2_dep_regex {
            get;
            default = /.*(\/|\\)(usr|ucrt64|clang64|mingw64|mingw32|clang32|clangarm64)(\/|\\)/;
        }
        GenericSet<string> dependencies = new GenericSet<string> (str_hash, str_equal);
        bool always_copy_themes;
        bool copy_locale_files;
    
        public GtkPacker (string file_path, string outdir, bool always_copy_themes, bool copy_locale_files) {
            this.file_path = file_path;
            this.outdir = outdir;
            this.always_copy_themes = always_copy_themes;
            this.copy_locale_files = copy_locale_files;
        }
    
        void copy_bin_files () throws Error {
            string deps_info;
    
            Process.spawn_command_line_sync (@"ntldd -R '$(this.file_path)'", out deps_info);
            var bin_path = Path.build_path (Path.DIR_SEPARATOR_S, this.outdir, "bin");
            DirUtils.create_with_parents (bin_path, 0644);
            
            var file = File.new_for_path (this.file_path);
            var target = File.new_for_path (Path.build_path (Path.DIR_SEPARATOR_S, bin_path, file.get_basename ()));
            file.copy (target, FileCopyFlags.OVERWRITE);
            
            var deps_info_array = deps_info.split ("\n");
            foreach (unowned var i in deps_info_array) {
                var item = (i._strip ()).split (" ");
                if ((item.length == 4) && (!(item[0] in this.dependencies))) {
                    bool condition;
                    if (this.mingw_path == null) {
                        MatchInfo match_info;
                        condition = msys2_dep_regex.match (item[2], 0, out match_info);
                        this.mingw_path = match_info.fetch (0);
                    } else {
                        condition = msys2_dep_regex.match (item[2]);
                    }
                    if (condition) {
                        this.dependencies.add (item[0]);
                        file = File.new_for_path (item[2]);
                        target = File.new_for_path (Path.build_path(Path.DIR_SEPARATOR_S, bin_path, item[0]));
                        file.copy (target, FileCopyFlags.OVERWRITE);
                    }
                }
            }
        }
    
        static bool copy_recursive (File src, File dest, FileCopyFlags flags = FileCopyFlags.NONE, Cancellable? cancellable = null) throws Error {
            FileType src_type = src.query_file_type (FileQueryInfoFlags.NONE, cancellable);
            if (src_type == FileType.DIRECTORY) {
                string src_path = src.get_path ();
                string dest_path = dest.get_path ();
                DirUtils.create_with_parents(dest_path, 0644);
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
    
        inline void copy_resources () throws Error {
            string[] resources = {
                Path.build_path (Path.DIR_SEPARATOR_S, "share", "themes", "default", "gtk-3.0"),
                Path.build_path (Path.DIR_SEPARATOR_S, "share", "themes", "emacs", "gtk-3.0"),
                Path.build_path (Path.DIR_SEPARATOR_S, "share", "glib-2.0", "schemas"),
                Path.build_path (Path.DIR_SEPARATOR_S, "share", "icons"),
                // Keep to the last item
                Path.build_path (Path.DIR_SEPARATOR_S, "lib", "gdk-pixbuf-2.0")
            };

            if (always_copy_themes || "libgtk-3-0.dll" in this.dependencies) {
                foreach (unowned var item in resources) {
                    var resource = File.new_for_path (
                        Path.build_path (
                            Path.DIR_SEPARATOR_S,
                            this.mingw_path,
                            item
                        )
                    );
                    var target = File.new_for_path (
                        Path.build_path (
                            Path.DIR_SEPARATOR_S,
                            this.outdir,
                            item
                        )
                    );
                    copy_recursive (resource, target, FileCopyFlags.OVERWRITE);
                }
            } else if ("libgtk-4-1.dll" in this.dependencies) {
                var resource = File.new_for_path (
                    Path.build_path (
                        Path.DIR_SEPARATOR_S,
                        this.mingw_path,
                        resources[resources.length - 1]
                    )
                );
                var target = File.new_for_path (
                    Path.build_path (
                        Path.DIR_SEPARATOR_S,
                        this.outdir,
                        resources[resources.length - 1]
                    )
                );
                copy_recursive (resource, target, FileCopyFlags.OVERWRITE);
            }
        }

        inline void copy_locale () throws Error  {
            var resource = File.new_for_path (
                Path.build_path(
                    Path.DIR_SEPARATOR_S,
                    this.mingw_path,
                    "share",
                    "locale"
                )
            );
            var target = File.new_for_path (
                Path.build_path (
                    Path.DIR_SEPARATOR_S,
                    this.outdir,
                    "share",
                    "locale"
                )
            );
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
