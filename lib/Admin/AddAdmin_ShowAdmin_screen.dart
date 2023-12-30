import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AdminRegister.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Details'),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .where('role', isEqualTo: 'admin') // Filter by role
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error fetching data'),
              );
            } else {
              final adminDocs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: adminDocs.length,
                itemBuilder: (context, index) {
                  final adminData =
                      adminDocs[index].data() as Map<String, dynamic>;
                  final adminName = adminData['UserName'] ?? 'Unknown Admin';
                  final adminJoinDate = adminData['Date'] ?? 'Unknown Date';
                  final email = adminData['Email'];
                  final profilePhotoURL = adminData['ProfileUrl'] ??
                      'https://example.com/default_profile_photo.jpg';
                  final phoneNumber = adminData['PhoneNumber'] ?? 'N/A';

                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(profilePhotoURL),
                      ),
                      title: Text(
                        adminName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text(
                            'Join Date: $adminJoinDate',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Contact Number: $phoneNumber',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'email: $email',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: Container(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminRegister(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.green[700], // Change the button's background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
          child: Text(
            'Add new Admin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
