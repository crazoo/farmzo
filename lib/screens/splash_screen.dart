import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _borderAnimationController;
  late Animation<double> _borderAnimation;
  late AnimationController _scaleAnimationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkLoginStatus();
  }

  // Initialize animations
  void _initializeAnimations() {
    // Fade Animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Border Animation
    _borderAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Loop animation

    _borderAnimation = Tween<double>(begin: 2, end: 8).animate(
      CurvedAnimation(
          parent: _borderAnimationController, curve: Curves.easeInOut),
    );

    // Scale Animation for Image
    _scaleAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
          parent: _scaleAnimationController, curve: Curves.easeInOut),
    );
  }

  // Check login status
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userRole = prefs.getString('user_role');
    bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    await Future.delayed(const Duration(seconds: 4)); // Splash delay

    if (isLoggedIn) {
      if (userRole == 'farmer') {
        Navigator.pushReplacementNamed(context, '/farmer');
      } else if (userRole == 'buyer') {
        Navigator.pushReplacementNamed(context, '/buyerHome');
      } else {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _borderAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[900]!, Colors.blue[400]!],
              ),
            ),
          ),
          // Centered Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo with Animated Border
                  AnimatedBuilder(
                    animation:
                        Listenable.merge([_borderAnimation, _scaleAnimation]),
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                            width: _borderAnimation.value, // Animated border
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Transform.scale(
                          scale:
                              _scaleAnimation.value, // Image Scaling Animation
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/farmzo_app_logo_modified.png',
                              height: 120,
                              width: 120,
                              fit: BoxFit
                                  .cover, // Ensures it fits inside the border
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // App Name
                  Text(
                    'Farmzo..!',
                    style: GoogleFonts.poppins(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),
                  // App Tagline
                  const Text(
                    'Connecting Farmers and Buyers to Technology',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Loading Indicator
                  const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
