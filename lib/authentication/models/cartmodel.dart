import 'package:cloud_firestore/cloud_firestore.dart';

class CartModel {
  final String userId;
  final String name;
  final double price;
  final int quantity;
  final String imageURL;

  CartModel({
    required this.userId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageURL,
  });
}
