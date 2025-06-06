import 'package:geolocator/geolocator.dart';

class LocationService {
  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check current permission status
  Future<LocationPermission> checkPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  Future<LocationPermissionStatus> requestLocationPermission() async {
    LocationPermissionStatus status = LocationPermissionStatus();

    // First, check if location services are enabled
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      status.isEnabled = false;
      status.message =
          'Location services are disabled. Please enable them in settings.';
      return status;
    }

    // Check current permission status
    LocationPermission permission = await checkPermissionStatus();

    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        status.isGranted = false;
        status.message = 'Location permission denied';
        return status;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      status.isGranted = false;
      status.message =
          'Location permission permanently denied. Please enable in settings.';
      return status;
    }

    // Permission granted
    status.isGranted = true;
    status.message = 'Location permission granted';
    return status;
  }
}

// Status class to handle permission results
class LocationPermissionStatus {
  bool isEnabled;
  bool isGranted;
  String message;

  LocationPermissionStatus({
    this.isEnabled = true,
    this.isGranted = false,
    this.message = '',
  });
}
