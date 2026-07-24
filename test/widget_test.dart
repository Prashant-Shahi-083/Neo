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
import 'package:prashant/services/settings_provider.dart';

Widget _testApp(Widget home) {
  return MultiProvider(
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
    child: MaterialApp(theme: NeoTheme.theme, home: home),
  );
}

class _MyHttpOverrides extends HttpOverrides {}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MyHttpOverrides();
  });

  testWidgets('app startup reaches the native login screen', (tester) async {
    await tester.pumpWidget(_testApp(const NeoApp()));
    await tester.pumpAndSettle(const Duration(milliseconds: 3000));

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
    await tester.pumpAndSettle();
    await tester.tap(find.text('After Hours').last);
    await tester.pumpAndSettle();

    expect(find.byType(PlaybackScreen), findsOneWidget);
    expect(find.text('Playing from'), findsOneWidget);
    expect(find.text('Liked Songs'), findsOneWidget);
  });
}
