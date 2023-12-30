import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'EnterDetailsPage.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String selectedTime = '';
  DateTime selectedDate = DateTime.now();

  Widget _buildTimeButton(String time, bool isAvailable) {
    return ElevatedButton(
      onPressed: isAvailable
          ? () {
              setState(() {
                selectedTime = time;
              });
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedTime == time ? Colors.blue : null,
      ),
      child: Text(time),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime firstDate = now;
    if (now.weekday == DateTime.sunday) {
      // If today is Sunday, set the first selectable date to Monday
      firstDate = now.add(Duration(days: 1));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.isBefore(firstDate) ? firstDate : selectedDate,
      firstDate: firstDate,
      lastDate: firstDate.add(Duration(days: 365)),
      selectableDayPredicate: (DateTime day) {
        // Disable selection of Sundays
        return day.weekday != DateTime.sunday;
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // Reset selectedTime when a new date is selected
        selectedTime = '';
      });
    }
  }

  void _showEnterDetailsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnterDetailsPage(
          selectedDate: selectedDate,
          selectedTime: selectedTime,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultancy Service Booking'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select a Date:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('Pick a date'),
            ),
            SizedBox(height: 50),
            Text(
              'Select a Time Period:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FutureBuilder<bool>(
                      future: _isTimeSlotAvailable('8AM - 10AM'),
                      builder: (context, snapshot) {
                        bool isAvailable = snapshot.data ?? false;
                        return _buildTimeButton('8AM - 10AM', isAvailable);
                      },
                    ),
                    FutureBuilder<bool>(
                      future: _isTimeSlotAvailable('10AM - 12PM'),
                      builder: (context, snapshot) {
                        bool isAvailable = snapshot.data ?? false;
                        return _buildTimeButton('10AM - 12PM', isAvailable);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FutureBuilder<bool>(
                      future: _isTimeSlotAvailable('1PM - 3PM'),
                      builder: (context, snapshot) {
                        bool isAvailable = snapshot.data ?? false;
                        return _buildTimeButton('1PM - 3PM', isAvailable);
                      },
                    ),
                    FutureBuilder<bool>(
                      future: _isTimeSlotAvailable('3PM - 5PM'),
                      builder: (context, snapshot) {
                        bool isAvailable = snapshot.data ?? false;
                        return _buildTimeButton('3PM - 5PM', isAvailable);
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedTime.isNotEmpty && selectedDate != null) {
                  // Ensure both time and date are selected
                  if (selectedDate.weekday == DateTime.sunday) {
                    // Check if selected date is Sunday
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Invalid Date'),
                          content:
                              Text('Sundays are not available for booking.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Close the dialog
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    _checkTimeslotAvailability();
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Select Time Slot and Date'),
                        content: Text('Please select a time slot and a date.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkTimeslotAvailability() async {
    bool isAvailable = await _isTimeSlotAvailable(selectedTime);
    if (!isAvailable) {
      // Timeslot is already booked, show dialog to the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Timeslot Not Available'),
            content: Text(
                'The selected timeslot is already booked. Please choose another timeslot.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      _showEnterDetailsPage();
    }
  }

  Future<bool> _isTimeSlotAvailable(String time) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collectionGroup('ConsaltBooking')
        .where('selectedDate',
            isEqualTo: selectedDate.toLocal().toString().split(' ')[0])
        .where('selectedTime', isEqualTo: time)
        .get();

    return querySnapshot.docs.isEmpty;
  }
}
