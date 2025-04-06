import 'package:flutter/material.dart';

AppBar customAppBar(BuildContext context, String routeName, {VoidCallback? onLogout}) {
  String title = '';

  // Set the title based on the route
  switch (routeName) {
    case '/':
      title = 'Splash Screen';
      break;
    case '/welcome':
      title = 'Welcome';
      break;
    case '/userDetails':
      title = 'Farmer Details';
      break;
    case '/farmerHome':
      title = 'Farmer Dashboard';
      break;
    case '/profile':
      title = 'Profile';
      break;
    default:
      title = 'Farmers App';
  }

  return AppBar(
    title: Text(title),
    centerTitle: true,
    backgroundColor: Colors.green,
    automaticallyImplyLeading: false, // Remove back icon
    actions: [
      if (routeName == '/profile' && onLogout != null)
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: onLogout,
        ),
    ],
  );
}
