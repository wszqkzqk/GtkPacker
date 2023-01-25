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
        string[] locales;
        Gtk.Entry lang_entry;
        bool lang_in_entry = false;

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
                margin_top = 10,
                margin_bottom = 10,
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
                var box_line4_following = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                {   // A label and a switch ABOUT I18N
                    // Whether to copy locale files

                    // May also add an option to only copy the languages contained in `PROFILE`
                    // or input these languages (luaguage supported by the application)
                    // These options should only shown when the shitch thrned on
                    var label = new Gtk.Label (_("Options of built-in locale files:")) {
                        hexpand = true,
                        halign = Gtk.Align.START
                    };
                    box_line4.append (label);

                    Gtk.DropDown dropdown;
                    {
                        string[] options = {
                            _("Don't copy"),
                            _("Copy all locale files"),
                            _("Copy the locale files included in PROFILE"),
                            _("Input supported languages to copy")
                        };
                        dropdown = new Gtk.DropDown.from_strings(options);
                        dropdown.notify["selected"].connect(() => {
                            lang_in_entry = false;
                            switch (dropdown.get_selected()) {
                            case 0:
                            case 1:
                                // Don't copy or copy all
                                box.remove (box_line4_following);
                                break;
                            case 2:
                                // Copy the locale files included in PROFILE
                                // Add PROFILE selecter
                                box.remove (box_line4_following);
                                box_line4_following = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                                {
                                    var label_following = new Gtk.Label (_("Locales imported from PROFILE:")) {
                                        hexpand = true,
                                        halign = Gtk.Align.START
                                    };
                                    box_line4_following.append (label_following);
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
                                                uint8[] content;
                                                file_chooser.get_file ().load_contents (null, out content, null);
                                                var re = /\s+/;
                                                var langinfo = re.replace_literal (((string) content), -1, 0, " ");
                                                locales = langinfo.split (" ");
                                                file_button.label = langinfo;
                                            }
                                        });
                                        file_chooser.show ();
                                    });
                                    box_line4_following.append (file_button);
                                }
                                box.insert_child_after (box_line4_following, box_line4);
                                break;
                            case 3:
                                box.remove (box_line4_following);
                                box_line4_following = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                                {
                                    var label_following = new Gtk.Label (_("Input languages:")) {
                                        hexpand = true,
                                        halign = Gtk.Align.START
                                    };
                                    box_line4_following.append (label_following);
                                    lang_entry = new Gtk.Entry ();
                                    lang_entry.set_placeholder_text(_("Languages splited by spaces"));
                                    box_line4_following.append (lang_entry);
                                }
                                box.insert_child_after (box_line4_following, box_line4);
                                lang_in_entry = true;
                                break;
                            }
                        });
                    }
                    box_line4.append (dropdown);
                }
                box.append (box_line4);

                var box_line5 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                {   // Locale files of the applicaiton itself
                    var label = new Gtk.Label (_("Copy locale files of the application:")) {
                        hexpand = true,
                        halign = Gtk.Align.START
                    };
                    box_line5.append (label);

                    var switch_button = new Gtk.Switch ();
                    box_line5.append (switch_button);
                }
                box.append (box_line5);

                var box_last = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
                    halign = Gtk.Align.CENTER,
                    valign = Gtk.Align.END,
                    vexpand = true
                };
                {   // Confirm Button
                    var button = new Gtk.Button.with_label (_("Confirm"));
                    {
                        button.clicked.connect (() => {
                            if (exec_file_path == null || output_dir_path == null) {
                                return;
                            }
                            if (lang_in_entry) {
                                var re = /\s+/;
                                var langinfo = re.replace_literal ((lang_entry.buffer.text), -1, 0, " ");
                                locales = langinfo.split (" ");
                            }
                            var packer = new GtkPacker (
                                exec_file_path,
                                output_dir_path,
                                always_copy_themes,
                                copy_locale_files,
                                locales
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
