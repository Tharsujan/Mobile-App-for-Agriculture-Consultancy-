import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminChatScreen extends StatefulWidget {
  @override
  _AdminChatScreenState createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _replyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Chat'),
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
                return ListView.builder(
                  reverse: true,
                  itemCount: messages?.length,
                  itemBuilder: (context, index) {
                    final message = messages?[index].get('message');
                    final email = messages?[index].get('email');
                    final reply = messages?[index].get('reply');

                    return AdminMessageBubble(
                      email: email,
                      message: message,
                      reply: reply,
                      onReply: (newReply) {
                        _replyMessage(messages![index].id, newReply);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _replyMessage(String messageId, String newReply) {
    FirebaseFirestore.instance.collection('chat').doc(messageId).update({
      'reply': newReply,
    });
  }
}

class AdminMessageBubble extends StatefulWidget {
  final String email;
  final String message;
  final String reply;
  final Function(String) onReply;

  AdminMessageBubble({
    required this.email,
    required this.message,
    required this.reply,
    required this.onReply,
  });

  @override
  _AdminMessageBubbleState createState() => _AdminMessageBubbleState();
}

class _AdminMessageBubbleState extends State<AdminMessageBubble> {
  TextEditingController _replyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.email,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(widget.message),
            if (widget.reply.isNotEmpty)
              Container(
                color: Colors.blueGrey,
                padding: EdgeInsets.all(8.0),
                margin: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Admin Reply: ${widget.reply}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            if (widget.reply.isEmpty)
              TextField(
                controller: _replyController,
                decoration: InputDecoration(
                  hintText: 'Reply to this message...',
                ),
              ),
            if (widget.reply.isEmpty)
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  widget.onReply(_replyController.text);
                  _replyController.clear();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }
}
