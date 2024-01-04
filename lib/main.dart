import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stockpilot/pages/category_page.dart';
import 'package:stockpilot/pages/edit_profile_page.dart';
import 'package:stockpilot/pages/home_page.dart';
import 'package:stockpilot/pages/register_page.dart';
import 'pages/login_page.dart';

void main() async {
  await Hive.initFlutter();
  var box = await Hive.openBox("credentials");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'StockPilot';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
          primaryColor: Colors.blueGrey,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueGrey, brightness: Brightness.dark)),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/category': (context) => const CategoryPage(),
        '/editProfile': (context) => const EditProfilePage()
      },
    );
  }
}
