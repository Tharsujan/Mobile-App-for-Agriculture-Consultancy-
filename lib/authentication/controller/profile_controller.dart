import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import '../../repository/authendication_repository/authendication_repository.dart';
import '../../repository/user_repository/user_repository.dart';
import '../models/user_model.dart';
class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();
  /// Controllers
  final password = TextEditingController();
  ///Repository
  final _authRepo = Get.put(AuthenticationRepository());
  final _userRepo = Get.put(UserRepository());
// Step 3 - Get User Email and pass to UserRepository to fetch user record.
  getUserData() {
    final email = _authRepo.firebaseUser.value?.email;
    if (email != null) {
      return _userRepo.getUserDetails(email);
    } else {
      Get.snackbar("Error", "Login to continue");
      return null;
    }
  }
  updateRecord(UserModel user) async {
    await _userRepo.updateUserRecord(user);
  }
}
