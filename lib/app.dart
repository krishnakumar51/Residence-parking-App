import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/navigation_menu.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NavigationMenu(),
    );
  }
}
