import 'package:adora_location_task/domain/services/background_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackingProvider extends ChangeNotifier {
  bool _isTrackingEnabled = false;
  bool get isTrackingEnabled => _isTrackingEnabled;

  TrackingProvider() {
    _loadTrackingState();
  }

  Future<void> _loadTrackingState() async {
    final prefs = await SharedPreferences.getInstance();
    _isTrackingEnabled = prefs.getBool('tracking_enabled') ?? false;
    notifyListeners();
  }

  Future<void> toggleTracking(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final service = FlutterBackgroundService();

    if (value) {
      await LocationBackgroundService.initializeService();
      await service.startService();
    } else {
      service.invoke('stop');
    }

    _isTrackingEnabled = value;
    await prefs.setBool('tracking_enabled', value);
    notifyListeners();
  }
}
