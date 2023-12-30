import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'SessionTimeout.dart';

class ConsultancyBookingDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consultancy Booking Details'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('ConsaltBooking')
            .where('status', isEqualTo: 'pending')
            .snapshots(), // Fetch all documents in the 'ConsultancyBooking' collection
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No booking details found.'),
            );
          }

          // Extract the documents and sort them by date and time
          final bookingDocs = snapshot.data!.docs;
          bookingDocs.sort((a, b) {
            final aDate = DateTime.parse(a['selectedDate'] as String);
            final bDate = DateTime.parse(b['selectedDate'] as String);
            final aTime = a['selectedTime'] as String;
            final bTime = b['selectedTime'] as String;

            if (aDate.isBefore(bDate)) {
              return -1;
            } else if (aDate.isAfter(bDate)) {
              return 1;
            } else {
              return aTime.compareTo(bTime);
            }
          });

          return ListView.builder(
            itemCount: bookingDocs.length,
            itemBuilder: (context, index) {
              final bookingData =
                  bookingDocs[index].data() as Map<String, dynamic>;

              // Extract the specific fields you want to display
              final contact = bookingData['contact'];
              final name = bookingData['name'];
              final time = bookingData['selectedTime'];
              final date = bookingData['selectedDate'];
              final id = bookingData['id'];

              // Check if the Firestore fields might be null
              final selectedDate = bookingData['selected_date'];
              final selectedTime = bookingData['selected_time'] as String?;

              return Card(
                margin: EdgeInsets.all(8.0),
                elevation: 5,
                child: ListTile(
                  title: Text('Contact: $contact'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: $name'),
                      Text('Date: $date'),
                      Text('Time: $time'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          SessionTimeout().onUserInteraction();

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
                                      Navigator.pop(
                                          context); // Close the dialog
                                      // Handle complete button action here
                                      completeBookingDetail(id);
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
                                      Navigator.pop(
                                          context); // Close the dialog
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
                      SizedBox(width: 10),
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
                                  'Are you sure you want cancel this booking?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // Close the dialog
                                      // Handle complete button action here
                                      deleteBookingDetail(id);
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
                                      Navigator.pop(
                                          context); // Close the dialog
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
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> deleteBookingDetail(String id) async {
    try {
      // Query the 'Booking' sub-collection for the document with a matching 'id'
      QuerySnapshot bookingQuery = await FirebaseFirestore.instance
          .collectionGroup('ConsaltBooking')
          .where('id', isEqualTo: id)
          .get();

      if (bookingQuery.docs.isNotEmpty) {
        // Assuming there's only one document with the specified 'id'
        var documentReference = bookingQuery.docs.first.reference;
        await documentReference.delete();
      } else {
        print('Document not found with id: $id');
      }
    } catch (e) {
      print('Error Delete booking detail: $e');
    }
  }

  Future<void> completeBookingDetail(String id) async {
    try {
      // Query the 'Booking' sub-collection for the document with a matching 'id'
      QuerySnapshot bookingQuery = await FirebaseFirestore.instance
          .collectionGroup('ConsaltBooking')
          .where('id', isEqualTo: id)
          .get();

      if (bookingQuery.docs.isNotEmpty) {
        // Assuming there's only one document with the specified 'id'
        var documentReference = bookingQuery.docs.first.reference;
        await documentReference.update({'status': 'finished'});
      } else {
        print('Document not found with id: $id');
      }
    } catch (e) {
      print('Error cancelled booking detail: $e');
    }
  }
}
