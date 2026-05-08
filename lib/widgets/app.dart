import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/absensi.dart'; // AbsensiPage (home)
import '../start/start.dart';
import '../start/login.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/providers/profile_provider.dart';
import '../features/notification/screens/notification_page.dart';
import '../features/notification/providers/notification_provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Sora'),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(nextScreen: LoginPage()),
          '/login': (context) => LoginPage(),
          '/home': (context) => AbsensiPage(),
          '/profile': (context) => const ProfileScreen(),
          '/notification': (context) => const NotificationPage(),
        },
      ),
    );
  }
}