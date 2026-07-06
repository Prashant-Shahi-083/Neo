import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'theme/neo_theme.dart';
import 'services/auth_provider.dart';
import 'services/home_provider.dart';
import 'services/player_provider.dart';
import 'services/search_provider.dart';
import 'services/library_provider.dart';
import 'services/playlist_provider.dart';
import 'services/profile_provider.dart';
import 'services/settings_provider.dart';
import 'package:just_audio_background/just_audio_background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.neo.audio',
    androidNotificationChannelName: 'NEO Audio Playback',
    androidNotificationOngoing: true,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const NeoApp(),
    ),
  );
}

class NeoApp extends StatelessWidget {
  const NeoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NEO',
      theme: NeoTheme.theme,
      home: const SplashScreen(),
    );
  }
}
