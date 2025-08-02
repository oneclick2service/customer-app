import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/location_provider.dart';
import '../widgets/custom_button.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({Key? key}) : super(key: key);

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _userLocation;
  LatLng? _providerLocation;
  bool _isLoading = true;
  String _eta = 'Calculating...';
  String _distance = 'Calculating...';
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _initializeMap() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    // Get user location
    _userLocation = await locationProvider.getCurrentLocationAsLatLng();
    
    // Get booking details from arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bookingId = args?['bookingId'] as String?;
    
    if (bookingId != null) {
      await _loadBookingDetails(bookingId);
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadBookingDetails(String bookingId) async {
    // TODO: Load booking details from Supabase
    // For now, use mock data
    _providerLocation = const LatLng(16.5062, 80.6480); // Vijayawada center
    
    if (_userLocation != null && _providerLocation != null) {
      _updateMapMarkers();
      _calculateRoute();
      _updateETA();
    }
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateProviderLocation();
    });
  }

  void _updateProviderLocation() async {
    // TODO: Get real-time provider location from Supabase
    // For now, simulate movement
    if (_providerLocation != null) {
      setState(() {
        _providerLocation = LatLng(
          _providerLocation!.latitude + (0.001 * (DateTime.now().millisecond % 10 - 5)),
          _providerLocation!.longitude + (0.001 * (DateTime.now().millisecond % 10 - 5)),
        );
      });
      _updateMapMarkers();
      _updateETA();
    }
  }

  void _updateMapMarkers() {
    _markers.clear();
    
    if (_userLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: _userLocation!,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    
    if (_providerLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('provider'),
          position: _providerLocation!,
          infoWindow: const InfoWindow(title: 'Service Provider'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }
  }

  void _calculateRoute() async {
    if (_userLocation != null && _providerLocation != null) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final route = await locationProvider.getRoute(_userLocation!, _providerLocation!);
      
      if (route != null && route.length > 1) {
        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: route,
              color: AppConstants.primaryColor,
              width: 5,
            ),
          };
        });
      }
    }
  }

  void _updateETA() {
    if (_userLocation != null && _providerLocation != null) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final distance = locationProvider.calculateDistanceUsingMapsService(_userLocation!, _providerLocation!);
      final eta = locationProvider.calculateEstimatedTimeUsingMapsService(_userLocation!, _providerLocation!);
      
      setState(() {
        _distance = locationProvider.getFormattedDistance(distance);
        _eta = locationProvider.getFormattedTime(eta);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppConstants.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Live Tracking',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Open chat screen
                        Navigator.pushNamed(context, '/chat');
                      },
                      icon: const Icon(
                        Icons.chat,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Map Container
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: _userLocation ?? const LatLng(16.5062, 80.6480),
                                      zoom: 15,
                                    ),
                                    onMapCreated: (GoogleMapController controller) {
                                      _mapController = controller;
                                    },
                                    markers: _markers,
                                    polylines: _polylines,
                                    myLocationEnabled: true,
                                    myLocationButtonEnabled: true,
                                    zoomControlsEnabled: false,
                                    mapToolbarEnabled: false,
                                  ),
                          ),
                        ),
                      ),

                      // Tracking Info
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Status Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppConstants.primaryColor),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppConstants.primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.local_shipping,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Provider is on the way',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Estimated arrival: $_eta',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Info Cards
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoCard(
                                    icon: Icons.location_on,
                                    title: 'Distance',
                                    value: _distance,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInfoCard(
                                    icon: Icons.access_time,
                                    title: 'ETA',
                                    value: _eta,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Action Buttons
                            Row(
                              children: [
                                                                 Expanded(
                                   child: CustomButton(
                                     text: 'Call Provider',
                                     onPressed: () {
                                       // TODO: Implement call functionality
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         const SnackBar(
                                           content: Text('Calling provider...'),
                                         ),
                                       );
                                     },
                                     backgroundColor: Colors.green,
                                   ),
                                 ),
                                 const SizedBox(width: 12),
                                 Expanded(
                                   child: CustomButton(
                                     text: 'Chat',
                                     onPressed: () {
                                       Navigator.pushNamed(context, '/chat');
                                     },
                                     backgroundColor: AppConstants.primaryColor,
                                   ),
                                 ),
                               ],
                             ),

                             const SizedBox(height: 12),

                             CustomButton(
                               text: 'Cancel Booking',
                               onPressed: () {
                                 _showCancelDialog();
                               },
                               backgroundColor: Colors.red,
                               textColor: Colors.white,
                             ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Cancel booking in Supabase
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
} 