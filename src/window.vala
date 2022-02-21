/* window.vala
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
	[GtkTemplate (ui = "/ch/laurinneff/Lyrics/window.ui")]
	public class Window : Adw.ApplicationWindow {
	    private string player;
	    private TrackInfo current_track;
	    private Provider.IProvider provider;

	    [GtkChild]
	    private unowned Gtk.Stack stack;
	    [GtkChild]
	    private unowned Gtk.ListView unsynced_list_view;
	    [GtkChild]
	    private unowned Gtk.ProgressBar progress_bar;

		public Window (Gtk.Application app) {
			Object (application: app);

			provider = new Provider.Genius();

			var unsynced_factory = new Gtk.SignalListItemFactory();
            unsynced_factory.setup.connect((listitem) => {
                var label = new Gtk.Label("");
                label.use_markup = true;
                listitem.child = label;
            });
            unsynced_factory.teardown.connect((listitem) => {
                listitem.child = null;
            });
            unsynced_factory.bind.connect((listitem) => {
                var label = (Gtk.Label) listitem.child;
                var lyric = (Lyric) listitem.item;
                label.label = "<span size=\"x-large\" weight=\"bold\">" + lyric.text + "</span>";
            });
            unsynced_list_view.factory = unsynced_factory;

            populate_players_list.begin();
			GLib.Timeout.add(100, () => { this.poll_mpris.begin(); return Source.CONTINUE; });
		}

		private async void populate_players_list() {
			var players = yield Mpris.discover();
			this.player = players[0];
		}

		private async void poll_mpris() {
		    if(player == null) return;

			try {
			    // I know reconnecting every 100ms is bad, but position changes don't emit the property change signal so the cache isn't cleared
			    var mpris = yield Mpris.get(player);

			    var new_track = new TrackInfo(player, mpris.metadata);
			    if(current_track == null || new_track.track_id != current_track.track_id) {
			        current_track = new_track;
			        message("getting for %s", current_track.track_id);
                    stack.visible_child_name = "loading";
			        var id = yield provider.search(current_track);
			        if(id != null) {
			            var unsynced = yield provider.get_unsynced(id);
			            if(unsynced.get_n_items() == 0) {
			                var instrumental_placeholder = new ListStore(typeof(Lyric));
			                instrumental_placeholder.append(new Lyric("🎝 Instrumental 🎝"));
			                unsynced = instrumental_placeholder;
			            }
                        unsynced_list_view.model = new Gtk.NoSelection(unsynced);
                        stack.visible_child_name = "unsynced";
		            } else {
		                var empty_placeholder = new ListStore(typeof(Lyric));
		                empty_placeholder.append(new Lyric("<span style=\"italic\">No Lyrics found</span>"));
                        unsynced_list_view.model = new Gtk.NoSelection(empty_placeholder);
                        stack.visible_child_name = "unsynced";
		                warning("not found");
		            }
			    }

		        if(mpris.playback_status == "Playing") {
                    title = "%s - %s".printf(string.joinv(", ", mpris.artists), mpris.title);
                } else {
                    title = "Lyrics";
                }

                progress_bar.fraction = 1.0 * mpris.position / mpris.length;
			} catch(GLib.Error e) {
			    error(e.message);
			}
		}
	}
}
