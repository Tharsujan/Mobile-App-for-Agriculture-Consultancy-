import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'UserConsaltancyBookingDetailsPage.dart';

class EnterDetailsPage extends StatefulWidget {
  final DateTime selectedDate;
  final String selectedTime;

  EnterDetailsPage({required this.selectedDate, required this.selectedTime});

  @override
  _EnterDetailsPageState createState() => _EnterDetailsPageState();
}

class _EnterDetailsPageState extends State<EnterDetailsPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();

  bool _validatePhoneNumber(String value) {
    // Regular expression to check for a 10-digit phone number without any special characters
    RegExp regex = RegExp(r'^[0-9]{10}$');
    return regex.hasMatch(value);
  }

  void _saveBooking() {
    String name = nameController.text;
    String contact = contactController.text;

    if (!_validatePhoneNumber(contact)) {
      // Invalid phone number format
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invalid Phone Number'),
            content: Text('Please enter a valid 10-digit phone number.'),
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
      return;
    }

    // Get the current user's UID
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    // Generate a new document ID
    String documentId =
        FirebaseFirestore.instance.collection('ConsultancyBooking').doc().id;

    // Save the booking details to Firestore with the document ID
    FirebaseFirestore.instance
        .collection('ConsultancyBooking')
        .doc(uid)
        .collection("ConsaltBooking")
        .doc(documentId) // Use the generated document ID
        .set({
      'id': documentId, // Store the document ID as a field
      'name': name,
      'contact': contact,
      'selectedDate': widget.selectedDate.toLocal().toString().split(' ')[0],
      'selectedTime': widget.selectedTime,
      'email': user?.email,
      'status': "pending"
    }).then((value) {
      // Booking data saved successfully
      print('Booking data saved to Firestore with ID: $documentId');
      _showSuccessDialog(); // Show success dialog
      _resetFields(); // Clear all fields
      // Refresh the user's bookings list after saving a new booking
      // Call the function to fetch user bookings here (e.g., fetchUserBookings())
    }).catchError((error) {
      // Error occurred while saving the booking data
      print('Error saving booking data: $error');
      // You can also show an error message using a dialog here if needed
    });
  }

  // Show success dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Booking Successful'),
          content: Text('Your booking has been successfully saved.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserBookingDetailsPage(),
                  ),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _resetFields() {
    nameController.text = '';
    contactController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Selected Date:  ${widget.selectedDate.toLocal().toString().split(' ')[0]}',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700]),
              ),
              SizedBox(height: 10),
              Text(
                'Selected Time Slot:  ${widget.selectedTime}',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700]),
              ),
              SizedBox(height: 40),
              Text(
                'Enter Your Name:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Your name',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Enter Your Contact Number:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: contactController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Your contact Number',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveBooking,
                child: Text('Book Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
