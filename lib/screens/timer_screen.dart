import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:smarttimer/utils/custom_text_style.dart';
import 'package:smarttimer/widgets/circular_button.dart';
import 'dart:math' as math;

import '../constants/colors.dart';

/// Custom Gradient Progress Painter
class GradientCircularProgressPainter extends CustomPainter {
  GradientCircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    this.backgroundColor = Colors.white24,
  });

  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  @override

  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Create gradient paint
    final gradientPaint =
        Paint()
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    gradientPaint.shader = SweepGradient(
      colors: gradientColors,
      tileMode: TileMode.clamp,
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
    ).createShader(rect);

    // Draw progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress,
      false,
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isCompleted = false;
  bool _isPaused = false;

  // Lists for the pickers
  final List<String> _hoursList = List.generate(
    24,
    (index) => index.toString().padLeft(2, '0'),
  );
  final List<String> _minutesList = List.generate(
    60,
    (index) => index.toString().padLeft(2, '0'),
  );
  final List<String> _secondsList = List.generate(
    60,
    (index) => index.toString().padLeft(2, '0'),
  );

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_hours == 0 && _minutes == 0 && _seconds == 0) return;

    setState(() {
      _isRunning = true;
      _isPaused = false;
      _isCompleted = false;
      if (_remainingSeconds == 0) {
        // Only set initial time if starting fresh
        _remainingSeconds = (_hours * 3600) + (_minutes * 60) + _seconds;
      }
    });

    _runTimer();
  }

  void _runTimer() {
    if (!_isRunning) return;

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;  // Check if widget is still mounted
      
      if (_remainingSeconds > 0 && _isRunning) {
        setState(() {
          _remainingSeconds--;
        });
        _runTimer();
      } else if (_remainingSeconds == 0 && _isRunning) {
        setState(() {
          _isRunning = false;
          _isCompleted = true;
          _isPaused = false;
        });
        _playCompletionSound();
      }
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isCompleted = false;
      _remainingSeconds = 0;
    });
  }

  void _pauseTimer() {
    setState(() {
      if (_isRunning) {
        // Pause
        _isRunning = false;
        _isPaused = true;
      } else if (_isPaused) {
        // Resume
        _isRunning = true;
        _isPaused = false;
        _runTimer();
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _isCompleted = false;
      _isPaused = false;
      _remainingSeconds = 0;
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
    });
  }

  Future<void> _playCompletionSound() async {
    try {
      String audioPath = "lib/assets/sounds/bell.mp3";
      await _audioPlayer.setAsset(audioPath);
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildTimePicker() {
    const double itemExtent = 80.0;
    const double fontSize = 70.0;
    return SizedBox(
      height: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// ---- Hours --- ///
          Expanded(
            child: CupertinoPicker(
              itemExtent: itemExtent,
              backgroundColor: Colors.transparent,
              looping: true,
              magnification: 1.1,
              diameterRatio: 2 / 2,
              onSelectedItemChanged: (index) {
                setState(() => _hours = index);
              },
              children:
                  _hoursList
                      .map(
                        (hour) => Center(
                          child: Text(
                            hour,
                            style: myTextStyle48(fontColor: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          // Separator
          const Text(
            ":",
            style: TextStyle(fontSize: fontSize, color: Colors.white),
          ),

          /// --- Minutes --- ///
          Expanded(
            child: CupertinoPicker(
              itemExtent: itemExtent,
              backgroundColor: Colors.transparent,
              looping: true,
              magnification: 1.1,
              diameterRatio: 2 / 2,
              onSelectedItemChanged: (index) {
                setState(() => _minutes = index);
              },
              children:
                  _minutesList
                      .map(
                        (minute) => Center(
                          child: Text(
                            minute,
                            style: myTextStyle48(fontColor: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          // Separator
          const Text(
            ":",
            style: TextStyle(fontSize: fontSize, color: Colors.white),
          ),

          /// --- Seconds --- ///
          Expanded(
            child: CupertinoPicker(
              itemExtent: itemExtent,
              backgroundColor: Colors.transparent,
              looping: true,
              magnification: 1.1,
              diameterRatio: 2 / 2,
              onSelectedItemChanged: (index) {
                setState(() => _seconds = index);
              },
              children:
                  _secondsList
                      .map(
                        (second) => Center(
                          child: Text(
                            second,
                            style: myTextStyle48(fontColor: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      /// --- Body --- ///
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// time pick
            if (!_isRunning && !_isCompleted && !_isPaused) 
              _buildTimePicker(),

            /// --- running time --- ///
            if (_isRunning || _isCompleted || _isPaused)
              Center(
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: Duration(seconds: _remainingSeconds),
                  builder: (context, value, child) {
                    final totalSeconds =
                        (_hours * 3600) + (_minutes * 60) + _seconds;
                    final progress =
                        _isCompleted
                            ? 1.0
                            : 1 - (_remainingSeconds / totalSeconds);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CustomPaint(
                            painter: GradientCircularProgressPainter(
                              progress: progress,
                              strokeWidth: 12,
                              gradientColors:
                                  _isCompleted
                                      ? [
                                        Colors.green.shade300,
                                        Colors.greenAccent,
                                        Colors.greenAccent.shade100,
                                      ]
                                      : [
                                        Colors.red.shade400,
                                        Colors.yellow.shade200,
                                        Colors.green.shade200,
                                      ],
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(_remainingSeconds),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning && !_isCompleted && !_isPaused)
                  CircularButton(
                    onPressed: _startTimer,
                    icon: Icons.play_arrow_rounded,
                    iconColor: Colors.white,
                    iconSize: 150,
                    buttonColor: Colors.greenAccent,
                  ),

                if (_isRunning || _isPaused)
                  CircularButton(
                    buttonHeight: 100,
                    buttonWidth: 100,
                    onPressed: _pauseTimer,
                    icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    iconColor: Colors.white,
                    iconSize: 70,
                    buttonColor:  _isPaused ? Colors.greenAccent : Colors.red.shade400,
                  ),


              ],
            ),
          ],
        ),
      ),
    );
  }
}
