/* genius.vala
 *
 * Copyright 2022 Laurin Neff <laurin@laurinneff.ch>
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
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace Lyrics.Provider {
    class Genius : Object, IProvider {
        private Soup.Session session;
        private Regex simple_lyrics_regex;
        private Regex complex_lyrics_regex;

        public bool supports_unsynced { get { return true; } }
        public bool supports_synced { get { return false; } }

        public Genius() {
            session = new Soup.Session();
            simple_lyrics_regex = new Regex("<div class=\"lyrics\">(.+?)<\\/div>");
            complex_lyrics_regex = new Regex("<div ([\\w-]+=[\\w\"]+ )+class=\"Lyrics__Container.+?>(.+?)<\\/div>");
        }

        public async string search(TrackInfo info) {
            var searchUrl = "https://genius.com/api/search/song?per_page=20&q=";
            searchUrl += Uri.escape_string(info.title + " " + info.artists[0]);

            var msg = new Soup.Message("GET", searchUrl);
            var stream = yield session.send_async(msg);
            var dis = new DataInputStream(stream);
            var data = yield dis.read_upto_async("\0", 1, Priority.DEFAULT, null, null);

            var parser = new Json.Parser();
            parser.load_from_data(data);
            var hits = parser
                .get_root()
                .get_object()
                .get_object_member("response")
                .get_array_member("sections")
                .get_object_element(0)
                .get_array_member("hits");

            if(hits.get_length() != 0) {
                var url = hits
                    .get_object_element(0)
                    .get_object_member("result")
                    .get_string_member("url");
                return url;
            }

            return null;
        }

        public async ListModel get_unsynced(string url) {
            var msg = new Soup.Message("GET", url);
            var stream = yield session.send_async(msg);
            var dis = new DataInputStream(stream);
            var data = yield dis.read_upto_async("\0", 1, Priority.DEFAULT, null, null);

            ListStore lyrics = new ListStore(typeof(Lyric));

            MatchInfo matches;
            var matched = simple_lyrics_regex.match(data, 0, out matches);
            if(matched) {
                message("simple regex match");
            }

            matched = complex_lyrics_regex.match(data, 0, out matches);
            if(matched) {
                lyrics.remove_all();
                do {
                    var match = matches.fetch(2);
                    foreach(var line in match.split("<br/>")) {
                        lyrics.append(new Lyric(line));
                    }
                } while(matches.next());
            }

            return lyrics;
        }

        public async ListModel get_synced(string url) {
            return null;
        }
    }
}
