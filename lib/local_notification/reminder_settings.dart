import 'package:exercai_mobile/local_notification/notification_service.dart';
import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

class ReminderSettings extends StatefulWidget {
  const ReminderSettings({super.key});

  @override
  _ReminderSettingsState createState() => _ReminderSettingsState();
}

class _ReminderSettingsState extends State<ReminderSettings> {
  late Box reminderBox;

  final Map<DateTime, List<TimeOfDay>> _workoutReminders = {};
  final Map<DateTime, List<TimeOfDay>> _breakfastReminders = {};
  final Map<DateTime, List<TimeOfDay>> _lunchReminders = {};
  final Map<DateTime, List<TimeOfDay>> _dinnerReminders = {};

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    reminderBox = await Hive.openBox('reminders');
    _loadReminders();
  }

  void _loadReminders() {
    setState(() {
      _loadReminderType('workout', _workoutReminders);
      _loadReminderType('breakfast', _breakfastReminders);
      _loadReminderType('lunch', _lunchReminders);
      _loadReminderType('dinner', _dinnerReminders);
    });
  }

  void _loadReminderType(String key, Map<DateTime, List<TimeOfDay>> reminders) {
    final data = reminderBox.get(key, defaultValue: {});
    reminders.clear();
    data.forEach((dateStr, times) {
      DateTime date = DateTime.parse(dateStr);
      List<TimeOfDay> timeList = (times as List).map((t) {
        return TimeOfDay(hour: t["hour"], minute: t["minute"]);
      }).toList();
      reminders[date] = timeList;
    });
  }

  Future<void> _saveReminders(String key, Map<DateTime, List<TimeOfDay>> reminders) async {
    final Map<String, List<Map<String, int>>> data = {};
    reminders.forEach((date, times) {
      data[date.toIso8601String()] = times.map((t) => {"hour": t.hour, "minute": t.minute}).toList();
    });
    await reminderBox.put(key, data);
  }

  Future<void> _selectDate(BuildContext context, Map<DateTime, List<TimeOfDay>> reminders, String key) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        reminders.putIfAbsent(pickedDate, () => []);
      });
      _selectTime(context, pickedDate, reminders, key);
    }
  }

  Future<void> _selectTime(BuildContext context, DateTime date, Map<DateTime, List<TimeOfDay>> reminders, String key) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        reminders[date]!.add(pickedTime);
      });
      _saveReminders(key, reminders);
    } else {
      // If no time is chosen, remove the date from the reminders
      setState(() {
        reminders.remove(date);
      });
    }
  }


  Future<void> _scheduleNotifications(Map<DateTime, List<TimeOfDay>> reminders, String title, String body) async {
    if (reminders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one date and time for $title!')),
      );
      return;
    }

    for (var entry in reminders.entries) {
      DateTime date = entry.key;
      for (TimeOfDay time in entry.value) {
        DateTime scheduledDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);

        // Check if the selected date and time is in the past
        if (scheduledDateTime.isBefore(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Warning: You cannot save a reminder for a past time!'),
              backgroundColor: Colors.red,
            ),
          );
          return; // Stop scheduling if any time is in the past
        }

        // Generate a unique ID based on date and time
        int uniqueId = date.millisecondsSinceEpoch ~/ 1000 + time.hour * 60 + time.minute;

        await NotiService().scheduleNotification(
          id: uniqueId,
          title: title,
          body: body,
          scheduledDate: scheduledDateTime,
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title reminders set successfully.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildDateList(Map<DateTime, List<TimeOfDay>> reminders, String key) {
    return Column(
      children: reminders.entries.map((entry) {
        DateTime date = entry.key;
        List<TimeOfDay> times = entry.value;
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  DateFormat.yMMMd().format(date),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.add, color: Colors.blueAccent),
                  onPressed: () => _selectTime(context, date, reminders, key),
                ),
              ),
              Column(
                children: times.map((time) => ListTile(
                  title: Text(time.format(context)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        reminders[date]!.remove(time);
                        if (reminders[date]!.isEmpty) reminders.remove(date);
                      });
                      _saveReminders(key, reminders);
                    },
                  ),
                )).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReminderSection(String label, Map<DateTime, List<TimeOfDay>> reminders, String title, String body, String key) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$label Date & Time',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              GestureDetector(
                onTap: () => _selectDate(context, reminders, key),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.backgroundgrey,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDateList(reminders, key),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 240,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _scheduleNotifications(reminders, title, body),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.moresolidPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  'Save $label Reminder',
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Divider(thickness: 2, color: Colors.grey.shade300),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        title: const Text('Set Reminders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primary,
        elevation: 2,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: Colors.white,)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildReminderSection('Workout', _workoutReminders, 'Workout Reminder', 'Time for your scheduled workout! 💪', 'workout'),
            const SizedBox(height: 30),
            _buildReminderSection('Breakfast', _breakfastReminders, 'Breakfast Reminder', 'Time for your breakfast! 🍳', 'breakfast'),
            const SizedBox(height: 30),
            _buildReminderSection('Lunch', _lunchReminders, 'Lunch Reminder', 'Time for your lunch! 🍛', 'lunch'),
            const SizedBox(height: 30),
            _buildReminderSection('Dinner', _dinnerReminders, 'Dinner Reminder', 'Time for your dinner! 🍽️', 'dinner'),
          ],
        ),
      ),
    );
  }
}
