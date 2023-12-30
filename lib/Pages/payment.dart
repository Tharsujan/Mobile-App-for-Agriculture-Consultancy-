import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:intl/intl.dart';
import '../authentication/screens/home.dart';
import 'Product.dart';
import 'cart.dart';
import 'constants.dart';

class paymentpage extends StatefulWidget {
  const paymentpage({super.key, required this.amount});

  final double amount;

  @override
  State<paymentpage> createState() => _paymentState();
}

class Booking {
  String status;
  String payment;
  final String category;
  final String image_url;
  final String name;
  final double total;
  final int quantity;
  var email;
  String? bookingId;
  String? productId;
  String date;

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
      'date': date,
    };
  }
}

class _paymentState extends State<paymentpage> {
  void _removeItem(CartItem cartItem) {
    setState(() {
      Cart.removeItem(cartItem.product);
      cartItems = Cart.items;
      cardTotalAmount = Cart.getTotalAmount();
      cardTotalQuantity = Cart.getTotalQuantity();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item removed from cart.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

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
                            _handleSuccess();
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

  List<CartItem> cartItems = Cart.items;
  double cardTotalAmount = Cart.getTotalAmount();
  int cardTotalQuantity = Cart.getTotalQuantity();

  Future<void> _updateProductQuantities(List<CartItem> cartItems) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    for (CartItem cartItem in cartItems) {
      try {
        final DocumentReference productDoc = FirebaseFirestore.instance
            .collection(cartItem.product.Category.trim() == "equipments"
                ? 'Equipments'
                : 'Plants')
            .doc(cartItem.product.Category.trim() == "equipments"
                ? "equipments"
                : cartItem.product.Category)
            .collection('Items')
            .doc(cartItem.product.productId);

        final docSnapshot = await productDoc.get();

        if (docSnapshot.exists) {
          int currentAvailableQuantity =
              int.parse(docSnapshot['quantity'] ?? '0');
          int newAvailableQuantity =
              currentAvailableQuantity - cartItem.quantity;

          cartItem.product.quantity = newAvailableQuantity;

          await productDoc
              .update({'quantity': newAvailableQuantity.toString()});

          print('Quantity updated successfully for ${cartItem.product.name}');
        } else {
          print('Document does not exist for ${cartItem.product.name}');
        }
      } catch (error) {
        print('Error updating quantity for ${cartItem.product.name}: $error');
      }
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

  Future<void> _handleSuccess() async {
    final user = FirebaseAuth.instance.currentUser;

    await _updateProductQuantities(cartItems);

    Booking newBooking = Booking(
      status: 'pending',
      payment: 'payment',
      category: 'Combined',
      image_url: '',
      name: 'Combined Booking',
      total: cardTotalAmount,
      quantity: cardTotalQuantity,
      email: user?.email ?? '',
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    await _processBooking(user);

    // Show a SnackBar with a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking successful'),
        duration: Duration(seconds: 2),
      ),
    );
    _removeItem(CartItem as CartItem);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => home()),
    );
  }

  Future<void> _processBooking(User? user) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    if (user != null) {
      final percentages = await fetchPercentages();

      for (CartItem cartItem in cartItems) {
        Product product = cartItem.product;

        double equipmentPercentage = percentages['equipmentPercentage'] ?? 0.0;
        double plantsPercentage = percentages['plantsPercentage'] ?? 0.0;

        double adjustedTotal;

        if (cartItem.product.Category.trim() == "equipments") {
          adjustedTotal = (cartItem.product.price) -
              (cartItem.product.price * equipmentPercentage / 100.0);
        } else {
          adjustedTotal = (cartItem.product.price) -
              (cartItem.product.price * plantsPercentage / 100.0);
        }

        Booking booking = Booking(
          status: 'pending',
          payment: 'complete',
          category: product.Category,
          image_url: product.imageURL,
          name: product.name,
          total: adjustedTotal,
          quantity: cartItem.quantity,
          email: user.email,
          productId: product.productId,
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        );

        try {
          final DocumentReference docRef = await _firestore
              .collection('Booking')
              .doc(user.uid)
              .collection("UserBooking")
              .add(booking.toMap());

          final bookingId = docRef.id;
          booking.bookingId = bookingId;

          await docRef.update({'bookingId': bookingId});

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
        } catch (e) {
          print('Error booking product: $e');
        }
      }
      setState(() {
        Cart.items.clear();
        Cart.cartUpdatedCallback?.call();
      });
    }
  }
}
