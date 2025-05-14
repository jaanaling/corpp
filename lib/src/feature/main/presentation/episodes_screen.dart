import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:olympus_and_corp/routes/route_value.dart';
import 'package:olympus_and_corp/src/core/utils/animated_button.dart';
import 'package:olympus_and_corp/src/core/utils/app_icon.dart';
import 'package:olympus_and_corp/src/core/utils/size_utils.dart';
import 'package:olympus_and_corp/src/feature/main/bloc/app_bloc.dart';
import 'package:olympus_and_corp/src/feature/main/presentation/main_screen.dart';

class EpisodesScreen extends StatelessWidget {
  const EpisodesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.8),
              BlendMode.darken,
            ),
            child: AppIcon(
              asset: "assets/images/Office Corridor.webp",
              height: getHeight(context, percent: 1),
              width: getWidth(context, percent: 1),
              fit: BoxFit.fill,
            ),
          ),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: getHeight(context, percent: 0.1),
          ),
          child: Column(
            spacing: 18,
            children: [
              episodes(
                index: 1,
                episode: "C1B1",
                name: "Team building",
              ),
              episodes(
                index: 2,
                episode: "C2B1",
                name: "Rebranding",
              ),
              episodes(
                index: 3,
                episode: "C3B1",
                name: "The disappeared",
              ),
              episodes(
                index: 4,
                episode: "C4B1",
                name: "Corporate War",
              ),
              episodes(
                index: 5,
                episode: "UnderworldB1",
                name: "The Underdark",
              ),
              episodes(
                index: 6,
                episode: "AquariumB1",
                name: "Fishy commotion",
              ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Align(
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 100,
                    child: buildButton(
                      context,
                      'assets/images/menu.webp',
                      () => context.pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class episodes extends StatelessWidget {
  final int index;
  final String episode;
  final String name;
  const episodes({
    super.key,
    required this.index,
    required this.episode,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
        child: Stack(
          children: [
            AppIcon(
              asset: "assets/images/episode $index.webp",
              width: getWidth(context, percent: 0.6),
            ),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: SizedBox(
                width: getWidth(context, percent: 0.1),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'KZ',
                    color: Color(0xFFFFBB00),
                  ),
                ),
              ),
            ),
          ],
        ),
        onPressed: () {
          context.read<DialogueBloc>().add(EpisodeChosenEvent(episode));
          context.push(
            '${RouteValue.home.path}/${RouteValue.game.path}',
          );
        });
  }
}
