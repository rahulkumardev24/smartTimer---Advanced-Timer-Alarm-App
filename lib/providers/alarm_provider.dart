import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'package:audio_session/audio_session.dart';

class Alarm {
  final TimeOfDay time;
  final bool isActive;
  final List<bool> repeatDays; /// [Sun, Mon, Tue, Wed, Thu, Fri, Sat]
  final String label;

  Alarm({
    required this.time,
    this.isActive = true,
    List<bool>? repeatDays,
    this.label = 'Alarm',
  }) : repeatDays = repeatDays ?? List.filled(7, false);

  Alarm copyWith({
    TimeOfDay? time,
    bool? isActive,
    List<bool>? repeatDays,
    String? label,
  }) {
    return Alarm(
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      repeatDays: repeatDays ?? this.repeatDays,
      label: label ?? this.label,
    );
  }
}

class AlarmProvider extends ChangeNotifier {
  final List<Alarm> _alarms = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<Alarm> get alarms => _alarms;

  void addAlarm(Alarm alarm) {
    _alarms.add(alarm);
    _sortAlarms();
    notifyListeners();
  }

  void removeAlarm(int index) {
    _alarms.removeAt(index);
    notifyListeners();
  }

  void toggleAlarm(int index) {
    _alarms[index] = _alarms[index].copyWith(
      isActive: !_alarms[index].isActive,
    );
    notifyListeners();
  }

  void updateAlarm(int index, Alarm alarm) {
    _alarms[index] = alarm;
    _sortAlarms();
    notifyListeners();
  }

  void _sortAlarms() {
    _alarms.sort((a, b) {
      int aMinutes = a.time.hour * 60 + a.time.minute;
      int bMinutes = b.time.hour * 60 + b.time.minute;
      return aMinutes.compareTo(bMinutes);
    });
  }

  String formatTime(TimeOfDay time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String getRepeatDaysText(List<bool> repeatDays) {
    List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    List<String> selectedDays = [];
    
    for (int i = 0; i < repeatDays.length; i++) {
      if (repeatDays[i]) {
        selectedDays.add(days[i]);
      }
    }
    
    if (selectedDays.isEmpty) return 'Once';
    if (selectedDays.length == 7) return 'Every day';
    if (selectedDays.length == 5 && 
        repeatDays[1] && repeatDays[2] && repeatDays[3] && 
        repeatDays[4] && repeatDays[5]) {
      return 'Weekdays';
    }
    if (selectedDays.length == 2 && 
        repeatDays[0] && repeatDays[6]) {
      return 'Weekends';
    }
    
    return selectedDays.join(', ');
  }

  Future<void> playAlarmSound() async {
    try {
      // Configure audio session
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.alarm,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
      ));

      // Set audio player settings
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setLoopMode(LoopMode.off);
      
      // Use bundled asset with proper configuration
      await _audioPlayer.setAudioSource(
        AudioSource.asset(
          'lib/assets/sounds/alarm.mp3',

        ),
        initialPosition: Duration.zero,
        preload: true,
      );
      
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing alarm sound: $e');
      // Try fallback method with simpler configuration
      try {
        final player = AudioPlayer();
        await player.setAsset(
          'lib/assets/sounds/alarm.mp3',

        );
        await player.play();
        await player.dispose();
      } catch (e) {
        print('Fallback also failed: $e');
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
} 