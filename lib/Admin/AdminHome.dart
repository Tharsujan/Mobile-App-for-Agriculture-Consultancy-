import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_02_final/authentication/screens/login.dart';
import 'package:project_02_final/Admin/ManageUserPage.dart';
import 'package:project_02_final/Admin/SpecialOffers.dart';
import 'AddAdmin_ShowAdmin_screen.dart';

import 'AdminManagePage.dart';
import 'Adminchatscreen.dart';
import 'ConsultancyBookingDetailsPage.dart';
import 'QrScannerhomepage.dart';
import 'RatingListScreen.dart';
import 'SeeOrdersPage.dart';
import 'SelectProductsPage.dart';
import 'SessionTimeout.dart';
import 'UploadPlantsEquipmentsPage.dart';
import 'adminEditProfile.dart';
import 'fcm_token_page.dart';
import 'notification_admin.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late String UserName = "";
  late String ProfileUrl = "";

  @override
  void initState() {
    super.initState();

    // Fetch user data
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
        UserName = userData['UserName'] ?? 'Unknown User';
        ProfileUrl = userData['ProfileUrl'] ??
            'https://example.com/default_profile_photo.jpg';

        // Call setState to update the UI with the fetched data
        setState(() {});
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  title: Text(
                    'Hello, $UserName',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Have a nice day',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: Colors.white54),
                  ),
                  trailing: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(ProfileUrl),
                  ),
                ),
                const SizedBox(height: 30)
              ],
            ),
          ),
          Container(
            color: Theme.of(context).primaryColor,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(200),
                ),
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 40,
                mainAxisSpacing: 30,
                children: [
                  GestureDetector(
                    onTap: () {
                      SessionTimeout().onUserInteraction();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QrScannerHome(),
                        ),
                      );
                    },
                    child: itemDashboard(
                      'QR Scanner',
                      CupertinoIcons.qrcode_viewfinder,
                      Colors.black45,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SessionTimeout().onUserInteraction();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectProductsPage(),
                        ),
                      );
                    },
                    child: itemDashboard(
                      'Bill',
                      CupertinoIcons.creditcard,
                      Colors.lightGreen,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SessionTimeout().onUserInteraction();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeeOrdersPage(),
                        ),
                      );
                    },
                    child: itemDashboard(
                      'See Orders',
                      CupertinoIcons.square_list,
                      Colors.teal,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SessionTimeout().onUserInteraction();
                      String bookingId =
                          "ABC345"; // Replace with the actual booking ID
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConsultancyBookingDetailsPage(),
                        ),
                      );
                    },
                    child: itemDashboard(
                      'Consultancy Booking',
                      CupertinoIcons.book_circle,
                      Colors.teal,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SessionTimeout().onUserInteraction();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminChatScreen(),
                        ),
                      );
                    },
                    child: itemDashboard(
                      'Chat',
                      CupertinoIcons.bolt_horizontal_circle,
                      Colors.purple,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SessionTimeout().onUserInteraction();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FcmTokenList(), //Admin chat home page
                        ),
                      ); // Handle onTap for Chat
                      // Add your code here
                    },
                    child: itemDashboard(
                      'FCM Token',
                      CupertinoIcons.device_desktop,
                      Colors.lightGreen,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SessionTimeout().onUserInteraction();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NotificationAdmin(), //Admin chat home page
                        ),
                      ); // Handle onTap for Chat
                      // Add your code here
                    },
                    child: itemDashboard(
                      'Notification',
                      CupertinoIcons.mail,
                      Colors.greenAccent,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SessionTimeout().onUserInteraction();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminManagePage(),
                        ),
                      );
                    },
                    child: itemDashboard(
                      'Manage Plants and Equipments',
                      CupertinoIcons.doc_append,
                      Colors.grey,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SessionTimeout().onUserInteraction();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UploadPlantsEquipmentsPage(),
                        ),
                      );
                    },
                    child: itemDashboard(
                      'Upload Plants and Equipments',
                      CupertinoIcons.up_arrow,
                      Colors.brown,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SessionTimeout().onUserInteraction();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Offers(),
                        ),
                      );
                    },
                    child: itemDashboard(
                      'Special Offers',
                      CupertinoIcons.tag,
                      Colors.blue,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SessionTimeout().onUserInteraction();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RatingListScreen(),
                        ),
                      );
                    },
                    child: itemDashboard(
                      'See ratings',
                      CupertinoIcons.star_fill,
                      Colors.indigo,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SessionTimeout().onUserInteraction();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminEditProfilePage(),
                        ),
                      );
                    },
                    child: itemDashboard(
                      'My Account',
                      CupertinoIcons.person,
                      Colors.green,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SessionTimeout().onUserInteraction();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageUsersPage(),
                        ),
                      );
                    },
                    child: itemDashboard(
                      'Manage User',
                      CupertinoIcons.person_3,
                      Colors.teal,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      SessionTimeout().onUserInteraction();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminScreen(),
                        ),
                      );
                    },
                    child: itemDashboard(
                      'Add a new Admin',
                      CupertinoIcons.person_2,
                      Colors.black38,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Future.delayed(Duration(seconds: 1), () {
                        _logout(); // Call the logout function after a delay
                      });
                    },
                    child: itemDashboard(
                      'Logout',
                      CupertinoIcons.return_icon,
                      Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  void _logout() {
    // Clear user session or perform any other necessary logout actions here
    // For example, you can clear the user data from SharedPreferences or Firebase Auth
    FirebaseAuth.instance.signOut();

    // After the logout actions are performed, navigate to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => login_screen()),
    );
  }

  Widget itemDashboard(String title, IconData iconData, Color background) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Theme.of(context).primaryColor.withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
