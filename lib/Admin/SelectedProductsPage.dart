import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Pages/Product.dart';
import 'SaleDetails.dart';

class SelectedProductsPage extends StatefulWidget {
  late final List<Product> selectedProducts;

  SelectedProductsPage({required this.selectedProducts});

  @override
  _SelectedProductsPageState createState() => _SelectedProductsPageState();
}

class _SelectedProductsPageState extends State<SelectedProductsPage> {
  void _removeProductAtIndex(int index) {
    setState(() {
      widget.selectedProducts.removeAt(index);
    });
  }

  double _discountPercentage = 0.0;
  double _totalAmount = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selected Products'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.selectedProducts.isNotEmpty)
              Container(
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.selectedProducts.length,
                  itemBuilder: (context, index) {
                    final product = widget.selectedProducts[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        leading: Image.network(product.imageURL),
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Price: Rs ${product.price.toStringAsFixed(2)}'),
                            Text('Quantity: ${product.quantity}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _removeProductAtIndex(index);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showDiscountDialog();
                  },
                  child: Text('Add Discount'),
                ),
                ElevatedButton(
                  onPressed: _calculateTotalAmount,
                  child: Text('Calculate Total Amount'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Container(
                child: Text('Total Amount: Rs $_totalAmount',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            Center(
              child: Container(
                child: Text('Discount Percentage: $_discountPercentage%',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 35.0, vertical: 10),
              child: Center(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                      'Total Amount with Discount: Rs ${_totalAmountWithDiscount.toStringAsFixed(2)}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      textAlign: TextAlign.center),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(35.0),
              child: Center(
                child: Container(
                  child: ElevatedButton(
                    onPressed: _handlePaymentComplete,
                    child: Text('Payment Complete'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiscountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double selectedDiscount = _discountPercentage;
        return AlertDialog(
          title: Text('Add Discount Percentage'),
          content: TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              selectedDiscount = double.tryParse(value) ?? 0.0;
            },
            decoration: InputDecoration(labelText: 'Discount Percentage (%)'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _discountPercentage = selectedDiscount;
                });
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _calculateTotalAmount() {
    double total = 0.0;
    for (final product in widget.selectedProducts) {
      total += product.price * product.quantity;
    }
    _totalAmount = total;
    setState(() {});
  }

  double get _totalAmountWithDiscount {
    return _totalAmount - (_totalAmount * (_discountPercentage / 100));
  }

  Future<void> _updateProductQuantities() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // Create a copy of the selectedProducts list to avoid concurrent modification
    List<Product> selectedProductsCopy = List.from(widget.selectedProducts);

    for (final product in selectedProductsCopy) {
      try {
        final productDoc = firestore
            .collection('Equipments')
            .doc("equipments") // Use the category from the product
            .collection('Items')
            .doc(product.productId);

        final docSnapshot = await productDoc.get();

        if (docSnapshot.exists) {
          // Get the current available quantity from the Firestore document
          int currentAvailableQuantity =
              int.parse(docSnapshot['quantity'] ?? '0');

          // Calculate the new available quantity after deducting the selected quantity
          int newAvailableQuantity =
              currentAvailableQuantity - product.quantity;

          // Add the update operation to the batch
          batch.update(
              productDoc, {'quantity': newAvailableQuantity.toString()});

          // Update the product's availableQuantity property in memory to reflect the change
          int selectedProductIndex = widget.selectedProducts.indexOf(product);
          widget.selectedProducts[selectedProductIndex].quantity =
              newAvailableQuantity;
        } else {
          final productDoc = firestore
              .collection('Plants')
              .doc(product.Category) // Use the category from the product
              .collection('Items')
              .doc(product.productId);

          final docSnapshot = await productDoc.get();

          if (docSnapshot.exists) {
            // Get the current available quantity from the Firestore document
            int currentAvailableQuantity =
                int.parse(docSnapshot['quantity'] ?? '0');

            // Calculate the new available quantity after deducting the selected quantity
            int newAvailableQuantity =
                currentAvailableQuantity - product.quantity;

            // Add the update operation to the batch
            batch.update(
                productDoc, {'quantity': newAvailableQuantity.toString()});

            // Update the product's availableQuantity property in memory to reflect the change
            int selectedProductIndex = widget.selectedProducts.indexOf(product);
            widget.selectedProducts[selectedProductIndex].quantity =
                newAvailableQuantity;
          }
        }
      } catch (error) {
        print('Error updating quantity for ${product.name}: $error');
        // Handle the error as needed
      }
    }

    // Commit the batch write
    try {
      await batch.commit();
    } catch (error) {
      print('Error committing batch write: $error');
      // Handle the error as needed
    }
  }

  void _handlePaymentComplete() async {
    // Calculate total amount with discount first
    double totalAmountWithDiscount = _totalAmountWithDiscount;

    // Create a SaleDetails object
    SaleDetails saleDetails = SaleDetails(
      saleId: UniqueKey()
          .toString(), // You can use any unique identifier for the sale
      totalAmountWithDiscount: _totalAmountWithDiscount,
      discountPercentage: _discountPercentage,
      products: widget.selectedProducts,
      date: DateTime.now(),
    );

    // Store the SaleDetails in Firestore
    final firestore = FirebaseFirestore.instance;
    if (widget.selectedProducts.isNotEmpty && _totalAmount != 0) {
      try {
        await firestore
            .collection('SaleDetails')
            .doc(saleDetails.saleId)
            .set(saleDetails.toMap());
      } catch (error) {
        print('Error storing SaleDetails in Firestore: $error');
        // Handle the error as needed
      }
    }

    // Show the AlertDialog to confirm payment completion
    if (_totalAmount == 0) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'First Calculate the total amount !!!..',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Ok", style: TextStyle(fontSize: 19)),
                )
              ],
            );
          });
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Payment Completed',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            content: Text(
              'Total Amount with Discount: Rs ${totalAmountWithDiscount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the AlertDialog

                  // Call the function to update the product quantities in Firestore
                  _updateProductQuantities();

                  // Reset the selected products list as the payment is complete

                  if (_totalAmount != 0) {
                    setState(() {
                      widget.selectedProducts.clear();
                      _totalAmount = 0.0;
                      _discountPercentage = 0.0;
                    });
                  }
                },
                child: Text(
                  'OK',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
