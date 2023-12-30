import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:project_02_final/authentication/screens/register.dart';
import 'package:project_02_final/authentication/screens/reset_password.dart';
import '../../Admin/AdminHome.dart';
import '../../reusable_widgets/reusable_widgets.dart';
import '../controller/register_controller.dart';
import '../models/user_model.dart';
import 'home.dart';

class login_screen extends StatefulWidget {
  const login_screen({Key? key}) : super(key: key);
  @override
  State<login_screen> createState() => _login_screenState();
}

class _login_screenState extends State<login_screen> {
  final controller = Get.put(registerontroller());
  final _formKey = GlobalKey<FormState>();

  bool textvisible = true;
  String? emailError;
  String? passwordError;

  Future<void> saveFcmToken(String userEmail, String fcmToken) async {
    try {
      // Get a reference to the Firestore collection 'fcm_token'
      CollectionReference<Map<String, dynamic>> fcmTokenCollection =
      FirebaseFirestore.instance.collection('fcm_token');

      // Create a document with the user's email as the document ID
      await fcmTokenCollection.doc(userEmail).set({
        'email': userEmail,
        'fcm': fcmToken,
      });
    } catch (error) {
      print('Error saving FCM token: ${error.toString()}');
    }
  }


  Future<void> signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential? userCredential;
        try {
          userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: controller.email.text,
            password: controller.password.text,
          );
        } catch (error) {
          // Check if the error is a FirebaseAuthException
          if (error is FirebaseAuthException) {
            if (error.code == 'user-not-found') {
              setState(() {
                emailError = 'User not found';
              });
            } else if (error.code == 'wrong-password') {
              setState(() {
                passwordError = 'Incorrect password';
              });
            } else {
              print("Error: ${error.toString()}");
            }
          } else {
            // Handle other types of errors if needed
            print("Error: ${error.toString()}");
          }
        }

        if (userCredential != null && userCredential.user != null) {
          String? email = userCredential.user!.email;
          QuerySnapshot<Map<String, dynamic>> userDocs = await FirebaseFirestore
              .instance
              .collection('Users')
              .where('Email', isEqualTo: email)
              .get();

          // Check if a user document with the provided email exists
          if (userDocs.docs.isNotEmpty) {
            DocumentSnapshot<Map<String, dynamic>> userDoc =
                userDocs.docs.first;
            UserModel user = UserModel.fromSnapshot(userDoc);

            if (user.role == 'admin') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminHome()),
              );
              registerontroller.instance.clearRegisterFields();
            } else if (user.role == 'user' && user.ActiveUser == true) {

    // Fetch the FCM token
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? fcmToken = await messaging.getToken();
    // Save the FCM token to Firestore
    await saveFcmToken(user.email, fcmToken!);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => home()),
              );
              registerontroller.instance.clearRegisterFields();
            } else if (user.role == 'user' && user.ActiveUser == false) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        '${user.username}, Your account has been blocked !',
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Ok", style: TextStyle(fontSize: 19)),
                        )
                      ],
                      content: Text(
                        'For more information cantact us 0769218508 or psell@gmail.com',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    );
                  });
            } else {
              // Handle other roles or invalid role values here (if needed)
              print('Invalid user role: ${user.role}');
            }
          } else {
            // Handle the case where the user document does not exist
            print('User document not found for the provided email.');
          }
        }
      } catch (error) {
        print("Error: ${error.toString()}");
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromRGBO(25, 176, 47, 1),
            Color.fromRGBO(0, 0, 0, 10)
          ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.1, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const Text(
                    'Psell',
                    style: TextStyle(
                      fontSize: 80,
                      color: Colors.white,
                      fontFamily: 'Times New Roman',
                      letterSpacing: 4,
                    ),
                  ),
                  logoWidget('assets/images/logo1.png'),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: controller.email,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Colors.white70,
                        ),
                        labelText: "Enter Email address",
                        labelStyle:
                            TextStyle(color: Colors.white.withOpacity(0.9)),
                        filled: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: Colors.white.withOpacity(0.3),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                width: 0, style: BorderStyle.none)),
                        errorText: emailError),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: controller.password,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.password,
                          color: Colors.white70,
                        ),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                textvisible = !textvisible;
                              });
                            },
                            icon: textvisible
                                ? const Icon(
                                    Icons.visibility,
                                    color: Colors.white,
                                  )
                                : const Icon(
                                    Icons.visibility_off,
                                    color: Colors.white,
                                  )),
                        labelText: "Password",
                        labelStyle:
                            TextStyle(color: Colors.white.withOpacity(0.9)),
                        filled: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: Colors.white.withOpacity(0.3),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                                width: 0, style: BorderStyle.none)),
                        errorText: passwordError),
                    obscureText: textvisible,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  forgetPassword(context),
                  const SizedBox(height: 20),
                  firebaseUIButton(context, "Login", signIn),
                  registerOption(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row registerOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(context as BuildContext,
                MaterialPageRoute(builder: (context) => const register()));
          },
          child: const Text(
            "  Register",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "forgot password?",
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const resetpassword())),
      ),
    );
  }
}
