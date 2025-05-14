import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:olympus_and_corp/src/feature/main/model/model.dart';

abstract class DialogueEvent extends Equatable {
  const DialogueEvent();

  @override
  List<Object?> get props => [];
}

class LoadGameEvent extends DialogueEvent {}

class OptionChosenEvent extends DialogueEvent {
  final DialogueChoice choice;
  const OptionChosenEvent(this.choice);

  @override
  List<Object?> get props => [choice];
}

class MarkEncounterEvent extends DialogueEvent {
  final String characterId;
  const MarkEncounterEvent(this.characterId);

  @override
  List<Object?> get props => [characterId];
}

class EpisodeChosenEvent extends DialogueEvent {
  final String episodeId;
  const EpisodeChosenEvent(this.episodeId);

  @override
  List<Object?> get props => [episodeId];
}


class StartNewGameEvent extends DialogueEvent {}

class DialogueState extends Equatable {
  final GameState gameState;
  final DialogueBranch? currentBranch;
  final bool isLoading;
  final bool hasError;

  const DialogueState({
    required this.gameState,
    required this.currentBranch,
    this.isLoading = false,
    this.hasError = false,
  });

  DialogueState copyWith({
    GameState? gameState,
    DialogueBranch? currentBranch,
    bool? isLoading,
    bool? hasError,
  }) {
    return DialogueState(
      gameState: gameState ?? this.gameState,
      currentBranch: currentBranch ?? this.currentBranch,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object?> get props => [gameState, currentBranch, isLoading, hasError];
}

class DialogueBloc extends Bloc<DialogueEvent, DialogueState> {
  final DialogueManager dialogueManager;

  DialogueBloc({
    required this.dialogueManager,
  }) : super(
          DialogueState(
            gameState: dialogueManager.gameState,
            currentBranch: null,
          ),
        ) {
    on<LoadGameEvent>(_onLoadGame);
    on<StartNewGameEvent>(_onStartNewGame);
    on<OptionChosenEvent>(_onOptionChosen);
    on<EpisodeChosenEvent>(_onEpisodeChosenEvent);
  }

  Future<void> _onEpisodeChosenEvent(
    EpisodeChosenEvent event,
    Emitter<DialogueState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('gameState');
      await dialogueManager.loadGame(prefs);

      dialogueManager.gameState = GameState(
        currentDialogueBranchId: event.episodeId,
      );

      emit(
        state.copyWith(
          gameState: dialogueManager.gameState,
          currentBranch: dialogueManager.dialogueBranches.firstWhere(
            (element) => element.branchId == dialogueManager.currentBranch,
          ),
          isLoading: false,
          hasError: false,
        ),
      );
    } catch (e) {
      debugPrint('Ошибка при выборе эпизода: $e');
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }
  

  Future<void> _onStartNewGame(
    StartNewGameEvent event,
    Emitter<DialogueState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('gameState');
      await dialogueManager.loadGame(prefs);

      dialogueManager.gameState = GameState(
        currentDialogueBranchId: "C1B1",
      );

      emit(
        state.copyWith(
          gameState: dialogueManager.gameState,
          currentBranch: dialogueManager.dialogueBranches.firstWhere(
            (element) => element.branchId == dialogueManager.currentBranch,
          ),
          isLoading: false,
          hasError: false,
        ),
      );
    } catch (e) {
      debugPrint('Ошибка при начале новой игры: $e');
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  Future<void> _onLoadGame(
    LoadGameEvent event,
    Emitter<DialogueState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final prefs = await SharedPreferences.getInstance();
      await dialogueManager.loadGame(prefs);

      if (dialogueManager.currentBranch == null) {
        dialogueManager.makeChoice(
          DialogueChoice(choiceText: "", nextDialogueBranchId: "C1B1"),
        );
      }

      emit(
        state.copyWith(
          gameState: dialogueManager.gameState,
          currentBranch: dialogueManager.dialogueBranches.firstWhere(
            (element) => element.branchId == dialogueManager.currentBranch,
          ),
          isLoading: false,
          hasError: false,
        ),
      );
    } catch (e) {
      debugPrint('Ошибка при загрузке игры: $e');
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  Future<void> _onOptionChosen(
    OptionChosenEvent event,
    Emitter<DialogueState> emit,
  ) async {
    dialogueManager.makeChoice(event.choice);

    final prefs = await SharedPreferences.getInstance();
    await dialogueManager.saveGame(prefs);

    emit(
      state.copyWith(
        gameState: dialogueManager.gameState,
        currentBranch: dialogueManager.dialogueBranches.firstWhere(
          (element) => element.branchId == dialogueManager.currentBranch,
        ),
        hasError: false,
      ),
    );
  }
}
