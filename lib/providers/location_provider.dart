import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/maps_service.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isLoading = false;
  String? _error;
  bool _hasLocationPermission = false;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLocationPermission => _hasLocationPermission;

  // Initialize location services
  Future<void> initializeLocation() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check location permission
      final permission = await Permission.location.request();
      _hasLocationPermission = permission.isGranted;

      if (!_hasLocationPermission) {
        _error = 'Location permission is required to use this app';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Location services are disabled. Please enable location services.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get current position
      await getCurrentLocation();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get current location
  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _currentPosition = position;
      await _getAddressFromCoordinates(position.latitude, position.longitude);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get address from coordinates
  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _currentAddress = _formatAddress(placemark);
      }
    } catch (e) {
      // If geocoding fails, we'll just use coordinates
      _currentAddress = '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    }
  }

  // Format address from placemark
  String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    
    if (placemark.street?.isNotEmpty == true) {
      parts.add(placemark.street!);
    }
    if (placemark.subLocality?.isNotEmpty == true) {
      parts.add(placemark.subLocality!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.postalCode?.isNotEmpty == true) {
      parts.add(placemark.postalCode!);
    }

    return parts.join(', ');
  }

  // Get coordinates from address
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final position = Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );

        _isLoading = false;
        notifyListeners();
        return position;
      }

      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Calculate distance between two points
  double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Get estimated travel time (simplified calculation)
  Duration getEstimatedTravelTime(double distanceInMeters, {double averageSpeedKmh = 30}) {
    // Convert distance to kilometers
    final distanceKm = distanceInMeters / 1000;
    
    // Calculate time in hours
    final timeInHours = distanceKm / averageSpeedKmh;
    
    // Convert to minutes
    final timeInMinutes = (timeInHours * 60).round();
    
    return Duration(minutes: timeInMinutes);
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Permission.location.request();
      _hasLocationPermission = permission.isGranted;
      notifyListeners();
      return _hasLocationPermission;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Check if location services are enabled
  Future<bool> checkLocationServices() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Location services are disabled. Please enable location services.';
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Set current position manually (for testing or when GPS is not available)
  void setCurrentPosition(Position position) {
    _currentPosition = position;
    _getAddressFromCoordinates(position.latitude, position.longitude);
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get current location as LatLng
  Future<LatLng?> getCurrentLocationAsLatLng() async {
    try {
      await getCurrentLocation();
      if (_currentPosition != null) {
        return LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      }
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Get route between two points
  Future<List<LatLng>?> getRoute(LatLng origin, LatLng destination) async {
    try {
      return await MapsService.getRoute(origin, destination);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Calculate distance using MapsService
  double calculateDistanceUsingMapsService(LatLng point1, LatLng point2) {
    return MapsService.calculateDistance(point1, point2);
  }

  // Calculate estimated time using MapsService
  int calculateEstimatedTimeUsingMapsService(LatLng origin, LatLng destination) {
    return MapsService.calculateEstimatedTime(origin, destination);
  }

  // Check if location is within service area
  bool isWithinServiceArea(LatLng location) {
    return MapsService.isWithinServiceArea(location);
  }

  // Get formatted distance string
  String getFormattedDistance(double distanceInKm) {
    return MapsService.getFormattedDistance(distanceInKm);
  }

  // Get formatted time string
  String getFormattedTime(int minutes) {
    return MapsService.getFormattedTime(minutes);
  }
} 