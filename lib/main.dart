import 'dart:async';

import 'package:adora_location_task/domain/provider/tracking_provider.dart';
import 'package:adora_location_task/domain/services/background_service.dart';
import 'package:adora_location_task/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  bool isTrackingEnabled = prefs.getBool('tracking_enabled') ?? false;

  await requestPermissions();

  if (isTrackingEnabled) {
    await LocationBackgroundService.initializeService();
  }

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
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TrackingProvider())],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}
