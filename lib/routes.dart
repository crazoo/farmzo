import 'package:farmzo/screens/farmer_dashboard/farmer_screens_main.dart';
import 'package:flutter/material.dart';
import 'package:farmzo/screens/splash_screen.dart';
import 'package:farmzo/screens/welcome_screen.dart';
import 'package:farmzo/screens/farmer_dashboard/farmer_details_screen.dart';
import 'package:farmzo/screens/buyer_dashboard/buyer_screens_main.dart';
import 'screens/farmer_dashboard/farmer_profile_screen.dart';



Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(), // AuthGate handles initial navigation
  '/welcome': (context) => const WelcomeScreen(),
  '/userDetails': (context) => const FarmerDetailsScreen(),
  '/farmer': (context) => const FarmerHomeScreen(),
  '/profile': (context) => const FarmerProfileScreen(),
  '/buyerHome': (context) => const BuyerHomeScreen(),
};
