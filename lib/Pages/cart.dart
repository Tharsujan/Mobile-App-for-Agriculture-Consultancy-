import 'package:flutter/material.dart';
import 'Product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});
}

class Cart extends ChangeNotifier {
  static List<CartItem> items = [];
  static Function? cartUpdatedCallback;

  static void addToCart(Product product, int quantity) {
    final existingItemIndex =
        items.indexWhere((item) => item.product.productId == product.productId);

    if (existingItemIndex != -1) {
      // If the product is already in the cart, update the quantity
      items[existingItemIndex] = CartItem(product: product, quantity: quantity);
    } else {
      // If the product is not in the cart, add it as a new item
      items.add(CartItem(product: product, quantity: quantity));
    }

    cartUpdatedCallback?.call();
  }

  static void removeItem(Product product) {
    items.removeWhere((cartItem) => cartItem.product == product);
    cartUpdatedCallback?.call();
  }

  static double getTotalAmount() {
    double total = 0;
    for (var item in items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  static int getTotalQuantity() {
    int totalQuantity = 0;
    for (var item in items) {
      totalQuantity += item.quantity;
    }
    return totalQuantity;
  }
}
