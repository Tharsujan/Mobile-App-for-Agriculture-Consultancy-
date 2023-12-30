import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemBookingDetailsPage extends StatefulWidget {
  final String qrCode;

  ItemBookingDetailsPage({required this.qrCode});

  @override
  _BookingDetailsPageState createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<ItemBookingDetailsPage> {
  late Future<List<Map<String, dynamic>>> _bookingDataList;

  @override
  void initState() {
    super.initState();
    _bookingDataList = fetchBookingData();
  }

  Future<List<Map<String, dynamic>>> fetchBookingData() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('Booking')
            .doc(widget.qrCode)
            .collection('UserBooking')
            .where('status', isEqualTo: 'pending')
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Convert each DocumentSnapshot to a Map and create a list
      return querySnapshot.docs.map((doc) => doc.data()!).toList();
    } else {
      return []; // Return an empty list if no data is found
    }
  }

  Future<void> _completeBooking(String bookingId) async {
    try {
      // Show a confirmation dialog with "Yes" and "No" options
      final result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Complete Booking',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Do you want to complete the booking?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Yes
                },
                child: Text(
                  'Yes',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // No
                },
                child: Text(
                  'No',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );

      // Handle the user's choice
      if (result == true) {
        // User clicked "Yes" to complete the booking
        await FirebaseFirestore.instance
            .collection('Booking')
            .doc(widget.qrCode)
            .collection('UserBooking')
            .doc(bookingId)
            .update({
          'status': 'complete',
          'payment': 'complete',
        });

        // Fetch and refresh data after completion
        setState(() {
          _bookingDataList = fetchBookingData();
        });
      } else {
        // User clicked "No" to cancel the completion
        // You can add optional handling for this case if needed
      }
    } catch (e) {
      // Handle any errors that occur during the deletion process.
      print('Error deleting booking: $e');
    }
  }

  Future<void> _cancelBooking(
      String bookingId, int quantity, String category, String productId) async {
    try {
      // Show a confirmation dialog with "Yes" and "No" options
      final result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Cancel Booking',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Do you want to cancel the booking?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Yes
                },
                child: Text(
                  'Yes',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // No
                },
                child: Text(
                  'No',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );

      // Handle the user's choice
      if (result == true) {
        // User clicked "Yes" to cancel the booking
        await FirebaseFirestore.instance
            .collection('Booking')
            .doc(widget.qrCode)
            .collection('UserBooking')
            .doc(bookingId)
            .update({'status': 'cancelled'});

        // Increase the product quantity by the canceled quantity

        final documentReference = FirebaseFirestore.instance
            .collection(
                category.trim() == 'equipments' ? 'Equipments' : 'Plants')
            .doc(category.trim())
            .collection('Items')
            .doc(productId);
        print("awwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww" + category);

// Retrieve the current quantity value as a string
        documentReference.get().then((docSnapshot) {
          if (docSnapshot.exists) {
            // Get the current quantity as a string
            final currentQuantityString = docSnapshot.data()?['quantity'];

            // Convert the current quantity string to an integer
            final currentQuantityInt = int.tryParse(currentQuantityString) ?? 0;

            // Update the quantity by adding the new quantity
            final newQuantityInt = currentQuantityInt + quantity;

            // Convert the new quantity integer back to a string
            final newQuantityString = newQuantityInt.toString();

            // Update the Firestore document with the new quantity string
            documentReference.update({
              'quantity': newQuantityString,
            });
          }
        });

        // Fetch and refresh data after cancellation
        setState(() {
          _bookingDataList = fetchBookingData();
        });
      } else {
        // User clicked "No" to cancel the cancellation
        // You can add optional handling for this case if needed
      }
    } catch (e) {
      // Handle any errors that occur during the cancellation process.
      print('Error canceling booking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookingDataList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error fetching data',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            );
          } else if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No booking data found',
                style: TextStyle(fontSize: 18),
              ),
            );
          } else {
            final bookingDataList = snapshot.data!;
            return ListView.builder(
              itemCount: bookingDataList.length,
              itemBuilder: (context, index) {
                final bookingData = bookingDataList[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Image.network(
                          bookingData['image_url'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          '${bookingData['name']}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              'Total: ${bookingData['total']}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Quantity: ${bookingData['quantity']}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'User email: ${bookingData['UserEmail']}',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Handle complete button action here
                              _completeBooking(bookingData['bookingId']);
                            },
                            child: Text('Complete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              textStyle: TextStyle(fontSize: 14),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Handle cancel button action here
                              _cancelBooking(
                                  bookingData['bookingId'],
                                  bookingData['quantity'],
                                  bookingData['category'],
                                  bookingData['productId']);
                            },
                            child: Text('Cancel'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              textStyle: TextStyle(fontSize: 14),
                            ),
                          ),
                          SizedBox(width: 16),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
