import 'package:flutter/material.dart';
import '../authentication/screens/ProductListPage.dart';

class HorizontalList extends StatelessWidget {
  const HorizontalList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Category(
            imageLocation: 'assets/category/equipment.png',
            imageCaption: 'Equipments',
            onTap: () {
              // Handle Equipment category tap
              navigateToProductList(context, 'equipments');
            },
          ),
          Category(
            imageLocation: 'assets/category/floweringplant.png',
            imageCaption: 'Flowering Plants',
            onTap: () {
              // Handle Flowering Plants category tap
              navigateToProductList(context, 'FloweringPlants');
            },
          ),
          Category(
            imageLocation: 'assets/category/indoor.png',
            imageCaption: 'Indoor Plants',
            onTap: () {
              // Handle Indoor Plants category tap
              navigateToProductList(context, 'IndoorPlants');
            },
          ),
          Category(
            imageLocation: 'assets/category/medicineplants.png',
            imageCaption: 'Medicinal Plants',
            onTap: () {
              // Handle Medicinal Plants category tap
              navigateToProductList(context, 'MedicinalPlants');
            },
          ),
          Category(
            imageLocation: 'assets/category/outdoor.png',
            imageCaption: 'Outdoor Plants',
            onTap: () {
              // Handle Exotic Plants category tap
              navigateToProductList(context, 'OutdoorPlants');
            },
          ),
          Category(
            imageLocation: 'assets/category/rareplant.png',
            imageCaption: 'Rare Plants',
            onTap: () {
              // Handle Exotic Plants category tap
              navigateToProductList(context, 'RareandExoticPlants');
            },
          ),
        ],
      ),
    );
  }

  void navigateToProductList(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListPage(category: category),
      ),
    );
  }
}

class Category extends StatelessWidget {
  final String imageLocation;
  final String imageCaption;
  final VoidCallback onTap;

  const Category({
    required this.imageLocation,
    required this.imageCaption,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  imageLocation,
                  width: 100.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                imageCaption,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
