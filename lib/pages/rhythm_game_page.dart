import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:preharness/routes/app_routes.dart';
import 'package:preharness/widgets/responsive_scaffold.dart';

enum RhythmCommand { pata, pon, chaka, don }

class RhythmGamePage extends StatefulWidget {
  const RhythmGamePage({super.key});

  @override
  State<RhythmGamePage> createState() => _RhythmGamePageState();
}

class _RhythmGamePageState extends State<RhythmGamePage> {
  final List<RhythmCommand> _currentSequence = [];
  String _feedbackMessage = 'Ready?';
  int _score = 0;
  double _characterXPosition = 50.0;

  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(RhythmCommand command) async {
    final soundPath = 'assets/sounds/${command.name}.mp3';
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(soundPath);
      _audioPlayer.play();
    } catch (e) {
      debugPrint("Error playing sound $soundPath: $e");
    }
  }

  void _onCommandPressed(RhythmCommand command) {
    _playSound(command);
    setState(() {
      _currentSequence.add(command);
    });

    if (_currentSequence.length == 4) {
      Timer(const Duration(milliseconds: 400), () {
        if (mounted) {
          _processCommandSequence();
        }
      });
    }
  }

  void _processCommandSequence() {
    const marchCommand = [
      RhythmCommand.pata,
      RhythmCommand.pata,
      RhythmCommand.pata,
      RhythmCommand.pon
    ];

    if (_sequenceEquals(_currentSequence, marchCommand)) {
      setState(() {
        _feedbackMessage = 'Marching Forward!';
        _score += 10;
        _characterXPosition += 40;
      });
    } else {
      setState(() {
        _feedbackMessage = '...Missed!';
      });
    }
    _currentSequence.clear();
  }

  bool _sequenceEquals(List<RhythmCommand> a, List<RhythmCommand> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Rhythm Game',
      currentPage: AppRoutes.rhythmGame,
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.lightBlue[100],
              child: Stack(
                children: [
                  // Character
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    left: _characterXPosition,
                    bottom: 50,
                    child: const _PataponCharacter(),
                  ),
                  // Command Feedback UI
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentSequence.map((c) => c.name.toUpperCase()).join(' '),
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _feedbackMessage,
                            style: const TextStyle(
                                fontSize: 18, color: Colors.deepPurple),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Score: $_score',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _RhythmButton(
                        label: 'PATA',
                        color: Colors.blue,
                        onPressed: () => _onCommandPressed(RhythmCommand.pata),
                      ),
                      _RhythmButton(
                        label: 'PON',
                        color: Colors.red,
                        onPressed: () => _onCommandPressed(RhythmCommand.pon),
                      ),
                      _RhythmButton(
                        label: 'CHAKA',
                        color: Colors.yellow,
                        onPressed: () => _onCommandPressed(RhythmCommand.chaka),
                      ),
                      _RhythmButton(
                        label: 'DON',
                        color: Colors.green,
                        onPressed: () => _onCommandPressed(RhythmCommand.don),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RhythmButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _RhythmButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(32),
        enableFeedback: false,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _PataponCharacter extends StatelessWidget {
  const _PataponCharacter();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/character.svg',
      width: 100,
      height: 100,
    );
  }
}
