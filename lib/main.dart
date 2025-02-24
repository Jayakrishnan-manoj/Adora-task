import 'dart:async';

import 'package:adora_location_task/domain/services/background_service.dart';
import 'package:adora_location_task/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();

  // 🔥 Initialize background service
  await LocationBackgroundService.initializeService();
  runApp(const MyApp());
}

Future<void> requestPermissions() async {
  await [
    Permission.locationAlways,
    Permission.locationWhenInUse,
    Permission.notification,
    Permission.ignoreBatteryOptimizations,
  ].request();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
