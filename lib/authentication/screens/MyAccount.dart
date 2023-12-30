import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserEditProfilePage extends StatefulWidget {
  @override
  _UserEditProfilePageState createState() => _UserEditProfilePageState();
}

class _UserEditProfilePageState extends State<UserEditProfilePage> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  final User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  bool _isEditing = false;
  String _existingUsername = '';
  String _existingPhoneNumber = '';
  String _joinDate = '';
  String _email = '';
  String _profileImageUrl = '';
  bool _changePassword = false;
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  @override
  void initState() {
    super.initState();
    // Fetch the existing user details from Firestore when the page loads
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('Email', isEqualTo: currentUser!.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs[0].data();
        setState(() {
          _existingUsername = userData['UserName'];
          _existingPhoneNumber = userData['PhoneNumber'];
          _email = userData['Email'];
          _joinDate = userData['Date'];
          _profileImageUrl =
              userData['ProfileUrl'] ?? ''; // Added for profile image
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Account'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'My Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                _isEditing
                    ? _buildEditableForm()
                    : _buildProfileDetails(context),
                SizedBox(height: 20),
                _buildEditButton(),
                SizedBox(height: 20),
                if (_isEditing) _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context) {
    // Fetch and display the existing user details (username and phone number)
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: _profileImageUrl.isNotEmpty
                    ? NetworkImage(_profileImageUrl) as ImageProvider<Object>?
                    : AssetImage('assets/category/white.jpg'),
              ),
            ),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  _changeProfilePhoto(context);
                  // Call the method to change the profile photo
                },
                icon: Icon(Icons.camera_alt),
                label: Text('Change profile Photo'),
              ),
            ),
            SizedBox(height: 16),
            _buildProfileInfoField('User name ', _existingUsername),
            _buildProfileInfoField('Contact Number ', _existingPhoneNumber),
            _buildProfileInfoField('Email address ', _email),
            _buildProfileInfoField('Joined date ', _joinDate),
          ],
        ),
      ),
    );
  }

  Future<void> _changeProfilePhoto(BuildContext context) async {
    // Show an alert box to confirm the update
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Profile Photo'),
        content: Text('Do you want to update your profile photo?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pop(false); // Dismiss the alert box and pass false
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pop(true); // Dismiss the alert box and pass true
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Get image from gallery or camera
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('UserProfilePhoto')
            .child(DateTime.now().toString());

        try {
          final UploadTask uploadTask =
              storageRef.putFile(File(pickedFile.path));
          final TaskSnapshot uploadSnapshot =
              await uploadTask.whenComplete(() {});

          // Get the download URL
          String downloadURL = await storageRef.getDownloadURL();

          // Update profile image URL in user details
          if (downloadURL != null) {
            setState(() {
              _profileImageUrl = downloadURL;
            });

            // Update profile image URL in Firestore
            try {
              await FirebaseFirestore.instance
                  .collection('Users')
                  .where('Email', isEqualTo: currentUser!.email)
                  .get()
                  .then((querySnapshot) {
                if (querySnapshot.docs.isNotEmpty) {
                  var docId = querySnapshot.docs[0].id;
                  FirebaseFirestore.instance
                      .collection('Users')
                      .doc(docId)
                      .update({
                    'ProfileUrl': downloadURL,
                  });
                }
              });
            } catch (e) {
              print('Error updating profile image URL in Firestore: $e');
            }

            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(content: Text('Profile Photo updated successfully.')),
            );
          }
        } catch (e) {
          print('Error uploading profile photo: $e');
        }
      }
    }
  }

  Widget _buildProfileInfoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableForm() {
    // Form fields to edit the username and phone number
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _phoneNumberController,
            decoration: InputDecoration(
              labelText: 'Contact Number',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _changePassword,
                onChanged: (value) {
                  setState(() {
                    _changePassword = value!;
                  });
                },
              ),
              Text('Change Password'),
            ],
          ),
          if (_changePassword) ...[
            SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _currentPassword = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _newPassword = value;
                });
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a new password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters long';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
                errorText: _newPassword.isNotEmpty && _newPassword.length < 8
                    ? 'Password must be at least 8 characters long'
                    : null,
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _confirmPassword = value;
                });
              },
              validator: (value) {
                if (value != _newPassword) {
                  return 'Passwords do not match';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
                errorText: _confirmPassword.isNotEmpty &&
                        _confirmPassword != _newPassword
                    ? 'Passwords do not match'
                    : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    // Toggle the editing state when the "Edit Profile" button is clicked
    return Center(
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                // If entering editing mode, populate the fields with the existing data
                if (_isEditing) {
                  _usernameController.text =
                      _existingUsername; // Replace [existing_username] with actual username data
                  _phoneNumberController.text =
                      _existingPhoneNumber; // Replace [existing_phone_number] with actual phone number data
                }
              });
            },
            child: Text(
              _isEditing ? 'Cancel' : 'Edit Details',
              style: TextStyle(
                color: _isEditing
                    ? Colors.red
                    : Colors
                        .white, // Set text color based on the _isEditing condition
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    // Save the changes to Firestore when the "Update changes" button is clicked
    return ElevatedButton(
      onPressed: () async {
        // Validate form fields
        if (_usernameController.text.trim().isEmpty ||
            _phoneNumberController.text.trim().isEmpty) {
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text('Please fill in all fields.')),
          );
          return;
        }

        // Verify the current password if the user wants to change it
        if (_changePassword) {
          try {
            AuthCredential credential = EmailAuthProvider.credential(
              email: currentUser!.email!,
              password: _currentPassword,
            );
            await currentUser!.reauthenticateWithCredential(credential);
          } catch (e) {
            print('Error verifying current password: $e');
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(content: Text('Incorrect current password.')),
            );
            return;
          }

          // If the new password is not empty and matches the confirm password
          if (_newPassword.isNotEmpty && _newPassword == _confirmPassword) {
            // Change the password using the Firebase Auth API
            try {
              await currentUser!.updatePassword(_newPassword);
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(content: Text('Password changed successfully.')),
              );
            } catch (e) {
              print('Error changing password: $e');
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                    content:
                        Text('An error occurred. Unable to change password.')),
              );
              return;
            }
          }
        }

        // Save the changes to Firestore using the email as the unique identifier
        try {
          await FirebaseFirestore.instance
              .collection('Users')
              .where('Email', isEqualTo: currentUser!.email)
              .get()
              .then((querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              var docId = querySnapshot.docs[0].id;
              FirebaseFirestore.instance.collection('Users').doc(docId).update({
                'UserName': _usernameController.text.trim(),
                'PhoneNumber': _phoneNumberController.text.trim(),
              });
            }
          });

          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(content: Text('Profile updated successfully.')),
          );
        } catch (e) {
          print('Error updating profile: $e');
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
                content: Text('An error occurred. Please try again later.')),
          );
        }
      },
      child: Center(child: const Text('Update Details')),
    );
  }
}
