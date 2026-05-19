import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/absensi/absensi.dart';
import '../start/start.dart';
import '../start/login.dart';
import '../pages/profile/screens/profile_screen.dart';
import '../pages/profile/providers/profile_provider.dart';
import '../pages/notification/screens/notification_page.dart';
import '../pages/notification/providers/notification_provider.dart';
import '../pages/menu/screens/menu_page.dart';
import '../pages/menu/screens/order_page.dart';
import '../pages/menu/providers/order_provider.dart';
import '../pages/scan/scan_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Sora'),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(nextScreen: LoginPage()),
          '/login': (context) => LoginPage(),
          '/home': (context) => AbsensiPage(),
          '/order': (context) => const DaftarOrderPage(),
          '/menu': (context) => const MenuPelangganPage(),
          '/profile': (context) => const ProfileScreen(),
          '/notification': (context) => const NotificationPage(),
          '/scan': (context) => const ScanPage(),
        },
      ),
    );
  }
}
