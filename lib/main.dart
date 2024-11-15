import 'dart:io';

import 'package:desktop_music_flutter/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // PC上面才设置窗口大小
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      center: true,
      //maximumSize: Size(1280, 720),
      minimumSize: Size(680, 420),
      backgroundColor: Colors.black,
      titleBarStyle: TitleBarStyle.hidden,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        fontFamily: "AvantGardeStd",
        colorScheme: const ColorScheme.dark(
          brightness: Brightness.light,
          // 表面颜色
          surface: Colors.white,
          // 文字颜色
          onSurface: Colors.black,
        ),
        useMaterial3: true,
        sliderTheme: const SliderThemeData(
          trackHeight: 2.5,
          thumbColor: Colors.white,
          activeTrackColor: Colors.black38,
          inactiveTrackColor: Colors.black12,
          overlayColor: Colors.black12,
          overlayShape: RoundSliderOverlayShape(overlayRadius: 6),
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: "AvantGardeStd",
        colorScheme: const ColorScheme.dark(
          brightness: Brightness.dark,
          // 表面颜色
          surface: Colors.black,
          // 文字颜色
          onSurface: Colors.white,
        ),
        useMaterial3: true,
        sliderTheme: const SliderThemeData(
          trackHeight: 2.5,
          thumbColor: Colors.white,
          activeTrackColor: Colors.white54,
          inactiveTrackColor: Colors.white12,
          overlayColor: Colors.white12,
          overlayShape: RoundSliderOverlayShape(overlayRadius: 6),
        ),
      ),
      home: const HomePage(),
    );
  }
}
