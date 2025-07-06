import 'dart:async';

import 'package:music_app/data/repository/repository.dart';

import '../../data/model/song.dart';

class MusicAppViewModel {
  StreamController<List<Song>> songStream = StreamController();
  // This class can be used
  // to manage the state of the music app view.
  void loadSongs(){
    final repository = DefaultRepository();
    repository.loadData().then((songs) {
      if (songs != null) {
        songStream.add(songs);
      } else {
        songStream.addError('Failed to load songs');
      }
    }).catchError((error) {
      songStream.addError('Error: $error');
    });
  }
}