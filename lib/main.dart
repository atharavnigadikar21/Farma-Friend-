import 'package:farma_friend/pages/splash_screen.dart';
import 'package:farma_friend/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'services/crop_service.dart';

void main() async {
  await setup();
  runApp(const MainApp());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();

  // Initialize CropService and Local DB
  final cropService = CropService();
  await cropService.initLocalDb(); // Initialize the SQLite DB
  await cropService.syncCropsFromFirebase();
  // cropService.enterData(); // Sync Firestore crops to local DB
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // If user is logged in, navigate to SplashScreen
            if (snapshot.hasData) {
              return const SplashScreen(
                status: true,
              );
            }
            // If user is not logged in, navigate to LoginPage
            return const SplashScreen(
              status: false,
            ); // Replace with your login page
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
