import 'package:do_instead/services/notification_service.dart';
import 'package:do_instead/services/settings_service.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final NotificationService _notificationService = NotificationService();
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _settingsService.getReminderTime().then((time) {
      setState(() {
        _selectedTime = time;
      });
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      await _settingsService.setReminderTime(picked);
      await _notificationService.scheduleDailyReminder();
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Daily Reminder Time'),
            subtitle: Text(_selectedTime.format(context)),
            onTap: () => _selectTime(context),
          ),
        ],
      ),
    );
  }
}
