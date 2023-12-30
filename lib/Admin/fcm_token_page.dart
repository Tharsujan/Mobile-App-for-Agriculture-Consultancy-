import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FcmTokenList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FCM Tokens'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('fcm_token').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final fcmTokens = snapshot.data!.docs;
          return ListView.builder(
            itemCount: fcmTokens.length,
            itemBuilder: (context, index) {
              final fcmTokenData =
                  fcmTokens[index].data() as Map<String, dynamic>;
              final email = fcmTokenData['email'] ?? 'Unknown Email';
              final fcmToken = fcmTokenData['fcm'] ?? 'Unknown FCM Token';

              // Store the subtitle text in a variable
              final subtitleText = '$fcmToken';

              return Card(
                elevation: 3,
                margin: EdgeInsets.all(8),
                child: GestureDetector(
                  onLongPress: () {
                    _showContextMenu(context, email, subtitleText);
                  },
                  child: ListTile(
                    title: Text(
                      'Email: $email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(subtitleText),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showContextMenu(
      BuildContext context, String email, String subtitleText) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.content_copy),
                title: Text('Copy Email'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: email));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email copied to clipboard'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.content_copy),
                title: Text('Copy FCM Token'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: subtitleText));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('FCM Token copied to clipboard'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
