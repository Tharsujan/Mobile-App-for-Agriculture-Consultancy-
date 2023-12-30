import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Ratings'),
      ),
      body: UserRatingsList(),
    );
  }
}

class UserRatingsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('ratings').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          ); // Show a centered loading indicator while fetching data
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No ratings found.'),
          ); // Show a centered message if no ratings are available
        }

        final ratingsDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: ratingsDocs.length,
          itemBuilder: (context, index) {
            final ratingData =
                ratingsDocs[index].data() as Map<String, dynamic>;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              elevation: 2.0,
              child: ListTile(
                title: Text('Email: ${ratingData['email']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rating: ${ratingData['rating']}'),
                    Text('Comment: ${ratingData['comment']}'),
                    Text(
                      'Timestamp: ${ratingData['timestamp'].toDate().toString()}',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
