import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../authentication/screens/constants.dart';

class NotificationAdmin extends StatefulWidget {
  @override
  _NotificationAdminState createState() => _NotificationAdminState();
}

class _NotificationAdminState extends State<NotificationAdmin> {
  late TextEditingController _textTitle;
  late TextEditingController _textBody;
  late TextEditingController _textSetToken;

  @override
  void initState() {
    super.initState();

    _textSetToken = TextEditingController();
    _textTitle = TextEditingController();
    _textBody = TextEditingController();
  }

  Future<bool> pushNotificationsSpecificDevice({
    required String token,
    required String title,
    required String body,
  }) async {
    String dataNotifications = '{ "to" : "$token",'
        ' "notification" : {'
        ' "title":"$title",'
        '"body":"$body"'
        ' }'
        ' }';

    await http.post(
      Uri.parse(Constants.BASE_URL),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key= ${Constants.KEY_SERVER}',
      },
      body: dataNotifications,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Push Notifications'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _textTitle,
              decoration: InputDecoration(labelText: 'Enter Title'),
            ),
            TextField(
              controller: _textBody,
              decoration: InputDecoration(labelText: 'Enter Notification Body'),
            ),
            TextField(
              controller: _textSetToken,
              decoration: InputDecoration(labelText: 'Enter the fcm token '),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      if (_textSetToken.text.isNotEmpty) {
                        pushNotificationsSpecificDevice(
                          title: _textTitle.text,
                          body: _textBody.text,
                          token: _textSetToken.text,
                        );
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.greenAccent), // Change button color
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Colors.white)), // Change text color
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(16.0)), // Add padding
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Round the button corners

                        ),
                      ),
                      overlayColor: MaterialStateProperty.all<Color>(Colors.greenAccent), // Add hover effect color
                    ),
                    child: Text('Send Notification for specific Device'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Notification Admin',
    home: NotificationAdmin(),
  ));
}
