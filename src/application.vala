/* application.vala
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
    public class Application : Gtk.Application {
        public Application () {
            Object (application_id: "dev.wszqkzqk.gtkpacker", flags: ApplicationFlags.FLAGS_NONE);
        }

        construct {
            ActionEntry[] action_entries = {
                { "about", this.on_about_action },
                { "preferences", this.on_preferences_action },
                { "quit", this.quit }
            };
            this.add_action_entries (action_entries, this);
            this.set_accels_for_action ("app.quit", {"<primary>q"});
        }

        public override void activate () {
            base.activate ();
            var win = this.active_window;
            if (win == null) {
                win = new MainWindow (this);
            }
            win.present ();
        }

        private void on_about_action () {
            string[] authors = { "wszqkzqk (周乾康)" };
            Gtk.show_about_dialog (this.active_window,
                                   "program-name", "gtkpacker",
                                   "logo-icon-name", "dev.wszqkzqk.gtkpacker",
                                   "authors", authors,
                                   "version", VERSION,
                                   "copyright", "© 2022-2023 wszqkzqk (周乾康) <wszqkzqk@stu.pku.edu.cn>");
        }

        private void on_preferences_action () {
            message ("app.preferences action activated");
        }
    }
}
