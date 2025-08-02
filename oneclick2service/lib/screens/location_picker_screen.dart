import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../constants/app_constants.dart';
import '../providers/location_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LocationPickerScreen extends StatefulWidget {
  final bool isPrimaryLocation;

  const LocationPickerScreen({super.key, this.isPrimaryLocation = true});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final LocationProvider _locationProvider = LocationProvider();
  final AuthProvider _authProvider = AuthProvider();

  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(
    16.5062,
    80.6480,
  ); // Vijayawada coordinates
  String _selectedAddress = '';
  bool _isLoading = false;
  String? _error;
  Set<Marker> _markers = {};

  // Vijayawada service areas
  final List<LatLng> _vijayawadaAreas = [
    const LatLng(16.5062, 80.6480), // City Center
    const LatLng(16.5200, 80.6400), // One Town
    const LatLng(16.4900, 80.6600), // Auto Nagar
    const LatLng(16.5300, 80.6300), // Patamata
    const LatLng(16.4800, 80.6800), // Benz Circle
    const LatLng(16.5400, 80.6200), // Gannavaram
  ];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check location permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          setState(() {
            _error = 'Location permission is required';
            _isLoading = false;
          });
          return;
        }
      }

      // Get current location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      await _getAddressFromCoordinates(_selectedLocation);
      _updateMarkers();
    } catch (e) {
      setState(() {
        _error = 'Failed to get current location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromCoordinates(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          _selectedAddress = _formatAddress(placemark);
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress =
            '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
      });
    }
  }

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

  void _updateMarkers() {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation,
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet: _selectedAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });
  }

  Future<void> _searchLocation() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final locations = await locationFromAddress(_searchController.text);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final newLocation = LatLng(location.latitude, location.longitude);

        setState(() {
          _selectedLocation = newLocation;
          _isLoading = false;
        });

        await _getAddressFromCoordinates(newLocation);
        _updateMarkers();

        // Animate camera to new location
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newLocation, 15),
        );
      } else {
        setState(() {
          _error = 'Location not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to search location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _getAddressFromCoordinates(location);
    _updateMarkers();
  }

  void _onCameraMove(CameraPosition position) {
    // Update selected location when user drags the map
    setState(() {
      _selectedLocation = position.target;
    });
  }

  void _onCameraIdle() async {
    // Get address when camera stops moving
    await _getAddressFromCoordinates(_selectedLocation);
    _updateMarkers();
  }

  Future<void> _saveLocation() async {
    if (_selectedAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update user's location in auth provider
      if (_authProvider.currentUser != null) {
        final updatedUser = _authProvider.currentUser!.copyWith(
          latitude: _selectedLocation.latitude,
          longitude: _selectedLocation.longitude,
          address: _selectedAddress,
          city: 'Vijayawada',
          state: 'Andhra Pradesh',
          updatedAt: DateTime.now(),
        );

        await _authProvider.updateUserLocation(updatedUser);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(
          context,
        ).pop({'location': _selectedLocation, 'address': _selectedAddress});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isPrimaryLocation ? 'Set Primary Location' : 'Select Location',
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _searchController,
                    hintText: 'Search for location...',
                    prefixIcon: const Icon(Icons.search),
                    onSubmitted: (_) => _searchLocation(),
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                IconButton(
                  onPressed: _searchLocation,
                  icon: const Icon(Icons.search),
                  style: IconButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Error Message
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              color: Colors.red.shade50,
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
              ),
            ),

          // Map
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _updateMarkers();
                  },
                  onTap: _onMapTap,
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),

                // Current Location Button
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _initializeLocation,
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.my_location),
                  ),
                ),

                // Vijayawada Areas Button
                Positioned(
                  bottom: 170,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _showVijayawadaAreas,
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.location_city),
                  ),
                ),
              ],
            ),
          ),

          // Selected Location Info
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppConstants.primaryColor,
                    ),
                    const SizedBox(width: AppConstants.paddingSmall),
                    Expanded(
                      child: Text(
                        'Selected Location',
                        style: AppConstants.subheadingStyle.copyWith(
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingSmall),
                Text(
                  _selectedAddress.isNotEmpty
                      ? _selectedAddress
                      : 'Tap on map to select location',
                  style: AppConstants.bodyStyle.copyWith(
                    color: AppConstants.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: _isLoading ? null : _saveLocation,
                    text: _isLoading ? 'Saving...' : 'Save Location',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showVijayawadaAreas() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Popular Areas in Vijayawada',
              style: AppConstants.headingStyle.copyWith(
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Expanded(
              child: ListView.builder(
                itemCount: _vijayawadaAreas.length,
                itemBuilder: (context, index) {
                  final area = _vijayawadaAreas[index];
                  final areaNames = [
                    'City Center',
                    'One Town',
                    'Auto Nagar',
                    'Patamata',
                    'Benz Circle',
                    'Gannavaram',
                  ];

                  return ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: AppConstants.primaryColor,
                    ),
                    title: Text(areaNames[index]),
                    subtitle: Text(
                      '${area.latitude.toStringAsFixed(4)}, ${area.longitude.toStringAsFixed(4)}',
                    ),
                    onTap: () {
                      setState(() {
                        _selectedLocation = area;
                      });
                      _getAddressFromCoordinates(area);
                      _updateMarkers();
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(area, 15),
                      );
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
