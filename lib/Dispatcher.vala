/*
 * Copyright (c) 2021 Manexim (https://github.com/manexim)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
 */

public class Flux.Dispatcher : GLib.Object {
    private static GLib.Once<Dispatcher> instance;

    private GLib.List<Flux.Middleware> middlewares;
    private GLib.List<Flux.Store> stores;
    private GLib.Queue<Flux.Action> actions;
    private GLib.Mutex mutex;

    private signal void new_action_added ();

    private Dispatcher () {
        middlewares = new GLib.List<Flux.Middleware> ();
        stores = new GLib.List<Flux.Store> ();
        actions = new GLib.Queue<Flux.Action> ();
        mutex = GLib.Mutex ();

        new_action_added.connect (on_new_action_added);
    }

    public static unowned Dispatcher get_instance () {
        return instance.once (() => {
            return new Dispatcher ();
        });
    }

    public void dispatch (Flux.Action action) {
        new GLib.MutexLocker (mutex);
        actions.push_tail (action);

        new_action_added ();
    }

    public void register_middleware (Flux.Middleware middleware) {
        middlewares.append (middleware);
    }

    public void register_store (Flux.Store store) {
        stores.append (store);
    }

    private void on_new_action_added () {
        mutex.lock ();

        Flux.Action action = null;
        while ((action = actions.pop_head ()) != null) {
            mutex.unlock ();

            middlewares.foreach ((middleware) => {
                middleware.process (action);
            });

            stores.foreach ((store) => {
                store.process (action);
            });

            mutex.lock ();
        }

        mutex.unlock ();
    }
}
