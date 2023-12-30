import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'SessionTimeout.dart';

class SeeOrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('See Orders'),
      ),
      body: OrdersList(),
    );
  }
}

class OrdersList extends StatefulWidget {
  @override
  _OrdersListState createState() => _OrdersListState();
}

class _OrdersListState extends State<OrdersList> {
  String _searchQuery = '';
  List<DocumentSnapshot> _ordersList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup("UserBooking")
          .where('status', isEqualTo: 'pending')
          .get();

      setState(() {
        _ordersList = snapshot.docs;
        _loading = false; // Set loading to false after data is loaded
      });
    } catch (e) {
      print('Error loading orders: $e');
      // Handle the error, show a message, or retry the operation
      setState(() {
        _loading = false; // Set loading to false even in case of an error
      });
    }
  }

  List<DocumentSnapshot> _filterOrders() {
    if (_searchQuery.isEmpty) {
      return _ordersList;
    }

    return _ordersList.where((order) {
      final orderData = order.data() as Map<String, dynamic>;
      final userEmail = orderData['UserEmail'].toString().toLowerCase();
      final searchQuery = _searchQuery.toLowerCase();

      return userEmail.contains(searchQuery);
    }).toList();
  }

  Future<void> _markAsFinished(DocumentSnapshot orderDocument) async {
    bool confirmAction = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Finished Order",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text("Are you sure you want to finished this order?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                SessionTimeout().onUserInteraction();

                Navigator.of(context).pop(false);
              },
              child: Text(
                'No',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                SessionTimeout().onUserInteraction();

                Navigator.of(context).pop(true);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmAction ?? true) {
      await orderDocument.reference.update({'payment': 'complete'});
      await orderDocument.reference.update({'status': 'complete'});

      await _loadOrders();
    }
  }

  Future<void> _cancellOrderAction(DocumentSnapshot orderDocument) async {
    bool confirmAction = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Cancel Order",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text("Are you sure you want to cancel this order?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                SessionTimeout().onUserInteraction();

                Navigator.of(context).pop(false);
              },
              child: Text(
                'No',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                SessionTimeout().onUserInteraction();

                Navigator.of(context).pop(true);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmAction ?? true) {
      if (orderDocument['status'] == 'pending') {
        await orderDocument.reference.update({'status': 'cancelled'});
      }

      await _loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _filterOrders();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search using Customer email..',
              suffixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: _loading
              ? Center(child: CircularProgressIndicator()) // Loading indicator
              : filteredOrders.isEmpty
                  ? Center(
                      child: Text(
                        'No matching orders found',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot userBookingDocument =
                            filteredOrders[index];
                        OrderModel order = OrderModel(
                          userEmail: userBookingDocument['UserEmail'],
                          imageUrl: userBookingDocument['image_url'],
                          name: userBookingDocument['name'],
                          quantity: userBookingDocument['quantity'],
                          payment: userBookingDocument['payment'],
                        );

                        return Card(
                          elevation: 3,
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(
                              '${order.userEmail}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name: ${order.name}'),
                                Text('Quantity: ${order.quantity}'),
                                Text('Payment: ${order.payment}'),
                              ],
                            ),
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(order.imageUrl ?? ''),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    SessionTimeout().onUserInteraction();

                                    _markAsFinished(userBookingDocument);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: Text('Finished'),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    _cancellOrderAction(userBookingDocument);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class OrderModel {
  final String? userEmail;
  final String? imageUrl;
  final String? name;
  final int? quantity;
  final String? payment;
  final String? status;

  OrderModel(
      {this.userEmail,
      this.imageUrl,
      this.name,
      this.quantity,
      this.payment,
      this.status});
}
