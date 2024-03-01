// ignore_for_file: unused_local_variable

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Your Age',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? _selectedDate;
  final String _age = '';
  late SharedPreferences _prefs;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  
  @override
  void initState() {
    super.initState();
    _initLocalNotifications();
    _loadSelectedDate();

    AndroidAlarmManager.periodic(
      const Duration(seconds: 60), // Adjust the interval as needed
      0,
      _backgroundTask,
      wakeup: true,
    );
  }

@override
  void dispose() {
    _flutterLocalNotificationsPlugin.cancelAll();
    super.dispose();
  }
Future<void> _initLocalNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        _openMyHomePage();
      },
    );

    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      _openMyHomePage();
    }
  }

  void _openMyHomePage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MyHomePage()),
    );
  }

  Future<void> _loadSelectedDate() async {
    _prefs = await SharedPreferences.getInstance();
    final storedDate = _prefs.getInt('selectedDate');
    if (storedDate != null) {
      setState(() {
        _selectedDate = DateTime.fromMillisecondsSinceEpoch(storedDate);
      });
    }
  }

  Future<void> _saveSelectedDate(DateTime selectedDate) async {
    await _prefs.setInt('selectedDate', selectedDate.millisecondsSinceEpoch);
  }

  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'rpsh',
      'Rupesh',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Your Age',
      message,
      platformChannelSpecifics,
    );
  }

   Future<void> _backgroundTask() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDate = prefs.getInt('selectedDate');
    if (storedDate != null) {
      final selectedDate = DateTime.fromMillisecondsSinceEpoch(storedDate);
      final age = calculateAge(selectedDate);
      await _showNotification(age);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Age'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '',
              style: TextStyle(fontSize: 25),
            ),
            ElevatedButton(
              onPressed: () async {
                DateTime? datePicked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1990),
                  lastDate: DateTime(2009),
                );

                if (datePicked != null) {
                  setState(() {
                    _selectedDate = datePicked;
                    _saveSelectedDate(datePicked);
                  });
                }
              },
              child: const Text(
                'Select Date',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            if (_selectedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 56.0),
                child: Column(
                  children: [
                    Text(
                      'Selected Date: ${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyan,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, bottom: 16.0, left: 12.0, right: 12.0),
                      child: Text(
                        'Your Age: $_age}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String calculateAge(DateTime selectedDate) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(selectedDate);

    int years = difference.inDays ~/ 365;
    int months = (difference.inDays % 365) ~/ 30;
    int weeks = (difference.inDays % 365 % 30) ~/ 7;
    int days = (difference.inDays % 365 % 30) % 7;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;
    int seconds = difference.inSeconds % 60;

    return '$years years, $months months, $weeks weeks, $days days, $hours hours, $minutes minutes, $seconds seconds';
  }
}
