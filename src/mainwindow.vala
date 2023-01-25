/* mainwindow.vala
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
    public class MainWindow : Gtk.ApplicationWindow {
        public File? exec_file {get; set;}
        public string? exec_file_path {
            owned get {
                return (exec_file == null) ? null : exec_file.get_path ();
            }
        }
        public File? output_dir {get; set;}
        public string? output_dir_path {
            owned get {
                return (output_dir == null) ? null : output_dir.get_path ();
            }
        }
        bool always_copy_themes = false;
        bool copy_locale_files = false;

        public MainWindow (Gtk.Application app) {
            Object (
                application: app,
                title: _("GtkPacker")
            );

            /* Use block to show containment relationship */

            // Title bar
            var header_bar = new Gtk.HeaderBar ();
            {   // End of title bar: a menu button
                var menu_button = new Gtk.MenuButton ();
                menu_button.icon_name = "open-menu-symbolic";
                {   // menu of the menu button
                    var primary_menu = new Menu ();
                    {   // item of the menu
                        primary_menu.append (_("Preferences"), "app.preferences");
                        primary_menu.append (_("Keyboard Shortcuts"), "win.show-help-overlay");
                        primary_menu.append (_("About GtkPacker"), "app.about");
                    }
                    menu_button.menu_model = primary_menu;
                }
                header_bar.pack_end (menu_button);
            }
            this.titlebar = header_bar;

            // A VERTICAL box to contain more than one widgets
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
                margin_start = 30,
                margin_end = 30,
                spacing = 20
            };
            {   // Each line of the VERTICAL box
                var box_line1 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                {   // A label and a filechooserbutton
                    var label = new Gtk.Label (_("File path:")) {
                        hexpand = true,
                        halign = Gtk.Align.START
                    };
                    box_line1.append (label);

                    var file_button = new Gtk.Button.with_label ("   ......   ");
                    file_button.clicked.connect (() => {
                        var file_chooser = new Gtk.FileChooserNative (
                            null,
                            this,
                            Gtk.FileChooserAction.OPEN,
                            null,
                            null
                        );
                        file_chooser.response.connect ((a) => {
                            if (a == Gtk.ResponseType.ACCEPT) {
                                exec_file = file_chooser.get_file ();
                                file_button.label = Path.get_basename (exec_file.get_path ());
                            }
                        });
                        var filter = new Gtk.FileFilter ();
                        filter.add_pattern ("*.exe");
                        file_chooser.filter = filter;
                        file_chooser.show ();
                    });
                    box_line1.append (file_button);
                }
                box.append (box_line1);

                var box_line2 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                {   // A label and a filechooserbutton
                    var label = new Gtk.Label (_("Copy to:")) {
                        hexpand = true,
                        halign = Gtk.Align.START
                    };
                    box_line2.append (label);

                    var file_button = new Gtk.Button.with_label ("   ......   ");
                    file_button.clicked.connect (() => {
                        var file_chooser = new Gtk.FileChooserNative (
                            null,
                            this,
                            Gtk.FileChooserAction.SELECT_FOLDER,
                            null,
                            null
                        );
                        file_chooser.response.connect ((a) => {
                            if (a == Gtk.ResponseType.ACCEPT) {
                                output_dir = file_chooser.get_file ();
                                file_button.label = Path.get_basename (output_dir.get_path ());
                            }
                        });
                        file_chooser.show ();
                    });
                    box_line2.append (file_button);
                }
                box.append (box_line2);

                var box_line3 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                {   // A label and a switch ABOUT THEME FILES
                    // ALWAYS COPY THEME FILES
                    var label = new Gtk.Label (_("Always copy theme files:")) {
                        hexpand = true,
                        halign = Gtk.Align.START
                    };
                    box_line3.append (label);

                    var switch_button = new Gtk.Switch () {
                        state = always_copy_themes
                    };
                    switch_button.state_set.connect (() => {
                        always_copy_themes = switch_button.state = !switch_button.state;
                        return true;
                    });
                    box_line3.append (switch_button);
                }
                box.append (box_line3);

                var box_line4 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                // The switch this line should be accessible by others
                var switch_line4 = new Gtk.Switch () { state = copy_locale_files };
                {   // A label and a switch ABOUT I18N
                    // Whether to copy locale files
                    var label = new Gtk.Label (_("Copy built-in locale files:")) {
                        hexpand = true,
                        halign = Gtk.Align.START
                    };
                    box_line4.append (label);

                    switch_line4.state_set.connect (() => {
                        copy_locale_files = switch_line4.state = !switch_line4.state;
                        return true;
                    });
                    box_line4.append (switch_line4);
                }
                box.append (box_line4);

                var box_line5 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                {   // Whether to simplify the copy of locale files
                    // (Only copy languages supported by the application)

                }
                box.append (box_line5);

                var box_last = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) { halign = Gtk.Align.CENTER };
                {   // Confirm Button
                    var button = new Gtk.Button.with_label (_("Confirm"));
                    {
                        button.clicked.connect (() => {
                            if (exec_file_path == null || output_dir_path == null) {
                                return;
                            }
                            var packer = new GtkPacker (
                                exec_file_path,
                                output_dir_path,
                                always_copy_themes,
                                copy_locale_files
                            );
                            try {
                                packer.run ();
                                var done_win = new Gtk.Window () {
                                    title = _("Done"),
                                    transient_for = this
                                };
                                var done_label = new Gtk.Label (_("Done!")) {
                                    margin_top = 30,
                                    margin_bottom = 30,
                                    margin_start = 10,
                                    margin_end = 10
                                };
                                done_win.child = done_label;
                                done_win.present ();
                            } catch (Error e) {
                                critical (e.message);
                                var error_win = new Gtk.Window () {
                                    title = _("Error"),
                                    transient_for = this
                                };
                                var error_label = new Gtk.Label (e.message) {
                                    margin_top = 30,
                                    margin_bottom = 30,
                                    margin_start = 10,
                                    margin_end = 10
                                };
                                error_win.child = error_label;
                                error_win.present ();
                            }
                        });
                    }
                    box_last.append (button);
                }
                box.append (box_last);
            }
            this.child = box;
        }
    }
}
