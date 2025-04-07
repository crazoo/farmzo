import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'routes.dart'; // Your custom route file

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Background message handler (MUST be a top-level function)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification != null) {
    _sendNotification(
      message.notification!.title ?? "New Message",
      message.notification!.body ?? "",
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _initNotification();
  await _getAndPrintFcmToken();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

// Initialize local notifications and FCM foreground listener
Future<void> _initNotification() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Foreground notification handling
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      _sendNotification(
        message.notification!.title ?? "New Message",
        message.notification!.body ?? "",
      );
    }
  });
}

// Print FCM token for testing
Future<void> _getAndPrintFcmToken() async {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("📱 FCM Token: $fcmToken");
}

// Check Firestore for today's market prices based on user location
Future<void> _checkMarketPricesAndNotify() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final uid = user.phoneNumber;
  if (uid == null) return;

  final userDoc =
      await FirebaseFirestore.instance.collection('farmers').doc(uid).get();

  if (!userDoc.exists) return;

  final state = userDoc['state'];
  final district = userDoc['district'];
  final market = userDoc['market'];

  final today = DateTime.now();
  final todayStr =
      "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

  final docRef = FirebaseFirestore.instance
      .collection('market_prices')
      .doc(todayStr)
      .collection(state)
      .doc(district)
      .collection(market);

  final snapshot = await docRef.limit(1).get();

  if (snapshot.docs.isNotEmpty) {
    await _sendNotification(
      "📢 Market Prices Available",
      "Today's market prices for $market are now live!",
    );
  }
}

// Show local notification
Future<void> _sendNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'market_price_channel',
    'Market Price Alerts',
    channelDescription: 'Notification for updated market prices',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    notificationDetails,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    _checkMarketPricesAndNotify();

    return MaterialApp(
      title: "Farmzo",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: appRoutes,
    );
  }
}
