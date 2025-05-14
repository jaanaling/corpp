import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:olympus_and_corp/routes/root_navigation_screen.dart';
import 'package:olympus_and_corp/routes/route_value.dart';
import 'package:olympus_and_corp/src/core/utils/animated_button.dart';
import 'package:olympus_and_corp/src/core/utils/app_icon.dart';
import 'package:olympus_and_corp/src/core/utils/size_utils.dart';
import 'package:olympus_and_corp/src/feature/main/bloc/app_bloc.dart';
import 'package:olympus_and_corp/src/feature/main/model/model.dart';
import 'package:go_router/go_router.dart';
import 'package:olympus_and_corp/src/feature/main/presentation/main_screen.dart';

bool isRight = true;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentPhraseIndex = 0;
  String _currentSpeakerId = '';
  String _previousSpeakerId = '';

  void _nextPhrase(DialogueBranch branch) {
    setState(() {
      _previousSpeakerId = _currentSpeakerId;
      _currentPhraseIndex++;
      if (_currentPhraseIndex < branch.phrases.length) {
        _currentSpeakerId = branch.phrases[_currentPhraseIndex].speakerId;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    if (isMusicPlaying) {
      final branch = context.read<DialogueBloc>().state.currentBranch;

      startMusic(
          () => setState(() {}),
          branch!.branchId.contains("C1")
              ? 'episode 1'
              : branch.branchId.contains("C2")
                  ? 'episode 2'
                  : branch.branchId.contains("C3")
                      ? 'episode 3'
                      : branch.branchId.contains("C4")
                          ? 'episode 4'
                          : branch.branchId.contains("Underworld")
                              ? 'episode 5'
                              : 'episode 6',);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DialogueBloc, DialogueState>(
      builder: (context, state) {
        if (state.isLoading || state.currentBranch == null) {
          return Positioned.fill(
            child: AppIcon(
              asset: 'assets/images/Office Corridor.webp',
              height: getHeight(context, percent: 1),
              width: getWidth(context, percent: 1),
              fit: BoxFit.fill,
            ),
          );
        }

        final branch = state.currentBranch!;
        final location = branch.location;
        final currentPhrase = _currentPhraseIndex < branch.phrases.length
            ? branch.phrases[_currentPhraseIndex]
            : null;

        if (_currentPhraseIndex == 0 && currentPhrase != null) {
          _currentSpeakerId = currentPhrase.speakerId;
        }

        final shouldAnimate = _currentSpeakerId != _previousSpeakerId;

        final characterImagePath = _currentSpeakerId == 'NARRATOR'
            ? null
            : 'assets/images/$_currentSpeakerId.webp';

        return Scaffold(
          body: Stack(
            children: [
              Image.asset(
                'assets/images/$location.webp',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              if (characterImagePath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Align(
                    child: AnimatedCharacter(
                      speakerId: _currentSpeakerId,
                      emotionPath: characterImagePath,
                      animate: shouldAnimate,
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DialogueBox(
                      phrase: currentPhrase,
                      choices: branch.choices,
                      textaudio: currentPhrase?.speakerId,
                      state: state,
                      onTap: (DialogueChoice choice) {
                        context
                            .read<DialogueBloc>()
                            .add(OptionChosenEvent(choice));
                        setState(() {
                          _currentPhraseIndex = 0;
                          _previousSpeakerId = '';

                          if (state.currentBranch != null &&
                              state.currentBranch!.phrases.isNotEmpty) {
                            _currentSpeakerId =
                                state.currentBranch!.phrases[0].speakerId;
                          }
                        });
                      },
                      onDialogueTap: () => _nextPhrase(branch),
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
                            () => context.go(RouteValue.home.path),
                          ),
                        ),
                        AnimatedButton(
                          isMenu: true,
                          onPressed: _toggleMusic,
                          child: Image.asset(
                            isMusicPlaying
                                ? 'assets/images/sound on.webp'
                                : 'assets/images/sound off.webp',
                            height: getHeight(context, baseSize: 48),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleMusic() {
    toggleMusic(() => setState(() {}));
  }
}

class AnimatedCharacter extends StatefulWidget {
  final String speakerId;
  final String emotionPath;
  final bool animate; // controls the entrance slide only

  const AnimatedCharacter({
    Key? key,
    required this.speakerId,
    required this.emotionPath,
    required this.animate,
  }) : super(key: key);

  @override
  State<AnimatedCharacter> createState() => _AnimatedCharacterState();
}

class _AnimatedCharacterState extends State<AnimatedCharacter>
    with TickerProviderStateMixin {
  late final AnimationController _slideController; // entrance animation
  late final AnimationController _breathController; // looping breathing

  late final Animation<double> _slide;
  late final Animation<double> _breathScale;

  bool isRight = false; // keep existing flag if you use it elsewhere

  @override
  void initState() {
    super.initState();

    // ───── Entrance slide (plays once per "animate" trigger) ─────
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    final slideCurved = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuint,
      reverseCurve: Curves.easeInCirc,
    );

    _slide = Tween<double>(begin: 200, end: 0).animate(slideCurved);

    if (widget.animate) {
      _slideController.forward();
    } else {
      _slideController.value = 1.0;
    }

    // ───── Breathing loop (always running) ─────
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    final breathCurved = CurvedAnimation(
      parent: _breathController,
      curve: Curves.easeInOut,
    );

    _breathScale =
        Tween<double>(begin: 0.988, end: 1.012).animate(breathCurved);
  }

  @override
  void didUpdateWidget(covariant AnimatedCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart entrance slide only when the speaker changes
    if (oldWidget.speakerId != widget.speakerId) {
      if (widget.animate) {
        _slideController
          ..reset()
          ..forward();
      } else {
        _slideController.value = 1.0;
      }
    }
    isRight = !isRight;
  }

  @override
  void dispose() {
    _slideController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _slideController,
        _breathController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slide.value),
          child: Transform.scale(
            scale: _breathScale.value,
            child: child,
          ),
        );
      },
      child: _buildImage(context),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Image.asset(
      widget.emotionPath,
      height: getHeight(context, percent: 0.65),
      fit: BoxFit.fitHeight,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/images/${widget.speakerId}.webp',
        height: getHeight(context, percent: 0.65),
        fit: BoxFit.fitHeight,
      ),
    );
  }
}

class DialogueBox extends StatefulWidget {
  final DialoguePhrase? phrase;
  final List<DialogueChoice> choices;
  final VoidCallback onDialogueTap;
  final Function(DialogueChoice) onTap;
  final DialogueState state;
  final String? textaudio;

  const DialogueBox({
    super.key,
    required this.phrase,
    required this.choices,
    required this.onDialogueTap,
    required this.textaudio,
    required this.state,
    required this.onTap,
  });

  @override
  State<DialogueBox> createState() => _DialogueBoxState();
}

class _DialogueBoxState extends State<DialogueBox> {
  final AudioPlayer _audioPlayer = AudioPlayer()
    ..setAudioContext(
      AudioContextConfig(
        focus: AudioContextConfigFocus.duckOthers,
      ).build(),
    );
  bool _isNarratorSpeaking = false;
  final ScrollController _scrollController = ScrollController();
  int _visibleTextLength = 0;

  bool _isTextFullyVisible = false;
  Timer? _textTimer;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setVolume(0.3);
    _startTextAnimation();
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    _stopAudio();
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _playAudio(
    String asset, {
    bool loop = false,
    double volume = 0.3,
  }) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer
          .setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.play(AssetSource(asset));
    } catch (_) {}
  }

  Future<void> _startNarratorAudio() async {
    if (_isNarratorSpeaking) return;
    _isNarratorSpeaking = true;
    await _playAudio('audio/sound.mp3', volume: 0.2);
  }

  Future<void> _stopNarratorAudio() async {

    _isNarratorSpeaking = false;
    await _audioPlayer.stop();
  }

  Future<void> _playCharacterAudio() async {
    if (widget.textaudio == null) return;
    if (_visibleTextLength != 0) return;
    await _stopNarratorAudio();
    await _playAudio('audio/sound.mp3');
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    _isNarratorSpeaking = false;
  }

  void _startTextAnimation() {
    if (widget.phrase == null || _isTextFullyVisible) return;

    _textTimer?.cancel();
    _textTimer = Timer(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      if (widget.phrase != null &&
          _visibleTextLength < widget.phrase!.text.length) {
        setState(() => _visibleTextLength++);
        _startTextAnimation();
      } else {
        setState(() => _isTextFullyVisible = true);
      }
    });
  }

  void _showFullText() {
    _textTimer?.cancel();
    if (!mounted || widget.phrase == null) return;
    setState(() {
      _visibleTextLength = widget.phrase!.text.length;
      _isTextFullyVisible = true;
    });
  }

  @override
  void didUpdateWidget(covariant DialogueBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.phrase != oldWidget.phrase) {
      _textTimer?.cancel();
      _visibleTextLength = 0;
      _isTextFullyVisible = false;
      _startTextAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final phrase = widget.phrase;
    final isNarrator = phrase?.speakerId == 'NARRATOR';

    if (!_isTextFullyVisible && isMusicPlaying) {
      if (isNarrator) {
        _startNarratorAudio();
      } else {
        _playCharacterAudio();
      }
    }

    final speakerColor = _speakerColor(phrase?.speakerId);

    return PopScope(
      onPopInvoked: (_) => _stopNarratorAudio(),
      child: SizedBox(
        width: getWidth(context, percent: 1),
        height: getHeight(context, percent: 0.4),
        child: GestureDetector(
          onTap: () {  _stopNarratorAudio();
            if (!_isTextFullyVisible && phrase != null) {
              _showFullText();
            
            } else {
              widget.onDialogueTap();
              setState(() {
                _isTextFullyVisible = false;
                _visibleTextLength = 0;
              });
              _startTextAnimation();
            }
          },
          child: _buildFrame(context, speakerColor),
        ),
      ),
    );
  }

  Widget _buildFrame(BuildContext context, Color speakerColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/dialog.webp'),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: (widget.phrase?.speakerId != 'NARRATOR')
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          if (widget.phrase != null)
            Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.phrase!.speakerId != 'NARRATOR')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.phrase!.speakerId,
                              style: TextStyle(
                                color: speakerColor,
                                fontSize: 28,
                                fontFamily: 'KZ',
                              ),
                            ),
                          ],
                        ),
                      const Gap(8),
                      Center(
                        child: Text(
                          widget.phrase!.text.substring(0, _visibleTextLength),
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: 'KZ',
                            color: Color(0xFF7B2500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (widget.phrase == null && widget.choices.isNotEmpty)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...widget.choices.map(_choiceButton),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _choiceButton(DialogueChoice choice) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AnimatedButton(
          onPressed: () {
            widget.onTap(choice);
            setState(() {
              _visibleTextLength = 0;
              _isTextFullyVisible = false;
            });
            _startTextAnimation();
          },
          child: Container(
            width: double.infinity,
            height: 90,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
            margin: EdgeInsets.symmetric(horizontal: 30),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/choose.webp'),
                fit: BoxFit.fill,
              ),
            ),
            child: Text(
              choice.choiceText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'KZ',
                color: Color(0xFFFFBB00),
              ),
            ),
          ),
        ),
      );

  Color _speakerColor(String? id) {
    switch (id) {
      case 'Hephaestus':
        return const Color.fromARGB(255, 77, 54, 6);
      case 'Dionysus':
        return Colors.purple;
      case 'Artemis':
        return Colors.blue;
      case 'Apollo':
        return const Color.fromARGB(255, 153, 92, 0);
      case 'Aphrodite':
        return const Color.fromARGB(255, 255, 0, 179);
      case 'Athena':
        return const Color.fromARGB(255, 0, 156, 184);
      case 'Demeter':
        return const Color.fromARGB(255, 88, 151, 15);
      case 'Hades':
        return const Color.fromARGB(255, 78, 2, 2);
      case 'Hera':
        return const Color.fromARGB(255, 128, 126, 124);
      case 'Hermes':
        return const Color.fromARGB(255, 114, 151, 11);
      case 'Hestia':
        return const Color.fromARGB(255, 182, 92, 32);
      case 'Persephone':
        return const Color.fromARGB(255, 42, 73, 0);
      case 'Poseidon':
        return const Color.fromARGB(255, 19, 145, 113);
      case 'Zeus':
        return const Color.fromARGB(255, 138, 136, 54);
      case 'Ares':
        return const Color.fromARGB(255, 182, 31, 26);
      case 'NARRATOR':
        return Colors.grey.shade300;
      default:
        return Colors.white;
    }
  }
}
