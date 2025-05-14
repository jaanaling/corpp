// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:olympus_and_corp/src/core/utils/json_loader.dart';

class DialoguePhrase {
  final String speakerId; // Кто говорит (ID персонажа)
  final String text; // Текст фразы

  DialoguePhrase({
    required this.speakerId,
    required this.text,

  });

  DialoguePhrase copyWith({
    String? speakerId,
    String? text,
    String? emotion,
  }) {
    return DialoguePhrase(
      speakerId: speakerId ?? this.speakerId,
      text: text ?? this.text,

    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'speakerId': speakerId,
      'text': text,

    };
  }

  factory DialoguePhrase.fromMap(Map<String, dynamic> map) {
    return DialoguePhrase(
      speakerId: map['speakerId'] as String,
      text: map['text'] as String,

    );
  }

  String toJson() => json.encode(toMap());

  factory DialoguePhrase.fromJson(String source) =>
      DialoguePhrase.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'DialoguePhrase(speakerId: $speakerId, text: $text)';

  @override
  bool operator ==(covariant DialoguePhrase other) {
    if (identical(this, other)) return true;

    return other.speakerId == speakerId &&
        other.text == text ;
  }

  @override
  int get hashCode => speakerId.hashCode ^ text.hashCode;
}

/// Вариант выбора в конце диалога
class DialogueChoice {
  final String choiceText; // Текст выбора
  final String nextDialogueBranchId;
  DialogueChoice({
    required this.choiceText,
    required this.nextDialogueBranchId,
  });

  DialogueChoice copyWith({
    String? choiceText,
    String? nextDialogueBranchId,
  }) {
    return DialogueChoice(
      choiceText: choiceText ?? this.choiceText,
      nextDialogueBranchId: nextDialogueBranchId ?? this.nextDialogueBranchId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'choiceText': choiceText,
      'nextDialogueBranchId': nextDialogueBranchId,
    };
  }

  factory DialogueChoice.fromMap(Map<String, dynamic> map) {
    return DialogueChoice(
      choiceText: map['choiceText'] as String,
      nextDialogueBranchId: map['nextDialogueBranchId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DialogueChoice.fromJson(String source) =>
      DialogueChoice.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'DialogueChoice(choiceText: $choiceText, nextDialogueBranchId: $nextDialogueBranchId)';

  @override
  bool operator ==(covariant DialogueChoice other) {
    if (identical(this, other)) return true;

    return other.choiceText == choiceText &&
        other.nextDialogueBranchId == nextDialogueBranchId;
  }

  @override
  int get hashCode => choiceText.hashCode ^ nextDialogueBranchId.hashCode;
}

/// Диалоговая ветка (серия реплик + выборы в конце)
class DialogueBranch {
  final String branchId; // Уникальный ID ветки
  final String location; // Текущая локация

  final List<DialoguePhrase> phrases; // Реплики в порядке отображения
  final List<DialogueChoice> choices; // Варианты выбора в конце ветки

  DialogueBranch({
    required this.branchId,
    required this.location,
    required this.phrases,
    required this.choices,
  });

  DialogueBranch copyWith({
    String? branchId,
    String? location,
    List<DialoguePhrase>? phrases,
    List<DialogueChoice>? choices,
  }) {
    return DialogueBranch(
      branchId: branchId ?? this.branchId,
      location: location ?? this.location,
      phrases: phrases ?? this.phrases,
      choices: choices ?? this.choices,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'branchId': branchId,
      'location': location,
      'phrases': phrases.map((x) => x.toMap()).toList(),
      'choices': choices.map((x) => x.toMap()).toList(),
    };
  }

  factory DialogueBranch.fromMap(Map<String, dynamic> map) {
    return DialogueBranch(
      branchId: map['branchId'] as String,
      location: map['location'] as String,
      phrases: List<DialoguePhrase>.from(
        (map['phrases'] as List<dynamic>).map<DialoguePhrase>(
          (x) => DialoguePhrase.fromMap(x as Map<String, dynamic>),
        ),
      ),
      choices: List<DialogueChoice>.from(
        (map['choices'] as List<dynamic>).map<DialogueChoice>(
          (x) => DialogueChoice.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory DialogueBranch.fromJson(String source) =>
      DialogueBranch.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DialogueBranch(branchId: $branchId, location: $location phrases: $phrases, choices: $choices)';
  }

  @override
  bool operator ==(covariant DialogueBranch other) {
    if (identical(this, other)) return true;

    return other.branchId == branchId &&
        other.location == location &&
        listEquals(other.phrases, phrases) &&
        listEquals(other.choices, choices);
  }

  @override
  int get hashCode {
    return branchId.hashCode ^
        location.hashCode ^
        phrases.hashCode ^
        choices.hashCode;
  }
}

/// Обновлённое состояние игры (для хранения текущей ветки)
class GameState {
  String currentDialogueBranchId; // Текущая диалоговая ветка

  GameState({
    required this.currentDialogueBranchId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currentDialogueBranchId': currentDialogueBranchId,
    };
  }

  factory GameState.fromMap(Map<String, dynamic> map) {
    return GameState(
      currentDialogueBranchId: map['currentDialogueBranchId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GameState.fromJson(String source) =>
      GameState.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant GameState other) {
    if (identical(this, other)) return true;

    return other.currentDialogueBranchId == currentDialogueBranchId;
  }

  @override
  int get hashCode => currentDialogueBranchId.hashCode;

  GameState copyWith({
    String? currentDialogueBranchId,
  }) {
    return GameState(
        currentDialogueBranchId:
            currentDialogueBranchId ?? this.currentDialogueBranchId);
  }

  @override
  String toString() =>
      'GameState(currentDialogueBranchId: $currentDialogueBranchId)';
}

/// Методы для управления диалогами и выборами
class DialogueManager {
  final List<DialogueBranch> dialogueBranches; // Все диалоговые ветки
  GameState gameState;

  DialogueManager({
    required this.dialogueBranches,
    required this.gameState,
  });

  /// Получить текущую диалоговую ветку
  String? get currentBranch {
    return dialogueBranches.isNotEmpty
        ? gameState.currentDialogueBranchId != ""
            ? gameState.currentDialogueBranchId
            : "C1B1"
        : null;
  }

  /// Сделать выбор и перейти к следующей ветке
  void makeChoice(DialogueChoice choice) {
    gameState.currentDialogueBranchId = choice.nextDialogueBranchId;
  }

  /// Сохранить состояние игры
  Future<void> saveGame(SharedPreferences prefs) async {
    // ⬇️ заменяем jsonEncode(gameState)
    await prefs.setString('gameState', gameState.toJson());
  }

  /// Загрузить состояние игры
  Future<void> loadGame(SharedPreferences prefs) async {
    final data1 = await JsonLoader.loadData<DialogueBranch>(
      "plot",
      'assets/json/plot.json',
      (json) => DialogueBranch.fromMap(json),
    );

    final data = prefs.getString('gameState');
    dialogueBranches.addAll(data1);

    if (data != null) {
      gameState = GameState.fromJson(data); // ← без jsonDecode
    }
  }

  /// Начать новую игру
}
