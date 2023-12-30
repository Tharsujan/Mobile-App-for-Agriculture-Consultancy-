import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_02_final/authentication/controller/profile_controller.dart';
import '../../authentication/models/user_model.dart';

class updateProfile extends StatefulWidget {
  const updateProfile({Key? key}) : super(key: key);

  @override
  State<updateProfile> createState() => _updateprofileState();
}

class _updateprofileState extends State<updateProfile> {
  final controller = Get.put(ProfileController());
  final _formkey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phonenumberController = TextEditingController();

  @override
  void initState() {
    fetchUserData(); // Call fetchUserData here without super.initState()
    super.initState();
  }

  Future<void> fetchUserData() async {
    final userData = await controller.getUserData();
    if (userData != null) {
      usernameController.text = userData.username;
      emailController.text = userData.email;
      phonenumberController.text = userData.phonenumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss the keyboard when the user taps outside the text fields
          FocusScope.of(context).unfocus();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color.fromRGBO(25, 176, 47, 1),
              Color.fromRGBO(0, 0, 0, 10)
            ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
              child: Form(
                key: _formkey,
                child: FutureBuilder<UserModel?>(
                  future: controller.getUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        UserModel userData = snapshot.data!;

                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: usernameController,
                              style: TextStyle(color: Colors.white.withOpacity(0.9)),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: Colors.white70,
                                ),
                                labelText: "Username",
                                labelStyle:
                                TextStyle(color: Colors.white.withOpacity(0.9)),
                                filled: true,
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                fillColor: Colors.white.withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Username is required";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: emailController,
                              style: TextStyle(color: Colors.white.withOpacity(0.9)),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: Colors.white70,
                                ),
                                labelText: "Email",
                                labelStyle:
                                TextStyle(color: Colors.white.withOpacity(0.9)),
                                filled: true,
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                fillColor: Colors.white.withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: const BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Email is required";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: phonenumberController,
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
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Phone number is required";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                // Close the keyboard before submitting the form
                                FocusScope.of(context).unfocus();

                                if (_formkey.currentState!.validate()) {
                                  final userdata = UserModel(
                                    username: usernameController.text.trim(),
                                    email: emailController.text.trim(),
                                    phonenumber: phonenumberController.text.trim(),
                                    role: "user",
                                    ActiveUser: true,
                                  );
                                  await controller.updateRecord(userdata);
                                }
                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
                                ),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                textStyle: MaterialStateProperty.all<TextStyle>(
                                  const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              child: const Text('Update Profile'),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text(snapshot.error.toString()));
                      } else {
                        return const Center(child: Text("Something went wrong"));
                      }
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}