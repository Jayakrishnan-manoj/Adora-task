import 'dart:async';
import 'dart:ui';

import 'package:adora_location_task/domain/services/database_service.dart';
import 'package:adora_location_task/domain/services/location_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
class LocationBackgroundService {
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static Future<void> onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    Timer.periodic(const Duration(minutes: 2), (timer) async {
      try {
        final position = await LocationService.instance.getCurrentPosition();
        if (position != null) {
          DatabaseService.instance.addLocation(position, DateTime.now());

          if (service is AndroidServiceInstance) {
            await service.setForegroundNotificationInfo(
              title: 'Location Tracking Active',
              content:
                  'Lat: ${position.latitude.toStringAsFixed(4)}, '
                  'Long: ${position.longitude.toStringAsFixed(4)}',
            );
          }
        }
      } catch (e) {
        print('Error updating location: $e');
      }
    });

    service.on('update').listen((event) {
      if (service is AndroidServiceInstance) {
        (service).setForegroundNotificationInfo(
          title: event?['title'] ?? 'Location Tracking Active',
          content: event?['content'] ?? '',
        );
      }
    });
  }

  static Future<void> initializeService() async {
    print("inside initializeService");
    final service = FlutterBackgroundService();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'location_tracker',
      'Location Tracking Service',
      description: "This channel is used for location tracking",
      importance: Importance.high,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel)
        .whenComplete(() {
          print("resolve notification channel");
        });

    await service
        .configure(
          iosConfiguration: IosConfiguration(
            autoStart: true,
            onForeground: onStart,
            onBackground: onIosBackground,
          ),
          androidConfiguration: AndroidConfiguration(
            onStart: onStart,
            autoStart: true,
            isForegroundMode: true,
            notificationChannelId: 'location_tracker',
            initialNotificationTitle: 'Location Tracking Active',
            initialNotificationContent: 'Initializing location tracking...',
            foregroundServiceNotificationId: 888,
          ),
        )
        .whenComplete(() {
          print("configuration done");
        });
  }
}
