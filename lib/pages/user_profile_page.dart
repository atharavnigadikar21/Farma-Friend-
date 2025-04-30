import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farma_friend/pages/login_page.dart';
import 'package:farma_friend/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;
  final AuthService _authService = AuthService();

  UserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile', style: GoogleFonts.poppins()),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User does not exist'));
          }

          // Extract user data from snapshot
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String name = userData['name'] ?? 'No name available';
          String mobileNumber =
              userData['mobileNumber'] ?? 'No mobile number available';
          String email = userData['email'] ?? 'No email available';
          String profileImage = userData['profileImageUrl'] ??
              ''; // Ensure this matches your Firestore field name

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 70,
                  backgroundImage: profileImage.isNotEmpty
                      ? NetworkImage(
                          profileImage) // This should show the uploaded image
                      : const AssetImage('assets/default_profile.jpg')
                          as ImageProvider,
                ),
                const SizedBox(height: 20),
                // User Information Cards
                _buildInfoCard('Full Name', name),
                _buildInfoCard('Mobile Number', mobileNumber),
                _buildInfoCard('Email', email),
                const SizedBox(height: 30),
                // Edit Profile Button
                ElevatedButton(
                  onPressed: () {
                    _logout(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 235, 183, 183),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: GoogleFonts.poppins(fontSize: 18),
                  ),
                  child: const Text('Log out'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.poppins(fontSize: 16),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Call Firebase sign-out method
      await _authService.signOut();

      // Navigate to login page after successful sign-out
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully Logged Out"),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error during sign-out: $e');
    }
  }
}
