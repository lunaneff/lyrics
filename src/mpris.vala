/* mpris.vala
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
    [DBus (name = "org.mpris.MediaPlayer2.Player")]
    interface Mpris : DBusProxy {
        public abstract string playback_status { owned get; }
        public abstract int64 position { owned get; }
        public abstract HashTable<string, Variant> metadata { owned get; }

        public abstract void play_pause() throws GLib.Error;

        public string title {
            get {
                return this.metadata.get("xesam:title").get_string();
            }
        }

        public uint64 length {
            get {
                return this.metadata.get("mpris:length").get_uint64();
            }
        }

        public string[] artists {
            owned get {
                return this.metadata.get("xesam:artist").get_strv();
            }
        }

        public static async Mpris get(string dbus_name) {
            return yield Bus.get_proxy (BusType.SESSION, dbus_name, "/org/mpris/MediaPlayer2");
        }

        public static async string[] discover() throws IOError, Error {
            var conn = yield Bus.get(SESSION);
            var services = conn.call_sync(
                "org.freedesktop.DBus",
                "/org/freedesktop/DBus",
                "org.freedesktop.DBus",
                "ListNames",
                null,
                new VariantType.tuple({VariantType.STRING_ARRAY}),
                NONE,
                -1
            ).get_child_value(0).get_strv();

            // We temporarily use a linked list to filter the array
            var filtered = new List<string>();

            foreach(var service in services) {
                if(service.contains("org.mpris.MediaPlayer2")) {
                    filtered.append(service);
                }
            }

            var as_array = new string[filtered.length()];
            for(var i = 0; i < as_array.length; i++) {
                as_array[i] = filtered.nth_data(i);
            }

            return as_array;
        }
    }
}
