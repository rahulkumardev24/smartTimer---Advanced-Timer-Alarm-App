import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';


class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _hours = 0;
  int _minutes = 0;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isCompleted = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_hours == 0 && _minutes == 0) return;
    
    setState(() {
      _isRunning = true;
      _isCompleted = false;
      _remainingSeconds = (_hours * 3600) + (_minutes * 60);
    });

    _runTimer();
  }

  void _runTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_remainingSeconds > 0 && _isRunning) {
        setState(() {
          _remainingSeconds--;
        });
        _runTimer();
      } else if (_remainingSeconds == 0 && _isRunning) {
        setState(() {
          _isRunning = false;
          _isCompleted = true;
        });
        _playCompletionSound();
      }
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _isCompleted = false;
      _remainingSeconds = 0;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Timer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isRunning && !_isCompleted)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Hours',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _hours = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Minutes',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _minutes = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            Text(
              _formatTime(_remainingSeconds),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning && !_isCompleted)
                  ElevatedButton(
                    onPressed: _startTimer,
                    child: const Text('Start'),
                  ),
                if (_isRunning)
                  ElevatedButton(
                    onPressed: _stopTimer,
                    child: const Text('Stop'),
                  ),
                if (_isCompleted)
                  ElevatedButton(
                    onPressed: _resetTimer,
                    child: const Text('Reset'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 