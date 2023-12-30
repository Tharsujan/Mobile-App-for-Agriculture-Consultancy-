import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserModel {
  // Helper method to convert DateTime to String in a specific format
  String formatDate(DateTime? dateTime) {
    if (dateTime != null) {
      final formattedDate = DateFormat('yyyy-MM-dd')
          .format(dateTime); // Customize the date format here
      return formattedDate;
    }
    return "";
  }

  final String? uid;
  final String username;
  final String email;
  final String phonenumber;
  final String? downloadUrl;
  final String? ProfileUrl;
  final DateTime formattedDate;
  final String role;
  final bool ActiveUser;

  UserModel({
    this.uid,
    required this.username,
    required this.email,
    required this.phonenumber,
    this.downloadUrl,
    required this.ActiveUser,
    required this.role,
    this.ProfileUrl,
    DateTime? formattedDate,
  }) : formattedDate = formattedDate ?? DateTime.now();

  toJson() {
    return {
      "uid": uid,
      "UserName": username,
      "Email": email,
      "PhoneNumber": phonenumber,
      "qrCodeUrl": downloadUrl,
      "ProfileUrl": ProfileUrl,
      "Date": formatDate(formattedDate),
      "role": role,
      "ActiveUser": ActiveUser
    };
  }

  // Step 1- Map user fetched from Firebase to UserModel

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;

    return UserModel(
        uid: document.id,
        email: data["Email"],
        username: data["UserName"],
        phonenumber: data["PhoneNumber"],
        ActiveUser: data["ActiveUser"],
        role: data["role"]);
  }
}
