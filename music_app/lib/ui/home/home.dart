import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/home/viewModel.dart';
import '../../data/model/song.dart';
import '../discovery/discovery.dart';
import '../now_playing/playing.dart';
import '../settings/settings.dart';
import '../user/user.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.greenAccent[400],
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        useMaterial3: true,
      ),
      home: const MusicHomepage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MusicHomepage extends StatefulWidget {
  const MusicHomepage({super.key});

  @override
  State<MusicHomepage> createState() => _MusicHomepageState();
}

class _MusicHomepageState extends State<MusicHomepage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const acountTab(),
    const settingTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Music App', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black.withOpacity(0.8),
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Colors.black.withOpacity(0.9),
          activeColor: Colors.greenAccent[400]!,
          inactiveColor: Colors.white54,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.album), label: 'Discovery'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: 'Settings'),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  late MusicAppViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    observerData();
  }

  @override
  void dispose() {
    _viewModel.songStream.close();
    super.dispose();
  }

  void observerData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              const Color(0xFF121212),
            ],
          ),
        ),
        child: SafeArea(
          child: songs.isEmpty ? getProgressBar() : getListView(),
        ),
      ),
    );
  }

  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
      ),
    );
  }

  Widget getListView() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      itemBuilder: (context, position) {
        return getRow(position);
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 8.0);
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  Widget getRow(int position) {
    return _SongItemSection(
      parent: this,
      song: songs[position],
    );
  }

  void showBottowSheet(Song song){

    showModalBottomSheet(context: context, builder: (context) {
      return ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
        child: Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow, color: Colors.greenAccent),
                title: const Text('Play Now', style: TextStyle(color: Colors.white)),
                onTap: () {
                  if (songs.isNotEmpty) {
                    navigate(songs[0]);
                  }
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) {
                      return NowPlaying(
                        playingSong: song,
                        songList: songs,
                      );
                    }),
                  );

                },
              ),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.greenAccent),
                title: const Text('Add to Playlist', style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Add your logic for adding to playlist
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info, color: Colors.greenAccent),
                title: const Text('Song Info', style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Add your logic for showing song info
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );

    });

  }
  void navigate(Song song) {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) {
        return NowPlaying(
          playingSong: song,
          songList: songs,
        );
      }),
    );
    ;
  }
}

class _SongItemSection extends StatelessWidget {
  const _SongItemSection({required this.parent, required this.song});

  final _HomeTabPageState parent;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/images/img.png',
            image: song.image,
            fit: BoxFit.cover,
            width: 60,
            height: 60,
            imageErrorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/img.png',
                fit: BoxFit.cover,
                width: 60,
                height: 60,
              );
            },
          ),
        ),
        title: Text(
          song.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artist,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.white70),
          onPressed: () {
            parent.showBottowSheet(song);
          },
        ),
        onTap: () {
          parent.navigate(song);
        },
      ),
    );
  }
}

