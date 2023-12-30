import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Pages/Product.dart';
import 'SelectedProductsPage.dart';
import 'SessionTimeout.dart';

class SelectProductsPage extends StatefulWidget {
  @override
  _SelectProductsPageState createState() => _SelectProductsPageState();
}

class _SelectProductsPageState extends State<SelectProductsPage> {
  String _searchQuery = '';
  List<Product> _selectedProducts = [];
  String _selectedCollection =
      'Plants'; // Default selected collection is 'Plants'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Products'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  SessionTimeout().onUserInteraction();
                  _changeCollection('Plants');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedCollection == 'Plants'
                      ? Colors.green[700]
                      : Colors.grey,
                ),
                child: Text('Plants'),
              ),
              ElevatedButton(
                onPressed: () {
                  SessionTimeout().onUserInteraction();
                  _changeCollection('Equipments');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedCollection == 'Equipments'
                      ? Colors.green[700]
                      : Colors.grey,
                ),
                child: Text('Equipments'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () {
                      SessionTimeout().onUserInteraction();
                    },
                    icon: const Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.green,
                    ),
                  ),
                ),
                hintText: 'Search ${_selectedCollection}...',
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final products = snapshot.data;

                if (products == null || products.isEmpty) {
                  return Center(
                    child: Text('No products found.'),
                  );
                }

                // Filter products based on the search query
                final filteredProducts = products
                    .where((product) => product.name
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase()))
                    .toList();

                // Products found
                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final product = filteredProducts[index];
                    return Card(
                      child: ListTile(
                        leading: Image.network(
                            product.imageURL), // Display the photo
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Available: ${product.quantity}'),
                            Text('Price: ${product.price.toStringAsFixed(2)}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            SessionTimeout().onUserInteraction();
                            _showQuantityDialog(product);
                          },
                          child: Text('Choose Quantity'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _selectedProducts.isEmpty
                ? null
                : () {
                    _showSelectedProductsPage();
                  },
            child: Text('View Selected Products'),
          ),
        ],
      ),
    );
  }

  void _changeCollection(String collection) {
    setState(() {
      _selectedCollection = collection;
      _searchQuery = ''; // Reset search query when changing collection
    });
  }

  void _showQuantityDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) {
        int selectedQuantity = 1;
        int availableQuantity = product.quantity;
        int maxAvailableQuantity = product.quantity;

        // If the product is already selected, update selectedQuantity and maxAvailableQuantity
        if (_isProductSelected(product)) {
          final selectedProduct = _selectedProducts.firstWhere(
            (selectedProduct) => selectedProduct.name == product.name,
          );

          selectedQuantity = selectedProduct.quantity + 1;
          maxAvailableQuantity = product.quantity - selectedProduct.quantity;
        }

        return AlertDialog(
          title: Text('Choose Quantity for ${product.name}'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<int>(
                value: selectedQuantity,
                onChanged: (newValue) {
                  if (newValue! > 0) {
                    setState(() {
                      selectedQuantity = newValue;
                    });
                  }
                },
                items: List.generate(maxAvailableQuantity, (index) {
                  return DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text((index + 1).toString()),
                  );
                }),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_isProductSelected(product)) {
                  final selectedProductIndex = _selectedProducts.indexWhere(
                      (selectedProduct) =>
                          selectedProduct.name == product.name);
                  _selectedProducts[selectedProductIndex].quantity =
                      selectedQuantity;
                } else {
                  _selectedProducts
                      .add(product.copyWith(quantity: selectedQuantity));
                }

                // Check if any product has a quantity greater than zero
                bool anyProductSelected =
                    _selectedProducts.any((p) => p.quantity > 0);
                setState(() {
                  // Update the button's enabled state based on whether any product is selected
                  _selectedProducts.isEmpty
                      ? _selectedProducts.isEmpty
                      : anyProductSelected;
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

  void _showSelectedProductsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SelectedProductsPage(selectedProducts: _selectedProducts),
      ),
    );
  }

  bool _isProductSelected(Product product) {
    return _selectedProducts
        .any((selectedProduct) => selectedProduct.name == product.name);
  }

  Future<List<Product>> _fetchProducts() async {
    if (_selectedCollection == 'Plants') {
      return _fetchPlants();
    } else if (_selectedCollection == 'Equipments') {
      return _fetchEquipments();
    } else {
      // Handle other cases if needed
      return [];
    }
  }

  Future<List<Product>> _fetchPlants() async {
    final List<String> categories = [
      'FloweringPlants',
      'IndoorPlants',
      'MedicinalPlants',
      'OutdoorPlants',
      'RareandExoticPlants',
    ];

    final CollectionReference plantsCollection =
        FirebaseFirestore.instance.collection('Plants');

    // Fetch products from all categories and combine them into a single list
    List<Product> allProducts = [];
    for (final category in categories) {
      final QuerySnapshot itemsQuerySnapshot =
          await plantsCollection.doc(category).collection('Items').get();
      final categoryProducts = itemsQuerySnapshot.docs
          .map((doc) => Product.fromSnapshot(doc))
          .toList();
      allProducts.addAll(categoryProducts);
    }

    return allProducts;
  }

  Future<List<Product>> _fetchEquipments() async {
    final CollectionReference equipmentsCollection =
        FirebaseFirestore.instance.collection('Equipments');

    final QuerySnapshot equipmentsQuerySnapshot =
        await equipmentsCollection.get();

    List<Product> allProducts = [];

    for (final equipmentDoc in equipmentsQuerySnapshot.docs) {
      final itemsCollection = equipmentDoc.reference.collection('Items');

      final QuerySnapshot itemsQuerySnapshot = await itemsCollection.get();
      final categoryProducts = itemsQuerySnapshot.docs
          .map((doc) => Product.fromSnapshot(doc))
          .toList();

      allProducts.addAll(categoryProducts);
    }

    return allProducts;
  }
}
