import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:project_02_final/authentication/controller/register_controller.dart';
import '../authentication/models/user_model.dart';
import 'AddAdmin_ShowAdmin_screen.dart';

class AdminRegister extends StatefulWidget {
  const AdminRegister({Key? key}) : super(key: key);

  @override
  State<AdminRegister> createState() => _registerState();
}

class _registerState extends State<AdminRegister> {
  final controller = Get.put(registerontroller());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Admin register page",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
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
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: controller.username,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Colors.white70,
                      ),
                      labelText: "Enter UserName",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Username must be at least 2 characters in length';
                      }
                      // Check if the value consists entirely of numbers
                      if (int.tryParse(value) != null) {
                        return 'Username cannot consist entirely of numbers';
                      }
                      // Return null if the entered username is valid
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: controller.email,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.white70,
                      ),
                      labelText: "Enter Email id",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none)),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter an email';
                      } else if (!value.contains('@') ||
                          (!value.contains('.com') &&
                              !value.contains('@yahoo.com') &&
                              !value.contains('@yahoomail.com'))) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: controller.phonenumber,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: Colors.white70,
                      ),
                      labelText: "Enter Phone Number",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none)),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please Enter a Phone Number";
                      } else if (!RegExp(
                              r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$')
                          .hasMatch(value)) {
                        return "Please Enter a Valid Phone Number";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: controller.password,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.password,
                        color: Colors.white70,
                      ),
                      labelText: "Enter password",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none)),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is required';
                      }
                      if (value.trim().length < 8) {
                        return 'Password must be at least 8 characters in length';
                      }
                      // Return null if the entered password is valid
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.password,
                        color: Colors.white70,
                      ),
                      labelText: "Confirm password",
                      labelStyle:
                          TextStyle(color: Colors.white.withOpacity(0.9)),
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      fillColor: Colors.white.withOpacity(0.3),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: const BorderSide(
                              width: 0, style: BorderStyle.none)),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != controller.password.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          // Create new account with Firebase Authentication
                          final UserCredential userCredential =
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                            email: controller.email.text,
                            password: controller.password.text,
                          );
                          final ProfileUrl = "";
                          final role = "admin";
                          final ActiveUser = true;

                          // Store user data in Firestore
                          final user = UserModel(
                              uid: userCredential.user!.uid,
                              email: controller.email.text.trim(),
                              username: controller.username.text.trim(),
                              phonenumber: controller.phonenumber.text.trim(),
                              ProfileUrl: "",
                              role: role,
                              ActiveUser: ActiveUser,
                              formattedDate: DateTime.now());

                          registerontroller.instance.createUser(user);

                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('New Admin Added'),
                                titleTextStyle: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text(
                                      'OK',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );

                          // Navigation logic
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminScreen()),
                          );
                        } catch (error) {
                          // Handle errors
                          print('Error: $error');
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Registration Failed'),
                                titleTextStyle: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                                content: Text(
                                    'Email is already used for this registration, you can try a different email address.'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),

                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.black26;
                          }
                          return Colors.white;
                        }),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)))),
                    // ... Rest of the button code
                  ),
                ],
              ),
            ),
          ))),
    );
  }
}
