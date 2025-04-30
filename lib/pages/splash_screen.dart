import 'package:animated_splash_screen/animated_splash_screen.dart'; // Splash screen package
import 'package:farma_friend/pages/home_page.dart';
import 'package:farma_friend/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart'; // Add for transition effect

class SplashScreen extends StatelessWidget {
  final bool status;
  const SplashScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: _buildSplashContent(),
      nextScreen: (status)
          ? const FarmerFriendApp()
          : const LoginPage(), // Replace with your HomeScreen widget
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      backgroundColor: Colors.white,
      duration: 3000,
      splashIconSize: double.infinity,
    );
  }

  // Customize your splash content here
  Widget _buildSplashContent() {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.asset(
            'assets/create_page.jpg', // Replace with your splash image path
            fit: BoxFit.cover,
          ),
        ),
        // Overlay and Logo
        Positioned(
          left: 0,
          right: 0,
          top: 160,
          child: Column(
            children: [
              // App Logo
              // Image.asset(
              //   'assets/app_icon.jpg', // Replace with your app logo
              //   height: 120,
              // ),
              // const SizedBox(height: 20),
              // App Name
              Text(
                'Farma Friend',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              // Tagline
              Text(
                'Empowering Farmers with Smart Solutions',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        // Animated Loader (Optional)
        const Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
