import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'QrScannerItemBookingPage.dart';
import 'QrScannerPage.dart';
import 'SessionTimeout.dart';

class QrScannerHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner Home'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "You can scan the QR code to instantly obtain detailed information.",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    SessionTimeout().onUserInteraction();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QrScannerPageItemBooking(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green, // Text color
                    padding: EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 30), // Adjust height and width here
                    textStyle: TextStyle(fontSize: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 5,
                  ),
                  child: Text('Scan Plants & Equipment Booking'),
                ),
              ),
              SizedBox(height: 20), // Add some spacing between the buttons
              ElevatedButton(
                onPressed: () {
                  SessionTimeout().onUserInteraction();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QrScannerPageConsaltancyBooking(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green, // Text color
                  padding: EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 30), // Adjust height and width here
                  textStyle: TextStyle(fontSize: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                ),
                child: Text('Scan Consultancy Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
