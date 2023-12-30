import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Pages/cart.dart';
import '../../Pages/cart_screen.dart';
import '../../components/RecentProductsPage.dart';
import '../../reusable_widgets/theme_provider.dart';
import 'AboutUsPage.dart';
import 'MyAccount.dart';
import 'PreOrderBookingPage.dart';
import 'ProductSearchScreen.dart';
import 'QRCodeRetrieval.dart';
import 'RateUs.dart';

import 'UserConsaltancyBookingDetailsPage.dart';
import 'chat.dart';
import 'login.dart';
import 'package:project_02_final/components/horizontal_listview.dart';
import 'notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late String UserName = "";
  late String email = "";
  late String ProfileUrl = "";
  int totalItemsInCart = 0;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
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
        email = userData['Email'];
        ProfileUrl = userData['ProfileUrl'] ?? '';

        // Call setState to update the UI with the fetched data
        setState(() {});
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    totalItemsInCart = Cart.items.fold(0, (sum, item) => sum + item.quantity);
    Widget image_carousel = Container(
      height: 150.0,
      child: ListView(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/category/qwqw.jpg'),
              ),
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 150),
                          child: Container(
                            height: 70,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Color(0xffd1ad17),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(50),
                                bottomLeft: Radius.circular(50),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Offer !!',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    BoxShadow(
                                        color: Colors.black,
                                        blurRadius: 10,
                                        offset: Offset(3, 3))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        //Show offers
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('offers')
                              .doc('percentages')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || !snapshot.data!.exists) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            double plantsPercentage =
                                snapshot.data!.get('plantsPercentage') ?? 0.0;
                            double equipmentPercentage =
                                snapshot.data!.get('equipmentPercentage') ??
                                    0.0;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (plantsPercentage != 0)
                                  Container(
                                    padding: EdgeInsets.all(6.4),
                                    color: Colors.green[30],
                                    child: Text(
                                      '${plantsPercentage.toStringAsFixed(2)}% For All Plants',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                if (equipmentPercentage != 0)
                                  Container(
                                    padding: EdgeInsets.all(6.4),
                                    color: Colors.blue[30],
                                    child: Text(
                                      '${equipmentPercentage.toStringAsFixed(2)}% For All Equipments',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                        // Padding(
                        //   padding: const EdgeInsets.only(left: 20),
                        //   child: Text(
                        //     'On all Plants',
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
        ],
      ), //   boxFit: BoxFit.cover,
      //   images: [
      //     AssetImage('assets/images/H1.png'),
      //     AssetImage('assets/images/H2.jfif'),
      //     AssetImage('assets/images/H3.jpg'),
      //     AssetImage('assets/images/H4.jfif')
      //   ],
      //   autoplay: true,
      //   animationCurve: Curves.fastOutSlowIn,
      //   animationDuration: Duration(milliseconds: 1000),
      //   dotSize: 4.0,
      //   dotColor: Colors.green,
      //   indicatorBgPadding: 2.0,
      // ),
    );
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.black,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          CircleAvatar(
            radius: 15,
            backgroundColor: Colors.white,
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductSearchScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.search,
                size: 24,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 12), // Add spacing between icons
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    );
                  },
                  icon: const Icon(
                    Icons.shopping_cart,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
              ),
              if (totalItemsInCart > 0)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: Text(
                      totalItemsInCart.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: Colors.black,
            ),
            onPressed: () {
              themeProvider.toggleTheme(); // Toggle the theme mode
            },
          ),
        ],
      ),
      drawer: SafeArea(
        child: Drawer(
          elevation: 40,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(UserName),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      NetworkImage(ProfileUrl), // Use the fetched ProfileUrl
                ),
                decoration: const BoxDecoration(
                  color: Colors.grey,
                ),
              ),
              ListTile(
                dense: true,
                title: const Text("My Account"),
                leading: const Icon(Icons.person),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserEditProfilePage()),
                  );
                },
              ),
              ListTile(
                dense: true,
                title: const Text("Pre-Orders Bookings"),
                leading: const Icon(Icons.add_box),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PreOrderBookingPage()),
                  );
                },
              ),
              ListTile(
                dense: true,
                title: const Text("Consultancy Bookings"),
                leading: const Icon(Icons.add_box),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserBookingDetailsPage()),
                  ); //action when this menu is pressed
                },
              ),
              ListTile(
                dense: true,
                title: const Text("Notifications"),
                leading: const Icon(Icons.notifications_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyNotification()),
                  ); //action when this menu is pressed
                },
              ),
              ListTile(
                dense: true,
                title: const Text("Chat"),
                leading: const Icon(Icons.chat),
                onTap: () {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final uid = user.uid;
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatScreen(
                              userId: '',
                            )));
                  } else {
                    print('User authentication failed');
                    // Handle the error or show an error message to the user
                  }
                },
              ),
              ListTile(
                dense: true,
                title: const Text("About us"),
                leading: const Icon(Icons.contact_page_rounded),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AboutUsPage()),
                  ); //action when this menu is pressed
                },
              ),
              ListTile(
                dense: true,
                title: const Text("Rate us"),
                leading: const Icon(Icons.star_rate),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RateUsScreen(
                              uid: '',
                            )),
                  ); //action when this menu is pressed
                },
              ),
              ListTile(
                dense: true,
                title: const Text("Your QR"),
                leading: const Icon(Icons.qr_code),
                onTap: () {
                  // action when this menu is pressed
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final uid = user.uid;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRCodeRetrieval(uid: uid),
                      ),
                    );
                  } else {
                    print('User authentication failed');
                    // Handle the error or show an error message to the user
                  }
                },
              ),
              ListTile(
                dense: true,
                title: const Text("Log out"),
                leading: const Icon(Icons.arrow_back),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const login_screen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Theme(
        data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
          child: new ListView(
            children: [
              image_carousel,
              new Padding(
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                child: Center(child: new Text("SHOP FOR")),
              ),
              HorizontalList(),
              new Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(child: new Text("Recent Plants")),
              ),
              Container(
                height: 340.0,
                child: RecentProductsPage(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
