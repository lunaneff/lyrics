/* provider.vala
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
    interface IProvider : Object {
        public abstract bool supports_unsynced { get; }
        public abstract bool supports_synced { get; }

        public abstract async string search(TrackInfo info);
        public abstract async ListModel get_unsynced(string id);
        public abstract async ListModel get_synced(string id);
    }
}
