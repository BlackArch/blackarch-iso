/*
 * Copyright (C) 2012 Canonical Ltd.
 *
 * Author: Jens Georg <jensg@openismus.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA
 *
 */

#include <grilo.h>
#include <stdio.h>

/**
 * This TMDB key is just for testing.
 * For real-world use, please request your own key from
 * http://api.themoviedb.org
 */
#define TMDB_KEY "719b9b296835b04cd919c4bf5220828a"

#define TMDB_PLUGIN_ID "grl-tmdb"

GMainLoop *loop = NULL;
GrlKeyID director_key = 0;

static void
resolve_cb (GrlSource *src, guint operation_id, GrlMedia *media, gpointer user_data, const GError *error)
{
  g_assert_no_error (error);
  g_assert (media);

  const gchar *title = grl_media_get_title (media);
  const gchar *studio = grl_media_get_studio (media);
  printf ("Media: Title='%s', Studio='%s'\n",
    title, studio);

  if (director_key != 0) {
    const gchar *director =
      grl_data_get_string (GRL_DATA (media), director_key);
    printf ("  Director=%s\n", director);
  }

  g_main_loop_quit (loop);
}

int main (int argc, char *argv[])
{
#if !GLIB_CHECK_VERSION(2,35,0)
  g_type_init ();
#endif

  grl_init (&argc, &argv);

  /*
   * Set the TMDB API key:
   * You must use your own TMDB API key in your own application.
   */
  GrlRegistry *reg = grl_registry_get_default ();
  GrlConfig *config = grl_config_new (TMDB_PLUGIN_ID, NULL);
  grl_config_set_api_key (config, TMDB_KEY);
  grl_registry_add_config (reg, config, NULL);

  /*
   * Get the plugin:
   */
  GError *error = NULL;
  gboolean plugin_loaded =
    grl_registry_load_plugin_by_id (reg, TMDB_PLUGIN_ID, &error);
  g_assert (plugin_loaded);
  g_assert_no_error (error);

  /*
   * Get the Grilo source:
   */
  GrlSource *src =
    grl_registry_lookup_source (reg, TMDB_PLUGIN_ID);

  /*
   * Check that it has the expected capability:
   */
  g_assert (grl_source_supported_operations (src) & GRL_OP_RESOLVE);
  GrlCaps *caps = grl_source_get_caps (src, GRL_OP_RESOLVE);
  g_assert (caps);

  GrlOperationOptions *options = grl_operation_options_new (caps);

  /*
   * A media item that we will give to the TMDB plugin,
   * to discover its details.
   */
  GrlMedia *media = grl_media_video_new ();
  grl_media_set_title (media, "Sherlock Holmes");

  /*
   * Discover what keys are provided by the source:
   */
  const GList *keys = grl_source_supported_keys (src);
  const GList* l = NULL;
  for (l = keys; l != NULL; l = l->next) {
    GrlKeyID id = GPOINTER_TO_INT (l->data);
    g_assert (id);

    const gchar *name = grl_metadata_key_get_name (id);
    printf ("Supported key: %s\n", name);

    /*
     * Remember this for later use:
     * You may instead use grl_registry_lookup_metadata_key_name().
     */
    if (g_strcmp0 (name, "tmdb-director") == 0) {
      director_key = id;
    }
  }

  /*
   * Ask the TMDB plugin for the media item's details,
   * from the TMDB online service:
   */
  grl_source_resolve (src, media,
    keys, options,
    resolve_cb, NULL);

  /*
   * Start the main loop so our callback can be called:
   */
  loop = g_main_loop_new (NULL, FALSE);
  g_main_loop_run (loop);

  /*
   * Release objects:
   */
  g_object_unref (media);
  g_object_unref (config);
  g_object_unref (options);
}


