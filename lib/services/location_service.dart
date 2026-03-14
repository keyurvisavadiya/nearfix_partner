import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class ProviderLocationService {
  Timer? _locationTimer;
  final String apiUrl = "https://sal-unstunted-guadalupe.ngrok-free.dev/nearfix/update_provider_location.php";

  Future<void> startTracking(String providerId) async {
    // 1. Check if location services are enabled on the phone
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // You could show a snackbar here: "Please enable GPS"
      return;
    }

    // 2. Check and Request Permissions
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // This is what triggers the "Allow this time / While using app" popup
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // User rejected the permission
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // User clicked "Don't ask again" - they must go to settings now
      return;
    }

    // 3. If all good, start tracking
    stopTracking();
    _sendLocationUpdate(providerId, 1);

    _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _sendLocationUpdate(providerId, 1);
    });
  }

  // FIXED: Added curly braces to define 'providerId' as a named parameter
  void stopTracking({String? providerId}) async {
    _locationTimer?.cancel();
    _locationTimer = null;

    if (providerId != null) {
      await _sendLocationUpdate(providerId, 0);
    }
  }

  Future<void> _sendLocationUpdate(String providerId, int onlineStatus) async {
    try {
      double lat = 0.0;
      double lng = 0.0;

      if (onlineStatus == 1) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        lat = position.latitude;
        lng = position.longitude;
      }

      await http.post(
        Uri.parse(apiUrl),
        body: {
          "provider_id": providerId,
          "latitude": lat.toString(),
          "longitude": lng.toString(),
          "is_online": onlineStatus.toString(),
        },
      );
    } catch (e) {
      print("Sync Error: $e");
    }
  }
}