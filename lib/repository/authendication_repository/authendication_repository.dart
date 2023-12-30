import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:project_02_final/authentication/screens/home.dart';
import 'package:project_02_final/authentication/screens/login.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

//Variables

  final _auth = FirebaseAuth.instance;
  late final Rx<User?> firebaseUser;
  var verificationId = ''.obs;
// will  be load when app lunch this function will be called and set the firebase user state
  @override
  void onReady() {
    firebaseUser = Rx<User?>(_auth.currentUser);
    firebaseUser.bindStream(_auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    user == null
        ? Get.offAll(() => const login_screen())
        : Get.offAll(() => home());
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (_) {}
  }
}
