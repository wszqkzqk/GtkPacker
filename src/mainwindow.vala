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
        public File exec_file {get; set;}
        protected string _exec_file_path;
        public string exec_file_path {
            get {
                _exec_file_path = exec_file.get_path ();
                return _exec_file_path;
            }
        }

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
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 4);
            {   // Each line of the VERTICAL box
                var box_line1 = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 2);
                {   // A label and a filechooserbutton
                    var label = new Gtk.Label (_("File Path:")) {
                        hexpand = true,
                        halign = Gtk.Align.START
                    };
                    box_line1.append (label);

                    var file_button = new Gtk.Button.with_label ("...");
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
                        file_chooser.show ();
                    });
                    box_line1.append (file_button);
                }
                box.append (box_line1);
            }
            this.child = box;
        }
    }
}
