import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String userId;

  ChatScreen({required this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with Admin'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chat')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final messages = snapshot.data?.docs;
                final user = FirebaseAuth.instance.currentUser;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages?.length,
                  itemBuilder: (context, index) {
                    final message = messages?[index].get('message');
                    final email = messages?[index].get('email');
                    final isUserMessage = email == user?.email;
                    final reply = messages?[index].get('reply');

                    return MessageBubble(
                      message: message,
                      isUserMessage: isUserMessage,
                      reply: reply,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _sendMessage(widget.userId),
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String userId) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      FirebaseFirestore.instance.collection('chat').add({
        'email': FirebaseAuth.instance.currentUser!.email,
        'message': message,
        'reply': '', // Admin can fill this in later
        'timestamp': DateTime.now(),
      });
      _messageController.clear();
    }
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUserMessage;
  final String reply;

  MessageBubble({
    required this.message,
    required this.isUserMessage,
    required this.reply,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isUserMessage ? Colors.green : Colors.grey;
    final textColor = isUserMessage ? Colors.white : Colors.black;
    final alignment =
        isUserMessage ? Alignment.centerRight : Alignment.centerLeft;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Align(
        alignment: alignment,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(color: textColor),
              ),
              if (reply.isNotEmpty)
                Container(
                  color: Colors.blueGrey,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Admin Reply: $reply',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
