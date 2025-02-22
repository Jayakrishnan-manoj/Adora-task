import 'dart:async';

import 'package:adora_location_task/domain/services/database_service.dart';
import 'package:adora_location_task/domain/services/location_service.dart';
import 'package:adora_location_task/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
  // Timer.periodic(Duration(seconds: 15), (timer) async {
  //   final Position? position =
  //       await LocationService.instance.getCurrentPosition();
  //   print(position!.latitude.toString());
  //   DatabaseService.instance.addLocation(position, DateTime.now());
  // });
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
