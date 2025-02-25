import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static LocationService instance = LocationService._constructor();

  LocationService._constructor();

  Future<List<Placemark>> getLocationFromPosition(Position position) async {
    return await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
  }

  Future<Position?> getCurrentPosition() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationEnabled) {
      print("Location services are disabled.");
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permission denied.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      print("Location permission is permanently denied.");
      await Geolocator.openAppSettings();
      return null;
    }
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  Future<String> getCurrentLocation() async {
    Position? currentPosition = await getCurrentPosition();
    List<Placemark> places = await getLocationFromPosition(currentPosition!);

    return "${places[0].street}, ${places[0].name}";
  }

  Future<void> requestPermissions() async {
    // Request "When In Use" first
    PermissionStatus whenInUseStatus =
        await Permission.locationWhenInUse.request();

    if (whenInUseStatus.isGranted) {
      // Now request "Always" permission
      PermissionStatus alwaysStatus = await Permission.locationAlways.request();

      if (!alwaysStatus.isGranted) {
        print("User denied locationAlways permission.");
      }
    } else {
      print("User denied locationWhenInUse permission.");
    }

    // Request other permissions
    await Permission.notification.request();
    await Permission.ignoreBatteryOptimizations.request();
  }
}
