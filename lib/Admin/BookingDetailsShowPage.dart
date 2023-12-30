import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDetailsPage extends StatefulWidget {
  final String qrCode;

  BookingDetailsPage({required this.qrCode});

  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ConsultancyBooking')
            .doc(widget.qrCode)
            .collection('ConsaltBooking')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No booking data found',
                style: TextStyle(fontSize: 18),
              ),
            );
          } else {
            final bookingDocs = snapshot.data!.docs;
            return ListView.builder(
              itemCount: bookingDocs.length,
              itemBuilder: (context, index) {
                final bookingData =
                    bookingDocs[index].data() as Map<String, dynamic>;
                final bookingId = bookingDocs[index].id;

                return BookingCard(
                  bookingData: bookingData,
                  bookingId: bookingId,
                  qrCode: widget.qrCode,
                );
              },
            );
          }
        },
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> bookingData;
  final String bookingId;
  final String qrCode;

  BookingCard({
    required this.bookingData,
    required this.bookingId,
    required this.qrCode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Name: ${bookingData['name']}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: ${bookingData['selectedDate']}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Time: ${bookingData['selectedTime']}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Contact: ${bookingData['contact']}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Email: ${bookingData['email']}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Show a confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Confirm Completion',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          'Are you sure you want to mark this booking as complete?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                              // Handle complete button action here
                              updateBookingDetail(bookingId);
                            },
                            child: Text(
                              'Yes',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Text('No',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: Text(
                  'Complete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> updateBookingDetail(String bookingId) async {
    try {
      await FirebaseFirestore.instance
          .collection('ConsultancyBooking')
          .doc(qrCode)
          .collection('ConsaltBooking')
          .doc(bookingId)
          .update({'status': 'finished'});
    } catch (e) {
      print('Error deleting booking detail: $e');
    }
  }
}
