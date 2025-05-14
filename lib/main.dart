import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'src/feature/app/presentation/app_root.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  AudioPlayer.global.setAudioContext(
  AudioContextConfig(
    // Все плееры по умолчанию будут уме­ть микшироваться
    focus: AudioContextConfigFocus.mixWithOthers,
    stayAwake: true,
  ).build(),
);

  runApp(const AppRoot());
}
