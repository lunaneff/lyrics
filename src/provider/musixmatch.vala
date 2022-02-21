/* musixmatch.vala
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
    class Musixmatch : Object, IProvider {
        // Based on https://github.com/khanhas/spicetify-cli/blob/6944a17be8e66f650d98a7bae3bdf93d55576ae9/CustomApps/lyrics-plus/ProviderMusixmatch.js

        private string api_key;
        private Soup.Session session;

        public bool supports_unsynced { get { return true; } }
        public bool supports_synced { get { return true; } }

        public Musixmatch(string api_key = "220220c1d4f9934a939b00db35f68c4bdd006cb8886e457cb336e3") {
            this.api_key = api_key;
            session = new Soup.Session();
        }

        public async string search(TrackInfo info) {
            var url = "https://apic-desktop.musixmatch.com/ws/1.1/macro.subtitles.get?format=json&namespace=lyrics_richsynched&subtitle_format=mxm&app_id=web-desktop-app-v1.0";

            if(info.album != null) {
                url += "&q_album=" + Uri.escape_string(info.album);
            }
            if(info.artists != null) {
                url += "&q_artist=" + Uri.escape_string(info.artists[0]);
            }
            if(info.artists != null) {
                url += "&q_artists=" + Uri.escape_string(info.artists[0]);
            }
            if(info.title != null) {
                url += "&q_title=" + Uri.escape_string(info.title);
            }
            if(info.spotify_id != null) {
                url += "&track_spotify_id=" + Uri.escape_string(info.spotify_id);
            }
            if(info.duration != -1) {
                url += "&q_duration=" + Uri.escape_string(info.duration.to_string());
                url += "&f_subtitle_length=" + Uri.escape_string(info.duration.to_string());
            }

            url += "&usertoken=" + Uri.escape_string(api_key);

            message(url);
            var msg = new Soup.Message("GET", url);
            msg.request_headers.append("Authority", "apic-desktop.musixmatch.com");
            msg.request_headers.append("Cookie", "x-mxm-token-guid=");

            var stream = yield session.send_async(msg);
            var dis = new DataInputStream(stream);
            var data = yield dis.read_upto_async("\0", 1, Priority.DEFAULT, null, null);
            message(data);

            return null;
        }

        public async ListModel get_unsynced(string id) {
            return null;
        }

        public async ListModel get_synced(string id) {
            return null;
        }
    }
}
