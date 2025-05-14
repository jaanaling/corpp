import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:olympus_and_corp/routes/root_navigation_screen.dart';
import 'package:olympus_and_corp/routes/route_value.dart';
import 'package:olympus_and_corp/src/core/utils/animated_button.dart';
import 'package:olympus_and_corp/src/core/utils/size_utils.dart';
import 'package:olympus_and_corp/src/feature/main/bloc/app_bloc.dart';

import '../../../core/utils/app_icon.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void _toggleMusic() {
    toggleMusic(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AppIcon(
            asset: 'assets/images/Zeus’ Office.webp',
            height: getHeight(context, percent: 1),
            width: getWidth(context, percent: 1),
            fit: BoxFit.fill,
          ),
        ),
        Center(
          child: AppIcon(
            asset: 'assets/images/Zeus.webp',
            width: getWidth(context, percent: 0.9),
          ),
        ),
        Column(
          children: [
            const Spacer(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 44),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedButton(
                    onPressed: () => context.push(
                      '${RouteValue.home.path}/${RouteValue.game.path}',
                    ),
                    isMenu: true,
                    child: Image.asset(
                      'assets/images/continue.webp',
                      fit: BoxFit.fitWidth,
                      width: 240,
                    ),
                  ),
                  Gap(12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildButton(
                        context,
                        'assets/images/new game.webp',
                        () {
                          context.read<DialogueBloc>().add(StartNewGameEvent());
                          context.push(
                              '${RouteValue.home.path}/${RouteValue.game.path}');
                        },
                      ),
                      buildButton(
                        context,
                        'assets/images/episodes.webp',
                        () {
                          context.push(
                              '${RouteValue.home.path}/${RouteValue.chapters.path}');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 25,
          left: 18,
          child: AnimatedButton(
            isMenu: true,
            onPressed: _toggleMusic,
            child: Image.asset(
              isMusicPlaying
                  ? 'assets/images/sound on.webp'
                  : 'assets/images/sound off.webp',
              height: getHeight(context, baseSize: 64),
              fit: BoxFit.fitHeight,
            ),
          ),
        ),
      ],
    );
  }
}

Widget buildButton(
  BuildContext context,
  String imagePath,
  VoidCallback onTap,
) {
  return AnimatedButton(
    onPressed: onTap,
    isMenu: true,
    child: Image.asset(
      imagePath,
      fit: BoxFit.fitWidth,
      width: 180,
    ),
  );
}
