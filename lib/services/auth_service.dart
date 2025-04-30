import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register with email and password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      log(email);
      log(password);
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      log(result.toString());
      return result.user;
    } catch (e) {
      print(e.toString());
      return null; // Return null if registration fails
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      //user succesfully created
      return result.user;
    } catch (e) {
      print(e.toString());
      return null; // Return null if sign in fails
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is already logged in
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
}
