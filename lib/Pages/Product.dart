import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? productId;
  final String name;
  final double price;
  final String imageURL;
  final String description;
  int quantity;
  final DateTime date;
  final String Category;

  Product(
      {required this.name,
      required this.price,
      required this.imageURL,
      required this.description,
      required this.quantity,
      required this.date,
      required this.Category,
      this.productId});

  factory Product.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    final name = data['name'] as String? ?? '';
    final Category = data['Category'] as String? ?? '';
    final priceString = data['price'] as String? ?? '';
    final price = double.tryParse(priceString) ?? 0.0;
    final imageURL = data['image_url'] as String? ?? '';
    final description = data['description'] as String? ?? '';
    final quantityString = data['quantity'] as String? ?? '';
    final quantity = int.tryParse(quantityString) ?? 0;
    final dateTimestamp = data['date'] as Timestamp? ?? Timestamp.now();
    final date = dateTimestamp.toDate();
    final productId = data['productId'] as String? ?? '';

    return Product(
      name: name,
      price: price,
      imageURL: imageURL,
      description: description,
      quantity: quantity,
      date: date,
      productId: productId,
      Category: Category,
    );
  }

  // Define the copyWith method to create a new Product with specific properties modified
  Product copyWith({
    int? quantity,
  }) {
    return Product(
        name: this.name,
        price: this.price,
        imageURL: this.imageURL,
        description: this.description,
        quantity: quantity ?? this.quantity,
        date: this.date,
        productId: productId,
        Category: Category);
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'Category': Category,
    };
  }
}
