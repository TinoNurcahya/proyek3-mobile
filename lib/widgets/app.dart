import 'package:flutter/material.dart';
import '../config/navigator_key.dart';

import '../pages/absensi/absensi.dart';
import '../start/start.dart';
import '../start/login.dart';
import '../pages/profile/profile_screen.dart';
import '../pages/notification/notification_page.dart';
import '../pages/menu/menu_page.dart';
import '../pages/menu/order_page.dart';
import '../pages/scan/scan.dart';
import '../pages/scan/tata_letak.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Sora'),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(nextScreen: LoginPage()),
        '/login': (context) => LoginPage(),
        '/home': (context) => AbsensiPage(),
        '/order': (context) => const DaftarOrderPage(),
        '/daftar-order': (context) => const DaftarOrderPage(), // Alias
        '/scan': (context) => const ScanMejaPage(),
        '/menu': (context) => const MenuPelangganPage(),
        '/profile': (context) => const ProfileScreen(),
        '/notification': (context) => const NotificationPage(),
        '/tata-letak': (context) => const TataLetakMejaPage(),
      },
    );
  }
}
