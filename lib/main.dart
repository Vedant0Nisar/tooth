import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ui/main_screen.dart';

void main() {
  runApp(const ToothApp());
}

class ToothApp extends StatelessWidget {
  const ToothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '3D Transform Engine',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.greenAccent,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
