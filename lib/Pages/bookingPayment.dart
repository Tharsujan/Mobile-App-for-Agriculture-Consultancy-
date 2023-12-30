import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:intl/intl.dart';
import '../authentication/screens/home.dart';
import 'Product.dart';

import 'constants.dart';

class Booking {
  String status;
  String payment;
  final String category;
  final String image_url;
  final String name;
  final double total;
  final int quantity;
  var email;
  String date;
  String? bookingId;
  String? productId;

  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Booking({
    required this.status,
    required this.payment,
    required this.category,
    required this.image_url,
    required this.name,
    required this.total,
    required this.quantity,
    required this.email,
    this.bookingId,
    this.productId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'image_url': image_url,
      'name': name,
      'total': total * quantity,
      'quantity': quantity,
      'status': status,
      'payment': payment,
      'UserEmail': email,
      'bookingId': bookingId,
      'productId': productId,
      'date': formattedDate,
    };
  }
}

class BookingService {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> bookProduct(Booking booking) async {
    try {
      final DocumentReference docRef = await _firestore
          .collection('Booking')
          .doc(user!.uid) // Use user.uid here
          .collection("UserBooking")
          .add(booking.toMap());

      final bookingId = docRef.id;
      booking.bookingId = bookingId;

      // Update the 'bookingId' field in Firestore
      await docRef.update({'bookingId': bookingId});

      return bookingId;
    } catch (e) {
      print('Error booking product: $e');
      // Handle the error as needed
    }
  }
}

class singleProductBookingPaymentpage extends StatefulWidget {
  const singleProductBookingPaymentpage({
    Key? key,
    required this.amount,
    required this.product,
    required this.selectedQuantity,
  }) : super(key: key);

  final double amount;
  final Product product;
  final int selectedQuantity;

  @override
  State<singleProductBookingPaymentpage> createState() => _paymentState();
}

class _paymentState extends State<singleProductBookingPaymentpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PayPal Integration'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Text(
                  'Unfortunately, you are required to make your payment through PayPal in USD. All discounts have been applied. The option to make the payment in LKR will be available after a few days. Similarly, card payments will also be accepted after the same period.',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 17.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    height: 1.5,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => UsePaypal(
                          sandboxMode: true,
                          clientId: "${Constants.clientId}",
                          secretKey: "${Constants.secretKey}",
                          returnURL: "${Constants.returnURL}",
                          cancelURL: "${Constants.cancelURL}",
                          transactions: [
                            {
                              "amount": {
                                "total": widget.amount
                                    .toString(), // Convert amount to String
                                "currency": "USD",
                              },
                            }
                          ],
                          note: "Contact us for any questions on your order.",
                          onSuccess: (Map params) async {
                            print("onSuccess: $params");
                            // Perform actions after a successful PayPal transaction
                            _handleBookNow();
                          },
                          onError: (error) {
                            print("onError: $error");
                          },
                          onCancel: (params) {
                            print('cancelled: $params');
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Set button color
                    padding: EdgeInsets.all(16.0),
                  ),
                  child: Text(
                    'Pay With PayPal',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProductQuantities(
      Product product, int bookedQuantity) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    DocumentReference?
        productDoc; // Declare productDoc outside the if-else block

    try {
      if (widget.product.Category.trim() == "equipments") {
        productDoc = firestore
            .collection('Equipments')
            .doc("equipments")
            .collection('Items')
            .doc(product.productId);
      } else {
        productDoc = firestore
            .collection('Plants')
            .doc(widget.product.Category)
            .collection('Items')
            .doc(product.productId);
      }

      final docSnapshot = await productDoc.get();

      if (docSnapshot.exists) {
        // Get the current available quantity from the Firestore document
        int currentAvailableQuantity =
            int.parse(docSnapshot['quantity'] ?? '0');

        // Calculate the new available quantity after deducting the selected quantity
        int newAvailableQuantity = currentAvailableQuantity - bookedQuantity;

        // Add the update operation to the batch
        batch.update(productDoc, {'quantity': newAvailableQuantity.toString()});

        // Update the product's availableQuantity property in memory to reflect the change
        product.quantity = newAvailableQuantity;
      }
    } catch (error) {
      print('Error updating quantity for ${product.name}: $error');
      // Handle the error as needed
    }

    // Commit the batch write
    try {
      await batch.commit();
    } catch (error) {
      print('Error committing batch write: $error');
      // Handle the error as needed
    }
  }

  Future<Map<String, double>> fetchPercentages() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final Map<String, double> percentages = {};

    try {
      final DocumentReference docRef =
          _firestore.collection('offers').doc('percentages');

      final DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        final double equipmentPercentage = data['equipmentPercentage'] ?? 0.0;
        final double plantsPercentage = data['plantsPercentage'] ?? 0.0;

        percentages['equipmentPercentage'] = equipmentPercentage;
        percentages['plantsPercentage'] = plantsPercentage;
      }
    } catch (e) {
      print('Error fetching data: $e');
    }

    return percentages;
  }

  void _handleBookNow() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      // Fetch the percentages data
      final percentages = await fetchPercentages();

      // Use the fetched values to calculate the adjusted total
      double equipmentPercentage = percentages['equipmentPercentage'] ?? 0.0;
      double plantsPercentage = percentages['plantsPercentage'] ?? 0.0;

      // Declare the adjustedTotal variable outside of the if-else block
      double adjustedTotal;

      if (widget.product.Category.trim() == "equipments") {
        adjustedTotal = (widget.product.price) -
            (widget.product.price * equipmentPercentage / 100.0);
      } else {
        adjustedTotal = (widget.product.price) -
            (widget.product.price * plantsPercentage / 100.0);
      }

      final Booking booking = Booking(
        status: "pending",
        payment: "incomplete",
        category: widget.product.Category,
        image_url: widget.product.imageURL,
        name: widget.product.name,
        total: adjustedTotal,
        quantity: widget.selectedQuantity,
        email: user.email,
        productId: widget.product.productId,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );

      final bookingService = BookingService();

      await bookingService.bookProduct(booking);

      // Update the product quantity in Firestore and in memory
      await _updateProductQuantities(widget.product, widget.selectedQuantity);

      // Query for documents where status is "pending" and payment is "incomplete"
      final QuerySnapshot userBookingsQuery = await _firestore
          .collection('Booking')
          .doc(user.uid)
          .collection("UserBooking")
          .where('status', isEqualTo: 'pending')
          .where('payment', isEqualTo: 'incomplete')
          .get();

      for (QueryDocumentSnapshot doc in userBookingsQuery.docs) {
        // Update the payment status to "complete"
        await doc.reference.update({'payment': 'complete'});
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking successful'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => home()),
    );
  }
}
