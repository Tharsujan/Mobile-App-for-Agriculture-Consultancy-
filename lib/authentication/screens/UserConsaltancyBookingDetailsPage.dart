import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ConsultancyBookingPage.dart';

class UserBookingDetailsPage extends StatefulWidget {
  @override
  _UserBookingDetailsPageState createState() => _UserBookingDetailsPageState();
}

class _UserBookingDetailsPageState extends State<UserBookingDetailsPage> {
  List<Map<String, dynamic>> bookings = [];

  @override
  void initState() {
    super.initState();
    fetchUserBookings();
  }

  void fetchUserBookings() async {
    try {
      String uid = FirebaseAuth.instance.currentUser?.uid ?? '';

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('ConsultancyBooking')
              .doc(uid)
              .collection("ConsaltBooking")
              .where('status', isEqualTo: 'pending')
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          bookings = querySnapshot.docs.map((doc) => doc.data()).toList();
        });
      }
    } catch (e) {
      print('Error fetching user bookings: $e');
      // You can show an error message here if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Consultancy Bookig Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your consaltancy booking details',
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  if (bookings.isNotEmpty)
                    Column(
                      children: bookings.map((booking) {
                        return Column(
                          children: [
                            Text(
                              'Date: ${booking['selectedDate']}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Time Slot: ${booking['selectedTime']}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        );
                      }).toList(),
                    ),
                  if (bookings.isEmpty)
                    Text(
                      'No bookings found',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Unlock your potential with our expert consultancy service, tailored to empower and guide you on your journey to success. Book now to experience the transformative impact firsthand.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingPage(),
                        ),
                      );
                    },
                    child: Text('Book now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
