import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:prashant/main.dart';
import 'package:prashant/main_screen.dart';
import 'package:prashant/screens/playback_screen.dart';
import 'package:prashant/theme/neo_theme.dart';
import 'package:prashant/services/auth_provider.dart';
import 'package:prashant/services/home_provider.dart';
import 'package:prashant/services/player_provider.dart';
import 'package:prashant/services/search_provider.dart';
import 'package:prashant/services/library_provider.dart';
import 'package:prashant/services/playlist_provider.dart';
import 'package:prashant/services/profile_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prashant/services/settings_provider.dart';
import 'package:prashant/models/homepage_section.dart';
import 'package:prashant/models/song.dart';
import 'package:prashant/models/playlist.dart';
import 'package:prashant/widgets/playback/bottom_player.dart';

class _TestHomeProvider extends HomeProvider {
  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  List<HomepageSection> get sections {
    const mockSong = Song(
      id: 's1',
      title: 'After Hours',
      artist: 'The Weeknd',
      album: 'After Hours',
      duration: '4:20',
      colors: [Colors.purple, Colors.black],
      artworkSeed: 123,
      audioUrl: 'https://example.com/audio.mp3',
    );
    final mockItem = HomepageItem(
      id: 'item_1',
      referenceType: 'SONG',
      referenceId: 's1',
      order: 1,
      data: mockSong,
    );
    return [
      HomepageSection(
        id: 'sec_1',
        title: 'Recently Played',
        type: SectionType.continueListening,
        order: 1,
        items: [mockItem],
      ),
      HomepageSection(
        id: 'sec_2',
        title: 'Made For You',
        type: SectionType.recommended,
        order: 2,
        items: [mockItem],
      ),
      HomepageSection(
        id: 'sec_3',
        title: 'Now Playing',
        type: SectionType.horizontalList,
        order: 3,
        items: [mockItem],
      ),
    ];
  }

  @override
  Future<void> fetchHomeData() async {}
}

class _TestPlayerProvider extends PlayerProvider {
  Song? _mockCurrentTrack;

  @override
  Song? get currentTrack => _mockCurrentTrack ?? super.currentTrack;

  @override
  bool get isPlaying => _mockCurrentTrack != null;

  @override
  Future<void> playTrack(Song song) async {
    _mockCurrentTrack = song;
    notifyListeners();
  }
}

class _TestLibraryProvider extends LibraryProvider {
  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  List<Song> get likedSongs => [];

  @override
  List<Playlist> get playlists => [];

  @override
  Future<void> fetchLibrary() async {}
}

class _TestProfileProvider extends ProfileProvider {
  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  Future<void> loadProfile() async {}

  @override
  Future<void> refreshProfile() async {}
}

Widget _testApp(Widget home) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider<HomeProvider>(create: (_) => _TestHomeProvider()),
      ChangeNotifierProvider<PlayerProvider>(create: (_) => _TestPlayerProvider()),
      ChangeNotifierProvider(create: (_) => SearchProvider()),
      ChangeNotifierProvider<LibraryProvider>(create: (_) => _TestLibraryProvider()),
      ChangeNotifierProvider(create: (_) => PlaylistProvider()),
      ChangeNotifierProvider<ProfileProvider>(create: (_) => _TestProfileProvider()),
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
    ],
    child: MaterialApp(theme: NeoTheme.theme, home: home),
  );
}

class _MyHttpOverrides extends HttpOverrides {}

void main() {
  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({});
    HttpOverrides.global = _MyHttpOverrides();
  });

  testWidgets('app startup reaches the native login screen', (tester) async {
    await tester.pumpWidget(_testApp(const NeoApp()));
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('desktop home renders the main music sections', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(const MainScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Recently Played'), findsWidgets);
    expect(find.text('Made For You'), findsOneWidget);
    expect(find.text('Now Playing'), findsOneWidget);
  });

  testWidgets('mobile mini player opens the full player', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(const MainScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('After Hours').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byType(BottomPlayer));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(PlaybackScreen), findsOneWidget);
    expect(find.text('Playing from'), findsOneWidget);
    expect(find.text('Liked Songs'), findsOneWidget);
  });
}
