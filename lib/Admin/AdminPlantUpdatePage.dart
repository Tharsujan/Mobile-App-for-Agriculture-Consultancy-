import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AdminPlantUpdatePage extends StatefulWidget {
  final String category;
  final String plantId;

  AdminPlantUpdatePage({
    required this.category,
    required this.plantId,
  });

  @override
  _AdminPlantUpdatePageState createState() => _AdminPlantUpdatePageState();
}

class _AdminPlantUpdatePageState extends State<AdminPlantUpdatePage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  // Function to handle selecting a new image from gallery or camera

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Upload the image to Firebase Storage
      var storageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('plants/${widget.plantId}.jpg');
      await storageRef.putFile(File(pickedFile.path));
      // Get the updated image URL
      String imageUrl = await storageRef.getDownloadURL();
      // Update the Firestore document with the new image URL
      FirebaseFirestore.instance
          .collection('Plants')
          .doc(widget.category.replaceAll(' ', ''))
          .collection('Items')
          .doc(widget.plantId)
          .update({'image_url': imageUrl});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Plant Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Plants')
            .doc(widget.category.replaceAll(' ', ''))
            .collection('Items')
            .doc(widget.plantId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final plantData = snapshot.data!.data() as Map<String, dynamic>;
          _nameController.text = plantData['name'];
          _priceController.text = plantData['price'].toString();
          _quantityController.text = plantData['quantity'].toString();
          _descriptionController.text = plantData['description'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _pickImage, // Call the image update function
                      child: SizedBox(
                        height: 200,
                        child: Center(
                          child: Image.network(
                            plantData['image_url'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Name:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter plant name',
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Price:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter plant price',
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Quantity:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter plant quantity',
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Description:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter plant description',
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Update the plant details
                        FirebaseFirestore.instance
                            .collection('Plants')
                            .doc(widget.category.replaceAll(' ', ''))
                            .collection('Items')
                            .doc(widget.plantId)
                            .update({
                          'name': _nameController.text,
                          'price': _priceController.text.toString(),
                          'quantity': _quantityController.text.toString(),
                          'description': _descriptionController.text,
                        }).then((_) {
                          // Successfully updated the plant details
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Plant details updated.'),
                            ),
                          );
                        }).catchError((error) {
                          // Error occurred while updating the plant details
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating plant details.'),
                            ),
                          );
                        });
                      },
                      child: Center(child: Text('Update')),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
