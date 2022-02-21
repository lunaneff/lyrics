/* application.vala
 *
 * Copyright 2022 Laurin Neff
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Lyrics {
	public class Application : Adw.Application {
		private ActionEntry[] APP_ACTIONS = {
			{ "about", on_about_action },
			{ "preferences", on_preferences_action },
			{ "quit", quit }
		};


		public Application () {
			Object (application_id: "ch.laurinneff.Lyrics", flags: ApplicationFlags.FLAGS_NONE);

			this.add_action_entries(this.APP_ACTIONS, this);
			this.set_accels_for_action("app.quit", {"<primary>q"});
		}

		public override void activate () {
			base.activate();
			var win = this.active_window;
			if (win == null) {
				win = new Lyrics.Window (this);
			}
			win.present ();
		}

		private void on_about_action () {
			string[] authors = {"Laurin Neff"};
			Gtk.show_about_dialog(this.active_window,
				                  "program-name", "lyrics",
				                  "authors", authors,
				                  "version", "0.1.0");
		}

		private void on_preferences_action () {
			message("app.preferences action activated");
		}
	}
}
