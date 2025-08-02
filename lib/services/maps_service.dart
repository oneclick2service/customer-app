import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapsService {
  static const String _apiKey =
      'YOUR_GOOGLE_MAPS_API_KEY'; // Replace with actual API key

  // Get route between two points
  static Future<List<LatLng>?> getRoute(
    LatLng origin,
    LatLng destination,
  ) async {
    try {
      // TODO: Implement actual Google Maps Directions API
      // For now, return a simple straight line
      return [origin, destination];
    } catch (e) {
      print('Error getting route: $e');
      return null;
    }
  }

  // Calculate distance between two points
  static double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  // Calculate estimated travel time
  static int calculateEstimatedTime(LatLng origin, LatLng destination) {
    final distance = calculateDistance(origin, destination);
    // Assume average speed of 30 km/h
    final timeInMinutes = (distance / 1000) / 30 * 60;
    return timeInMinutes.round();
  }

  // Check if location is within service area
  static bool isWithinServiceArea(LatLng location) {
    // Define Vijayawada service area bounds
    const vijayawadaCenter = LatLng(16.5062, 80.6480);
    const maxDistanceKm = 50.0; // 50km radius

    final distance = calculateDistance(location, vijayawadaCenter);
    return distance <= maxDistanceKm * 1000; // Convert to meters
  }

  // Format distance for display
  static String getFormattedDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()}m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceInKm.round()}km';
    }
  }

  // Format time for display
  static String getFormattedTime(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
    }
  }

  // Get current location
  static Future<LatLng?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Validate if location is accessible
  static Future<bool> isLocationAccessible(LatLng location) async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Check location permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error checking location accessibility: $e');
      return false;
    }
  }

  // Get address from coordinates
  static Future<String?> getAddressFromCoordinates(LatLng location) async {
    try {
      // TODO: Implement actual geocoding
      // For now, return coordinates as string
      return '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  // Get coordinates from address
  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      // TODO: Implement actual geocoding
      // For now, return null
      return null;
    } catch (e) {
      print('Error getting coordinates: $e');
      return null;
    }
  }

  // Calculate bearing between two points
  static double calculateBearing(LatLng start, LatLng end) {
    final lat1 = start.latitude * (pi / 180);
    final lat2 = end.latitude * (pi / 180);
    final lng1 = start.longitude * (pi / 180);
    final lng2 = end.longitude * (pi / 180);

    final y = sin(lng2 - lng1) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lng2 - lng1);

    final bearing = atan2(y, x) * (180 / pi);
    return (bearing + 360) % 360;
  }

  // Check if two locations are nearby (within specified distance)
  static bool isNearby(
    LatLng location1,
    LatLng location2,
    double maxDistanceMeters,
  ) {
    final distance = calculateDistance(location1, location2);
    return distance <= maxDistanceMeters;
  }

  // Get service area polygon (for Vijayawada)
  static List<LatLng> getServiceAreaPolygon() {
    // Define a simple polygon around Vijayawada
    return [
      const LatLng(16.4562, 80.5980), // Southwest
      const LatLng(16.4562, 80.6980), // Southeast
      const LatLng(16.5562, 80.6980), // Northeast
      const LatLng(16.5562, 80.5980), // Northwest
    ];
  }

  // Check if location is within polygon
  static bool isLocationInPolygon(LatLng location, List<LatLng> polygon) {
    // Simple point-in-polygon check
    // TODO: Implement proper ray casting algorithm
    return true; // Placeholder
  }
}
