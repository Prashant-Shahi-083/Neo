import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prashant/main.dart';
import 'package:prashant/main_screen.dart';
import 'package:prashant/screens/playback_screen.dart';
import 'package:prashant/theme/neo_theme.dart';

Widget _testApp(Widget home) {
  return MaterialApp(theme: NeoTheme.theme, home: home);
}

void main() {
  testWidgets('app startup reaches the native login screen', (tester) async {
    await tester.pumpWidget(const NeoApp());
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
    await tester.tap(find.text('After Hours').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(PlaybackScreen), findsOneWidget);
    expect(find.text('Playing from'), findsOneWidget);
    expect(find.text('Liked Songs'), findsOneWidget);
  });
}
