/* trackinfo.vala
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

namespace Lyrics {
    class TrackInfo : Object {
        public string title { get; construct; }
        public string[] artists { get; construct; }
        public string album { get; construct; }
        public uint64 duration { get; construct; }
        public string track_id { get; construct; }
        public string spotify_id { get; construct; }

        // Player is so we can parse out some extra player-specific fields
        public TrackInfo(string player, HashTable<string, Variant> mpris_metadata) {
            string title = null, album = null, track_id = null, spotify_id = null;
            string[] artists = null;
            uint64? duration = null;

            if(mpris_metadata.contains("xesam:title")) {
                title = mpris_metadata.get("xesam:title").get_string();
                if(title == "") title = null;
            }

            if(mpris_metadata.contains("xesam:artist")) {
                artists = mpris_metadata.get("xesam:artist").get_strv();
                if(artists.length == 0) artists = null;
            }

            if(mpris_metadata.contains("xesam:album")) {
                album = mpris_metadata.get("xesam:album").get_string();
                if(album == "") album = null;
            }

            if(mpris_metadata.contains("mpris:length")) {
                // mpris:length is in microseconds, we want seconds
                duration = mpris_metadata.get("mpris:length").get_uint64() / 1000000;
                if(duration == 0) duration = null;
            }

            if(mpris_metadata.contains("mpris:trackid")) {
                track_id = mpris_metadata.get("mpris:trackid").get_string();
                if(track_id == "") track_id = null;
            }

            switch(player) {
                case "org.mpris.MediaPlayer2.Spot":
                    if(track_id != null) {
                        // The track id is in the form /dev/alextren/Spot/Track/<spotify_id>
                        var split = track_id.split("/");
                        spotify_id = split[split.length - 1];
                    }
                    break;
            }

            Object(
                title: title,
                artists: artists,
                album: album,
                duration: duration,
                track_id: track_id,
                spotify_id: spotify_id
            );
        }
    }
}
