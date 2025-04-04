import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';
import '../constants/colors.dart';
import '../utils/custom_text_style.dart';
import '../widgets/circular_button.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mqData = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AlarmProvider>(
        builder: (context, alarmProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: alarmProvider.alarms.isEmpty
                      ? Center(
                          child: Text(
                            'No alarms set',
                            style: myTextStyle24(fontColor: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          itemCount: alarmProvider.alarms.length,
                          itemBuilder: (context, index) {
                            final alarm = alarmProvider.alarms[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 10),
                                title: Row(
                                  children: [
                                    Text(
                                      alarmProvider.formatTime(alarm.time),
                                      style: myTextStyle24(),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          alarm.label,
                                          style: myTextStyle15(
                                              fontColor: Colors.white),
                                        ),
                                        Text(
                                          alarmProvider
                                              .getRepeatDaysText(alarm.repeatDays),
                                          style: myTextStyle15(
                                              fontColor: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Switch(
                                      value: alarm.isActive,
                                      onChanged: (value) =>
                                          alarmProvider.toggleAlarm(index),
                                      activeColor: AppColors.primary,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          alarmProvider.removeAlarm(index),
                                    ),
                                  ],
                                ),
                                onTap: () => _showEditAlarmDialog(
                                    context, alarmProvider, index, alarm),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                CircularButton(
                  buttonHeight: 80,
                  buttonWidth: 80,
                  onPressed: () => _showAddAlarmDialog(context, alarmProvider),
                  icon: Icons.add,
                  iconColor: Colors.white,
                  iconSize: 50,
                  buttonColor: AppColors.primary,
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddAlarmDialog(
      BuildContext context, AlarmProvider alarmProvider) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.background,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null && context.mounted) {
      _showAlarmDetailsDialog(context, alarmProvider, null, Alarm(
        time: selectedTime,
        label: 'Alarm',
      ));
    }
  }

  Future<void> _showEditAlarmDialog(BuildContext context,
      AlarmProvider alarmProvider, int index, Alarm alarm) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: alarm.time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.background,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null && context.mounted) {
      _showAlarmDetailsDialog(
          context,
          alarmProvider,
          index,
          alarm.copyWith(
            time: selectedTime,
          ));
    }
  }

  Future<void> _showAlarmDetailsDialog(BuildContext context,
      AlarmProvider alarmProvider, int? index, Alarm alarm) async {
    String label = alarm.label;
    List<bool> repeatDays = List.from(alarm.repeatDays);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text('Alarm Details',
            style: myTextStyle24(fontColor: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Label',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                ),
                onChanged: (value) => label = value,
                controller: TextEditingController(text: label),
              ),
              const SizedBox(height: 16),
              Text('Repeat', style: myTextStyle15(fontColor: Colors.white)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (int i = 0; i < repeatDays.length; i++)
                    FilterChip(
                      label: Text(['S', 'M', 'T', 'W', 'T', 'F', 'S'][i]),
                      selected: repeatDays[i],
                      onSelected: (bool selected) {
                        setState(() => repeatDays[i] = selected);
                      },
                      backgroundColor: Colors.black26,
                      selectedColor: AppColors.primary,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: repeatDays[i] ? Colors.white : Colors.white70,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel',
                style: myTextStyle15(fontColor: Colors.white70)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Save', style: myTextStyle15(fontColor: AppColors.primary)),
            onPressed: () {
              final updatedAlarm = alarm.copyWith(
                label: label,
                repeatDays: repeatDays,
              );
              if (index != null) {
                alarmProvider.updateAlarm(index, updatedAlarm);
              } else {
                alarmProvider.addAlarm(updatedAlarm);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
