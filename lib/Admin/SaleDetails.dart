import '../Pages/Product.dart';

class SaleDetails {
  final String saleId;
  final double totalAmountWithDiscount;
  final double discountPercentage;
  final List<Product> products;
  final DateTime date;

  SaleDetails({
    required this.saleId,
    required this.totalAmountWithDiscount,
    required this.discountPercentage,
    required this.products,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'saleId': saleId,
      'totalAmountWithDiscount': totalAmountWithDiscount,
      'discountPercentage': discountPercentage,
      'products': products.map((product) => product.toMap()).toList(),
      'date': date,
    };
  }
}
