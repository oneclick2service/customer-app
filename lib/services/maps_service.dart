import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapsService {
  static const String _apiKey = 'YOUR_GOOGLE_MAPS_API_KEY'; // TODO: Replace with actual API key
  
  // Default location (Vijayawada, Andhra Pradesh)
  static const LatLng _defaultLocation = LatLng(16.5062, 80.6480);
  
  // Get current location
  static Future<LatLng?> getCurrentLocation() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return null;
      }
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }
  
  // Get address from coordinates
  static Future<String?> getAddressFromCoordinates(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.administrativeArea}';
      }
      return null;
    } catch (e) {
      debugPrint('Error getting address: $e');
      return null;
    }
  }
  
  // Get coordinates from address
  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
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
    ) / 1000; // Convert to kilometers
  }
  
  // Calculate estimated travel time (in minutes)
  static int calculateEstimatedTime(LatLng origin, LatLng destination) {
    double distance = calculateDistance(origin, destination);
    // Assume average speed of 30 km/h in city
    return (distance / 30 * 60).round();
  }
  
  // Get route between two points
  static Future<List<LatLng>?> getRoute(LatLng origin, LatLng destination) async {
    try {
      // TODO: Implement actual route calculation using Google Directions API
      // For now, return a simple straight line
      return [origin, destination];
    } catch (e) {
      debugPrint('Error getting route: $e');
      return null;
    }
  }
  
  // Create custom marker icon
  static Future<BitmapDescriptor> createCustomMarker({
    required String title,
    Color color = Colors.blue,
  }) async {
    // TODO: Implement custom marker creation
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  }
  
  // Get map style for dark/light theme
  static String getMapStyle(bool isDark) {
    if (isDark) {
      return '''
        [
          {
            "elementType": "geometry",
            "stylers": [
              {
                "color": "#212121"
              }
            ]
          },
          {
            "elementType": "labels.text.fill",
            "stylers": [
              {
                "color": "#757575"
              }
            ]
          },
          {
            "elementType": "labels.text.stroke",
            "stylers": [
              {
                "color": "#212121"
              }
            ]
          },
          {
            "featureType": "administrative",
            "elementType": "geometry",
            "stylers": [
              {
                "color": "#757575"
              }
            ]
          },
          {
            "featureType": "landscape",
            "elementType": "geometry",
            "stylers": [
              {
                "color": "#212121"
              }
            ]
          },
          {
            "featureType": "poi",
            "elementType": "labels.text.fill",
            "stylers": [
              {
                "color": "#757575"
              }
            ]
          },
          {
            "featureType": "road",
            "elementType": "geometry",
            "stylers": [
              {
                "color": "#424242"
              }
            ]
          },
          {
            "featureType": "road",
            "elementType": "labels.text.fill",
            "stylers": [
              {
                "color": "#424242"
              }
            ]
          },
          {
            "featureType": "road.highway",
            "elementType": "geometry",
            "stylers": [
              {
                "color": "#424242"
              }
            ]
          },
          {
            "featureType": "road.highway",
            "elementType": "labels.text.fill",
            "stylers": [
              {
                "color": "#616161"
              }
            ]
          },
          {
            "featureType": "road.highway",
            "elementType": "labels.text.stroke",
            "stylers": [
              {
                "color": "#212121"
              }
            ]
          },
          {
            "featureType": "transit",
            "elementType": "geometry",
            "stylers": [
              {
                "color": "#212121"
              }
            ]
          },
          {
            "featureType": "water",
            "elementType": "geometry",
            "stylers": [
              {
                "color": "#000000"
              }
            ]
          },
          {
            "featureType": "water",
            "elementType": "labels.text.fill",
            "stylers": [
              {
                "color": "#3d3d3d"
              }
            ]
          }
        ]
      ''';
    } else {
      return ''; // Default light theme
    }
  }
  
  // Validate if location is within service area (Vijayawada)
  static bool isWithinServiceArea(LatLng location) {
    // Vijayawada city limits (approximate)
    const LatLng vijayawadaCenter = LatLng(16.5062, 80.6480);
    const double maxDistance = 25.0; // 25 km radius
    
    double distance = calculateDistance(location, vijayawadaCenter);
    return distance <= maxDistance;
  }
  
  // Get formatted distance string
  static String getFormattedDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }
  
  // Get formatted time string
  static String getFormattedTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      return '$hours hr ${remainingMinutes} min';
    }
  }
} 