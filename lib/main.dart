import 'package:flutter/material.dart';
import 'package:skysoft_bus/screens/roots/main_screen.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
        title: 'Skysoft Bus',
        theme: ThemeData(
          colorScheme: .fromSeed(seedColor: Colors.orange[800]!),
        ),
        debugShowCheckedModeBanner: false,
        home: MainScreen(),
      ),
    );
  }
}
