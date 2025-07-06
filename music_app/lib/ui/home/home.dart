import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/ui/home/viewModel.dart';

import '../discovery/discovery.dart';
import '../settings/settings.dart';
import '../user/user.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MussicHomepage(),
    );
  }
}

class MussicHomepage extends StatefulWidget {
  const MussicHomepage({super.key});

  @override
  State<MussicHomepage> createState() => _MussicHomepageState();
}

class _MussicHomepageState extends State<MussicHomepage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const DiscoveryTab(),
    const acountTab(),
    const settingTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Music App')),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.album),
              label: 'Discovery',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Acounts'),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings),
              label: 'Settings',
            ),
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
  List songs = [];
  late MusicAppViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MusicAppViewModel();
    _viewModel.loadSongs();
    observerData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );//khung suong chinh cua giao dien
  }

  Widget getBody(){
    bool showLoading = songs.isEmpty;
    if(showLoading){
      return getProgressBar();
    }else{
      return getListView();
    }
  }

  //
  Widget getProgressBar() {
    return const Center(
      child: CircularProgressIndicator(),
    ); //hien thi loading
  }

  ListView getListView() {
    return ListView.separated(
      itemBuilder: (context, position){
        return getRow(position);
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey, //mau cua duong ngan cach
          height: 1.0, //chieu cao cua duong ngan cach
          indent: 24.0, //khoang cach tu trai den duong ngan cach
          endIndent: 24.0, //khoang cach tu phai den duong ngan cach
        ); //hien thi duong ngan cach giua cac bai hat
      },
      itemCount: songs.length,
      shrinkWrap: true,

    ); //hien thi danh sach bai hat
  }

  Widget getRow(int position) {
    return Center(
      child: ListTile(
        leading: const Icon(Icons.music_note), //icon cua bai hat
        title: Text(songs[position].title), //tieu de cua bai hat
        subtitle: Text(songs[position].artist), //ten cua ca si
        onTap: () {
          //xu ly su kien khi nguoi dung bam vao bai hat
          print('Selected song: ${songs[position].title}');
        },
      ),
    );
  }

  //lay du dieu trong stream khi tra ve
  void observerData() {
    _viewModel.songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }
}
