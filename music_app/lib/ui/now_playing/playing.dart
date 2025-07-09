import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/model/song.dart';
import 'audio_manager.dart';

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
    return NowPlayingPage(playingSong: playingSong, songList: songList);
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

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  late final AudioPlayerManager _audioManager;

  @override
  void initState() {
    super.initState();
    _audioManager = AudioPlayerManager(songUrl: widget.playingSong.source);
    _audioManager.init();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double imageSize = 300.0;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.black,
        middle: Text(
          widget.playingSong.title,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.white),
          onPressed: () {},
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),

              /// Ảnh bài hát
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/img.png',
                    image: widget.playingSong.image,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/img.png',
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// Thông tin bài hát và nút yêu thích
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.playingSong.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.playingSong.artist,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.redAccent : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildProgressBar(),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _mediaButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MediaControlButtons(
            function: () {},
            icon: const Icon(Icons.shuffle_sharp),
            color: Colors.white,
            size: 20.0,
          ),
          // Previous, Play/Pause, Next buttons
          MediaControlButtons(
            function: () {
              // Handle previous song action
            },
            icon: const Icon(Icons.skip_previous_sharp),
            color: Colors.white,
            size: 40.0,
          ),
          // MediaControlButtons(
          //   function: () {
          //     // Handle play/pause action
          //   },
          //   icon: const Icon(Icons.play_circle_fill),
          //   color: Colors.white,
          //   size: 80.0,
          // ),
          _playButton(),
          MediaControlButtons(
            function: () {
              // Handle next song action
            },
            icon: const Icon(Icons.skip_next_sharp),
            color: Colors.white,
            size: 40.0,
          ),
          MediaControlButtons(
            function: () {},
            icon: const Icon(Icons.repeat),
            color: Colors.white,
            size: 20.0,
          ),
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _buildProgressBar() {
    return StreamBuilder<DurationState>(
      stream: _audioManager.durationSate,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;

        return ProgressBar(
          progress: progress,
          buffered: buffered,
          total: total,
          timeLabelTextStyle: const TextStyle(color: Colors.white),
          thumbColor: Colors.white,
          baseBarColor: Colors.white30,
          progressBarColor: Colors.white,
          bufferedBarColor: Colors.white60,
        );
      },
    );
  }

  StreamBuilder<PlayerState> _playButton(){
      return StreamBuilder<PlayerState>(
        stream: _audioManager.player.playerStateStream,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          final playing = playerState?.playing ?? false;
          final processingState = playerState?.processingState;
          // Check if the player is playing
          if(processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
            return Container(
              margin: const EdgeInsets.all(16.0),
              width: 48,
              height: 48,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
            );
          }else if(playing != true){
            return IconButton(
              icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 80.0),
              onPressed: () {
                _audioManager.player.play();
              },
            );
          } else if(processingState != ProcessingState.completed) {
            return IconButton(
              icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 80.0),
              onPressed: () {
                _audioManager.player.pause();
              },
            );
          } else {
            return MediaControlButtons(
                function: () {
                  _audioManager.player.seek(Duration.zero);
                },
                icon: const Icon(Icons.replay),
                color: null,
                size: 48.0,
            );
          }
        },
      );
  }
}





class MediaControlButtons extends StatefulWidget {
  const MediaControlButtons({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  final void Function()? function;
  final Icon icon;
  final Color? color;
  final double? size;

  @override
  State<StatefulWidget> createState() => _MediaControlButtonsState();
}

class _MediaControlButtonsState extends State<MediaControlButtons> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(
        widget.icon.icon,
        color: widget.color ?? Theme.of(context).colorScheme.primary,
        size: widget.size ?? 30.0,
      ),
    );
  }
}
