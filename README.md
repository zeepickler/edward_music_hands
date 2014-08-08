Edward Music Hands - Create a song using random samples from your music library

Setup:

- Ensure that ruby and sox is installed.

- Under config/settings.yml:
  - Modify ':music_root_dir:' to the folder path to your music library directory.
  - Modify ':input_file_types:' to your tastes (this filters the files it looks for).  

Run: 
- To create a song, you will need a song title ie. "my_cool_song_title" and choose a song length ie. "1:30".
- Under the repo type 'ruby edward_music_hands.rb my_cool_song_title 1:30".
- By default, it will create the file under project_library. However this can be modified in the config/settings.yml file.

Enjoy! :)
