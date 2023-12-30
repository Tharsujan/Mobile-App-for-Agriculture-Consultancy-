import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_02_final/authentication/screens/login.dart';

class SessionTimeout extends NavigatorObserver {
  static final SessionTimeout _instance = SessionTimeout._internal();
  factory SessionTimeout() => _instance;

  SessionTimeout._internal();

  final int timeoutInSeconds = 420; // Set 7 mins session time out
  Timer? _timer;
  bool _userInteracted = false;

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: timeoutInSeconds), () {
      if (!_userInteracted) {
        _logout();
      } else {
        _userInteracted = false;
        _resetTimer();
      }
    });
    print("Timer reset successfully..........................");
  }

  void _logout() {
    // Perform the logout action here (e.g., clear user session, go to the login screen)
    Navigator.pushReplacement(
      navigator!.context, // Change this line
      MaterialPageRoute(
        builder: (context) => login_screen(),
      ),
    );
  }

  void onUserInteraction() {
    _userInteracted = true;
    _resetTimer(); // Reset the timer on user interaction
  }

  // This method is named onActivityDetected, consistent with AdminHome usage
  void onActivityDetected() {
    onUserInteraction();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onActivityDetected();
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    onActivityDetected();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onActivityDetected();
    super.didPop(route, previousRoute);
  }
}
