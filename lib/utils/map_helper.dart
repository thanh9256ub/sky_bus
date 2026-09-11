import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapHelper {
  static LatLng? currentLocation;

  static Future<bool>? _permissionRequestFuture;

  static Future<bool> _checkPermission() async {
    if (_permissionRequestFuture != null) {
      return await _permissionRequestFuture!;
    }

    _permissionRequestFuture = _executePermissionCheck();

    try {
      return await _permissionRequestFuture!;
    } finally {
      _permissionRequestFuture = null;
    }
  }

  static Future<bool> _executePermissionCheck() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
  }

  static Future<LatLng?> getCurrentLocation() async {
    if (!await _checkPermission()) {
      return null;
    }

    if (currentLocation != null) {
      return currentLocation;
    }

    final lastKnown = await Geolocator.getLastKnownPosition();

    if (lastKnown != null) {
      currentLocation = LatLng(lastKnown.latitude, lastKnown.longitude);

      return currentLocation;
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
      ),
    );

    currentLocation = LatLng(pos.latitude, pos.longitude);

    return currentLocation;
  }

  static double calculateDistance(LatLng start, LatLng end) {
    final double distanceInMeters = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );

    return distanceInMeters / 1000;
  }
}
