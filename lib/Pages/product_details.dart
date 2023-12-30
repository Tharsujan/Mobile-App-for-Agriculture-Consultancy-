import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Product.dart';
import 'bookingPayment.dart';
import 'cart.dart';

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

class ProductDetails extends StatefulWidget {
  final Product product;

  const ProductDetails({required this.product});

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int selectedQuantity = 1;

  void _addToCart() {
    Cart.addToCart(widget.product, selectedQuantity);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showImageInFullScreen() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Image.network(
            widget.product.imageURL,
            fit: BoxFit.contain,
          ),
        );
      },
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
      // Reference to the "offers" collection and "percentages" document
      final DocumentReference docRef =
          _firestore.collection('offers').doc('percentages');

      // Get the document data
      final DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        // Access the fields "equipmentPercentage" and "plantsPercentage"
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
        quantity: selectedQuantity,
        email: user.email,
        productId: widget.product.productId,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );

      final bookingService = BookingService();
      final isAllowed = await checkBookingCriteria(booking);

      if (isAllowed) {
        final confirmed = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Booking'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to book $selectedQuantity ${widget.product.name}?',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Return false to indicate cancellation
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context)
                        .pop(true); // Return true to indicate confirmation
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Book'),
                ),
              ],
            );
          },
        );

        if (confirmed == true) {
          try {
            await bookingService.bookProduct(booking);

            // Update the product quantity in Firestore and in memory
            await _updateProductQuantities(widget.product, selectedQuantity);

            // Show the success message using ScaffoldMessenger
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Successfully booked $selectedQuantity ${widget.product.name}',
                ),
                duration: Duration(seconds: 2),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error booking ${widget.product.name}'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        double previousTotalAmount = await getAmount();
        double finalTotal = (previousTotalAmount +
            adjustedTotal * selectedQuantity); // Call the getAmount method
        double convert_srilankan_ammount_to_USD = finalTotal / 340;
        String formattedAmount =
            convert_srilankan_ammount_to_USD.toStringAsFixed(2);

// Parse the formatted string back to a double
        double parsedAmount = double.parse(formattedAmount);
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => singleProductBookingPaymentpage(
                            amount: parsedAmount,
                            product: widget.product,
                            selectedQuantity: selectedQuantity),
                      ),
                    );
                  },
                  child: Text(
                    'Continue Booking',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Add your logic for the "Cancel" option here
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<bool> checkBookingCriteria(Booking previousBooking) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Fetch the user's existing bookings
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Booking')
        .doc(currentUser!.uid)
        .collection("UserBooking")
        .get();

    double pewviousTotalAmount = 0.0;
    int previousTotalQuantity = 0;

    for (final QueryDocumentSnapshot doc in querySnapshot.docs) {
      final bookingData = doc.data() as Map<String, dynamic>;

      String status = bookingData['status'];
      String payment = bookingData['payment'];
      if (status == "pending" && payment == "incomplete") {
        final quantity =
            (bookingData['quantity'] ?? 0) as int; // Ensure it's an int
        final total =
            (bookingData['total'] ?? 0) as double; // Ensure it's a double

        previousTotalQuantity += quantity;
        pewviousTotalAmount += total;
      }
    }
    double selectProductPrice = (widget.product.price * selectedQuantity);
    // Calculate the total amount of the new booking as a double

    if ((previousTotalQuantity + selectedQuantity) >= 16 ||
        (pewviousTotalAmount + selectProductPrice) >= 15001.0) {
      return false; // Criteria not met
    }
    // print("QQQQQQQ");
    // print(totalQuantity + newBooking.quantity);
    // print("QQQQQQQ");
    // print(totalAmount + newBookingTotal);

    return true; // Criteria met, booking is allowed
  }

  Future<double> getAmount() async {
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

    return previousTotalAmount;
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = selectedQuantity * widget.product.price;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        children: [
          GestureDetector(
            onTap: _showImageInFullScreen,
            child: Container(
              height: 300.0,
              child: GridTile(
                child: Container(
                  color: Colors.white,
                  child: Image.network(
                    widget.product.imageURL,
                    fit: BoxFit.cover,
                  ),
                ),
                footer: Container(
                  color: Colors.white70,
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Price: Rs ${widget.product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        '${widget.product.quantity} Available',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: selectedQuantity,
                  onChanged: (newValue) {
                    setState(() {
                      selectedQuantity = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    hintText: 'Select Quantity',
                  ),
                  items: List.generate(
                    widget.product.quantity.toInt(),
                    (index) => DropdownMenuItem<int>(
                      value: index + 1,
                      child: Text('${index + 1}'),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.0),
            ],
          ),
          SizedBox(height: 16.0),
          Text(
            'Total Without Discount: Rs ${totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleBookNow,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    elevation: 0.2,
                  ),
                  child: Text("Book Now"),
                ),
              ),
              IconButton(
                onPressed: _addToCart,
                icon: Icon(Icons.add_shopping_cart),
                color: Colors.green,
              ),
            ],
          ),
          Divider(color: Colors.green),
          ListTile(
            title: Text(
              "Description",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              widget.product.description,
            ),
          ),
        ],
      ),
    );
  }
}
