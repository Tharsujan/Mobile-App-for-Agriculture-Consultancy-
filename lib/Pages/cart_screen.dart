import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_02_final/Pages/payment.dart';
import 'Product.dart';
import 'cart.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
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

class _CartScreenState extends State<CartScreen> {
  List<CartItem> cartItems = Cart.items;
  double cardTotalAmount = Cart.getTotalAmount();
  int cardTotalQuantity = Cart.getTotalQuantity();

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

  Future<String> _bookNow() async {
    final user = FirebaseAuth.instance.currentUser;

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add products to the cart before booking.'),
          duration: Duration(seconds: 2),
        ),
      );

      return 'Booking failed';
    }

    bool bookingAllowed = await checkBookingCriteria();

    double allProductTotalWithDiscount =
        await _allProductTotalWithDiscount(user);
    double finalTotal = await getAmount(
        allProductTotalWithDiscount); // Call the getAmount method
    double convert_srilankan_ammount_to_USD = finalTotal / 340;
    String formattedAmount =
        convert_srilankan_ammount_to_USD.toStringAsFixed(2);

// Parse the formatted string back to a double
    double parsedAmount = double.parse(formattedAmount);

    if (!bookingAllowed) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Booking Criteria Not Met'),
            content: Text(
              'Kindly note that you have reached the maximum booking limit. If you would like to proceed with the booking, we kindly request you to pay the full booking amount.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => paymentpage(amount: parsedAmount),
                    ),
                  );
                },
                child: Text(
                  'Continue Booking',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );

      return 'Booking criteria not met';
    }

    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Booking'),
          content: Text('Are you sure you want to book these items?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking successful. Cart cleared.'),
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        Cart.items.clear();
        cardTotalAmount = 0;
        Cart.cartUpdatedCallback?.call();
      });

      return 'Booking successful';
    }

    return 'Booking canceled';
  }

  Future<double> _allProductTotalWithDiscount(User? user) async {
    if (user != null) {
      final percentages = await fetchPercentages();
      double plantTotal = 0.0;
      double equpmentsTotal = 0.0;
      double allProductTotalWithDiscount = 0.0; // Initialize with 0.0

      for (CartItem cartItem in cartItems) {
        Product product = cartItem.product;

        double equipmentPercentage = percentages['equipmentPercentage'] ?? 0.0;
        double plantsPercentage = percentages['plantsPercentage'] ?? 0.0;

        double adjustedTotal;

        if (cartItem.product.Category.trim() == "equipments") {
          adjustedTotal = (cartItem.product.price) -
              (cartItem.product.price * equipmentPercentage / 100.0);
          equpmentsTotal =
              (equpmentsTotal + (adjustedTotal) * cartItem.quantity);
        } else {
          adjustedTotal = (cartItem.product.price) -
              (cartItem.product.price * plantsPercentage / 100.0);
          plantTotal = (plantTotal + (adjustedTotal * cartItem.quantity));
        }
      }

      // Calculate the total with discount
      allProductTotalWithDiscount = plantTotal + equpmentsTotal;

      return allProductTotalWithDiscount;
    }

    // Return a default value if the user is null
    return 0.0;
  }

  Future<void> _processBooking(User? user) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    if (user != null) {
      final percentages = await fetchPercentages();
      double plantTotal = 0.0;
      double equpmentsTotal = 0.0;
      double allProductTotalWithDiscount;

      for (CartItem cartItem in cartItems) {
        Product product = cartItem.product;

        double equipmentPercentage = percentages['equipmentPercentage'] ?? 0.0;
        double plantsPercentage = percentages['plantsPercentage'] ?? 0.0;

        double adjustedTotal;

        if (cartItem.product.Category.trim() == "equipments") {
          adjustedTotal = (cartItem.product.price) -
              (cartItem.product.price * equipmentPercentage / 100.0);
          equpmentsTotal += adjustedTotal;
        } else {
          adjustedTotal = (cartItem.product.price) -
              (cartItem.product.price * plantsPercentage / 100.0);
          plantTotal += adjustedTotal;
        }

        Booking booking = Booking(
          status: 'pending',
          payment: 'incomplete',
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
        } catch (e) {
          print('Error booking product: $e');
        }
      }
      ////////////////////////////////////////////////////////////////////

      allProductTotalWithDiscount = plantTotal + equpmentsTotal;

      /////////////////////////////////////////////////////////////////////

      setState(() {
        Cart.items.clear();
        Cart.cartUpdatedCallback?.call();
      });
    }
  }

  Future<bool> checkBookingCriteria() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Booking')
        .doc(currentUser!.uid)
        .collection("UserBooking")
        .get();

    double totalAmount = 0.0;
    int previousTotalQuantity = 0;

    for (final QueryDocumentSnapshot doc in querySnapshot.docs) {
      final bookingData = doc.data() as Map<String, dynamic>;

      String status = bookingData['status'];
      String payment = bookingData['payment'];

      if (status == "pending" && payment == "incomplete") {
        final quantity = bookingData['quantity'] as int;
        final total = bookingData['total'] as double;

        previousTotalQuantity += quantity;
        totalAmount += total;
      }
    }

    if ((previousTotalQuantity + cardTotalQuantity) >= 16 ||
        (totalAmount + cardTotalAmount) >= 15001.0) {
      return false;
    }

    return true;
  }

  Future<double> getAmount(double allProductTotalWithDiscount) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Booking')
        .doc(currentUser!.uid)
        .collection("UserBooking")
        .get();

    double previousTotalAmount = 0.0;

    for (final QueryDocumentSnapshot doc in querySnapshot.docs) {
      final bookingData = doc.data() as Map<String, dynamic>;

      String status = bookingData['status'];
      String payment = bookingData['payment'];

      if (status == "pending" && payment == "incomplete") {
        final total = bookingData['total'] as double;

        previousTotalAmount += total;
      }
    }

    // Calculate finalTotal outside of the loop
    double finalTotal = previousTotalAmount + allProductTotalWithDiscount;
    print("wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww");
    print("wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww");
    print("wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww");
    print(allProductTotalWithDiscount);

    return finalTotal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final cartItem = cartItems[index];

          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Image.network(
                cartItem.product.imageURL,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
              title: Text(cartItem.product.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quantity: ${cartItem.quantity}'),
                  Text(
                    'Total: Rs ${(cartItem.product.price * cartItem.quantity).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              trailing: IconButton(
                onPressed: () {
                  _removeItem(cartItem);
                },
                icon: Icon(Icons.remove_shopping_cart),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: Rs ${cardTotalAmount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: _bookNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('Book now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
