import 'package:flutter/material.dart';

import '../../data/model/song.dart';

class NowPlaying extends StatelessWidget {
  const NowPlaying({
    super.key,
    required this.playingSong,
    required this.songList,
  });
  final Song playingSong;
  final List<Song> songList;
  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(
      playingSong: playingSong,
      songList: songList,
    );
  }
  
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({
    super.key,
    required this.playingSong,
    required this.songList,
  });
  final Song playingSong;
  final List<Song> songList;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Now Playing: ${widget.playingSong.title}"),
      ),

    );
  }
}
