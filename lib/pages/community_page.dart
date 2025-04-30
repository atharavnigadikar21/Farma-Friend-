import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For formatting timestamp

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool canPost = false; // Default: User cannot post
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _opinionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPostingPermission(); // Check if the user has permission to post
  }

  Future<void> _checkPostingPermission() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Query Firestore to check the canPost permission
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid) // Assuming user ID matches the document ID
          .get();

      if (userDoc.exists) {
        setState(() {
          canPost = userDoc['canPost'] ??
              false; // Default to false if field is missing
        });
      }
    }
  }

  Future<void> _submitOpinion() async {
    final user = _auth.currentUser;
    if (user != null && canPost && _opinionController.text.isNotEmpty) {
      await _firestore.collection('posts').add({
        'username': user.displayName ?? "Anonymous",
        'opinion': _opinionController.text,
        'timestamp':
            FieldValue.serverTimestamp(), // Using Firestore's server timestamp
        'userId': user.uid,
      });

      // Clear the text field after submitting
      _opinionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Community',
          style: GoogleFonts.poppins(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: _firestore
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              Timestamp? timestamp = post['timestamp'] as Timestamp?;
              String formattedDate = timestamp != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate())
                  : 'Unknown'; // Default to 'Unknown' if timestamp is null
              return _buildOpinionCard(
                username: post['username'] ?? 'Unknown',
                opinion: post['opinion'] ?? '',
                timestamp: formattedDate, // Using formatted timestamp
              );
            },
          );
        },
      ),
      floatingActionButton: canPost
          ? FloatingActionButton(
              onPressed: () => _showPostDialog(context),
              backgroundColor: Colors.green[700],
              child: const Icon(Icons.add),
            )
          : null, // No button if the user can't post
    );
  }

  void _showPostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Post an Opinion'),
          content: TextField(
            controller: _opinionController,
            decoration:
                const InputDecoration(hintText: 'Share your thoughts...'),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _submitOpinion();
                Navigator.of(context).pop();
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  // Opinion Card Widget
  Widget _buildOpinionCard({
    required String username,
    required String opinion,
    required String timestamp,
  }) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green[700],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      timestamp, // Display the formatted timestamp
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Icons.more_vert, color: Colors.grey[600]),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              opinion,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.thumb_up, color: Colors.green[700]),
                  label: Text(
                    'Like',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.comment, color: Colors.green[700]),
                  label: Text(
                    'Comment',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.green[700],
                    ),
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