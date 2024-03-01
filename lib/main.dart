import 'dart:async';

import 'package:flutter/material.dart';

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
  String _age = '';

  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_selectedDate != null) {
        setState(() {
          _age = calculateAge(_selectedDate!);
        });
      }
    });
  }

  @override
  void dispose(){
    _timer.cancel();
    super.dispose();
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
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0, left: 12.0, right: 12.0),
                     child: Text( 'Your Age: $_age}',
                      style: const TextStyle(fontSize: 20, color: Colors.blue,),
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