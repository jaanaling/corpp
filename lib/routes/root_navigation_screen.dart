import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootNavigationScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const RootNavigationScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  State<RootNavigationScreen> createState() => _RootNavigationScreenState();
}

class _RootNavigationScreenState extends State<RootNavigationScreen> {
  @override
  void initState() {
    super.initState();

    startMusic(() => setState(() {}), 'episode 1');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      child: widget.navigationShell,
    );
  }
}

bool isMusicPlaying = true;
final AudioPlayer audioPlayer = AudioPlayer();
Future<void> startMusic(VoidCallback setState, String music) async {
  if (isMusicPlaying) {
    await audioPlayer.setAudioContext(
      AudioContextConfig(
        focus: AudioContextConfigFocus.mixWithOthers,
      ).build(),
    );
    await audioPlayer.play(AssetSource('audio/$music.mp3'));

   // isMusicPlaying = true;
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    audioPlayer.setVolume(0.2);

    setState();
  }
}

Future<void> toggleMusic(VoidCallback setState) async {
  if (isMusicPlaying) {
    await audioPlayer.pause();
  } else {
    await audioPlayer.resume();
  }

  isMusicPlaying = !isMusicPlaying;
  setState();
}
