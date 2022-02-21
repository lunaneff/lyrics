lyrics_sources = [
  'main.vala',
  'window.vala',
  'application.vala',
  'mpris.vala',
  'lyric.vala',
  'trackinfo.vala',
  'provider/provider.vala',
  'provider/genius.vala',
  'provider/musixmatch.vala',
]

lyrics_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1'),
  dependency('libsoup-2.4'),
  dependency('json-glib-1.0'),
]

gnome = import('gnome')

lyrics_sources += gnome.compile_resources('lyrics-resources',
  'lyrics.gresource.xml',
  c_name: 'lyrics'
)

executable('ch.laurinneff.Lyrics', lyrics_sources,
  vala_args: '--target-glib=2.50',  dependencies: lyrics_deps,
  install: true,
)
