import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({Key? key}) : super(key: key);

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  bool showActiveUsers =
      true; // Set this to true initially to show active users.
  TextEditingController _searchController = TextEditingController();
  late Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream;

  @override
  void initState() {
    super.initState();
    _usersStream = FirebaseFirestore.instance
        .collection('Users')
        .where('role', isEqualTo: 'user')
        .snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showActiveUsers = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Active Users'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showActiveUsers = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Blocked Users'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {}); // Trigger a rebuild when the text changes
              },
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: Colors.green,
                ),
                labelText: 'Search by Email',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _usersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final query = _searchController.text.toLowerCase();
                  final users = snapshot.data!.docs
                      .map((doc) => UserModel.fromMap(doc.data()))
                      .where((user) =>
                          user.email.toLowerCase().contains(query) &&
                          user.ActiveUser == showActiveUsers)
                      .toList();

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return SingleChildScrollView(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user.ProfileUrl),
                          ),
                          title: Text(user.email),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: ${user.UserName}'),
                              Text('Phone: ${user.phonenumber}'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              _showConfirmationDialog(user);
                            },
                            child: Text(user.ActiveUser ? 'Block' : 'Unblock'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  user.ActiveUser ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text('No users found'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmationDialog(UserModel user) async {
    final isBlocked = user.ActiveUser;
    final title = isBlocked ? 'Block User' : 'Unblock User';
    final message = isBlocked
        ? 'Are you sure you want to block this user?'
        : 'Are you sure you want to unblock this user?';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result != null && result) {
      // User confirmed the action, update the user status in Firestore
      _toggleUserStatus(user.email, !isBlocked);
    }
  }

  Future<void> _toggleUserStatus(String email, bool isActive) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .where('Email', isEqualTo: email)
              .get();

      final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
          querySnapshot.docs;
      if (docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> doc = docs.first;
        await doc.reference.update({
          'ActiveUser': isActive,
        });
        print('User status updated successfully');
        setState(() {}); // Refresh the UI
      } else {
        print('User not found');
      }
    } catch (e) {
      print('Error updating user status: $e');
    }
  }
}

class UserModel {
  final String email;
  final String UserName;
  final String phonenumber;
  final String ProfileUrl;
  final bool ActiveUser;
  final String role;

  UserModel(
      {required this.email,
      required this.UserName,
      required this.phonenumber,
      required this.ProfileUrl,
      required this.ActiveUser,
      required this.role});

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        email: map['Email'] ?? '',
        UserName: map['UserName'] ?? '',
        phonenumber: map['PhoneNumber'] ?? '',
        ProfileUrl: map['ProfileUrl'],
        ActiveUser: map['ActiveUser'] ?? false,
        role: map['role'] ?? '');
  }
}
