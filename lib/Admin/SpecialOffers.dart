import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Offers extends StatefulWidget {
  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<Offers> {
  final plantsController = TextEditingController();
  final equipmentController = TextEditingController();

  // Initialize the stream as 'null'
  late Stream<DocumentSnapshot<Map<String, dynamic>>> offersStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream when the widget is created
    offersStream = FirebaseFirestore.instance
        .collection('offers')
        .doc('percentages')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Offers'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: offersStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!.data();
              final oldPlantsPercentage = data!['plantsPercentage'];
              final oldEquipmentPercentage = data['equipmentPercentage'];

              plantsController.text = oldPlantsPercentage.toString();
              equipmentController.text = oldEquipmentPercentage.toString();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: plantsController,
                    decoration: InputDecoration(
                      labelText: 'Plants Percentage Off',
                      hintText: oldPlantsPercentage.toString(),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: equipmentController,
                    decoration: InputDecoration(
                      labelText: 'Equipment Percentage Off',
                      hintText: oldEquipmentPercentage.toString(),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: addOffers,
                    child: Text('Update Offers'),
                  ),
                ],
              );
            } else {
              // If snapshot is loading or doesn't have data yet, show a loading indicator
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  void addOffers() {
    double plantsPercentage = double.parse(plantsController.text);
    double equipmentPercentage = double.parse(equipmentController.text);

    // Update the offers percentages in the existing document in Firestore
    FirebaseFirestore.instance.collection('offers').doc('percentages').set(
      {
        'plantsPercentage': plantsPercentage,
        'equipmentPercentage': equipmentPercentage,
      },
      SetOptions(merge: true),
    ).then((value) {
      plantsController.clear();
      equipmentController.clear();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Offers Updated'),
          content:
              Text('The offers percentages have been successfully Updated!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content:
              Text('Failed to add the offers percentages. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    });
  }
}
