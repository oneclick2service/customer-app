import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/service_provider_model.dart';
import '../models/service_category_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/provider_card.dart';

class ProviderSelectionScreen extends StatefulWidget {
  const ProviderSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ProviderSelectionScreen> createState() =>
      _ProviderSelectionScreenState();
}

class _ProviderSelectionScreenState extends State<ProviderSelectionScreen> {
  List<ServiceProvider> _providers = [];
  List<ServiceProvider> _filteredProviders = [];
  String _selectedFilter = 'all';
  String _selectedSort = 'rating';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  void _loadProviders() {
    // Simulate loading providers from API
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _providers = _getMockProviders();
        _filteredProviders = _providers;
        _isLoading = false;
      });
    });
  }

  List<ServiceProvider> _getMockProviders() {
    return [
      ServiceProvider(
        id: '1',
        name: 'Rajesh Kumar',
        phone: '+91 9876543210',
        email: 'rajesh@example.com',
        rating: 4.8,
        totalReviews: 127,
        experience: 5,
        specializations: ['Plumbing', 'Electrical'],
        isVerified: true,
        isAvailable: true,
        distance: 2.3,
        estimatedArrival: 15,
        hourlyRate: 299.0,
        profileImage: 'https://example.com/rajesh.jpg',
        address: 'Vijayawada, Andhra Pradesh',
        languages: ['Telugu', 'Hindi', 'English'],
        certifications: ['Licensed Plumber', 'Electrical Safety'],
        backgroundCheck: true,
        trustScore: 95,
      ),
      ServiceProvider(
        id: '2',
        name: 'Suresh Reddy',
        phone: '+91 9876543211',
        email: 'suresh@example.com',
        rating: 4.6,
        totalReviews: 89,
        experience: 3,
        specializations: ['Cleaning', 'Appliance Repair'],
        isVerified: true,
        isAvailable: true,
        distance: 1.8,
        estimatedArrival: 12,
        hourlyRate: 249.0,
        profileImage: 'https://example.com/suresh.jpg',
        address: 'Vijayawada, Andhra Pradesh',
        languages: ['Telugu', 'English'],
        certifications: ['Professional Cleaner'],
        backgroundCheck: true,
        trustScore: 88,
      ),
      ServiceProvider(
        id: '3',
        name: 'Mohan Singh',
        phone: '+91 9876543212',
        email: 'mohan@example.com',
        rating: 4.9,
        totalReviews: 203,
        experience: 8,
        specializations: ['Carpentry', 'Painting'],
        isVerified: true,
        isAvailable: false,
        distance: 3.1,
        estimatedArrival: 25,
        hourlyRate: 399.0,
        profileImage: 'https://example.com/mohan.jpg',
        address: 'Vijayawada, Andhra Pradesh',
        languages: ['Hindi', 'English'],
        certifications: ['Master Carpenter', 'Professional Painter'],
        backgroundCheck: true,
        trustScore: 97,
      ),
      ServiceProvider(
        id: '4',
        name: 'Venkat Rao',
        phone: '+91 9876543213',
        email: 'venkat@example.com',
        rating: 4.4,
        totalReviews: 67,
        experience: 2,
        specializations: ['Electrical'],
        isVerified: false,
        isAvailable: true,
        distance: 4.2,
        estimatedArrival: 30,
        hourlyRate: 199.0,
        profileImage: 'https://example.com/venkat.jpg',
        address: 'Vijayawada, Andhra Pradesh',
        languages: ['Telugu', 'English'],
        certifications: ['Electrical Apprentice'],
        backgroundCheck: false,
        trustScore: 72,
      ),
    ];
  }

  void _applyFilters() {
    setState(() {
      _filteredProviders = _providers.where((provider) {
        // Availability filter
        if (_selectedFilter == 'available' && !provider.isAvailable) {
          return false;
        }
        if (_selectedFilter == 'verified' && !provider.isVerified) {
          return false;
        }
        if (_selectedFilter == 'nearby' && provider.distance > 5.0) {
          return false;
        }
        return true;
      }).toList();

      // Apply sorting
      switch (_selectedSort) {
        case 'rating':
          _filteredProviders.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'distance':
          _filteredProviders.sort((a, b) => a.distance.compareTo(b.distance));
          break;
        case 'price':
          _filteredProviders.sort(
            (a, b) => a.hourlyRate.compareTo(b.hourlyRate),
          );
          break;
        case 'experience':
          _filteredProviders.sort(
            (a, b) => b.experience.compareTo(a.experience),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final category = args?['category'] as ServiceCategory?;
    final service = args?['service'] as String?;
    final price = args?['price'] as double?;
    final isCustomRequest = args?['isCustomRequest'] as bool? ?? false;

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
                    Expanded(
                      child: Column(
                        children: [
                          const Text(
                            'Select Service Provider',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (category != null)
                            Text(
                              '${category.name} - ${service ?? "Custom Request"}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
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
                      // Filters
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Filter Chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterChip('all', 'All'),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('available', 'Available'),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('verified', 'Verified'),
                                  const SizedBox(width: 8),
                                  _buildFilterChip('nearby', 'Nearby'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Sort Dropdown
                            Row(
                              children: [
                                const Text(
                                  'Sort by: ',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                DropdownButton<String>(
                                  value: _selectedSort,
                                  underline: Container(),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'rating',
                                      child: Text('Rating'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'distance',
                                      child: Text('Distance'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'price',
                                      child: Text('Price'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'experience',
                                      child: Text('Experience'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSort = value!;
                                    });
                                    _applyFilters();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Providers List
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _filteredProviders.isEmpty
                            ? const Center(
                                child: Text(
                                  'No providers available',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: _filteredProviders.length,
                                itemBuilder: (context, index) {
                                  final provider = _filteredProviders[index];
                                  return ProviderCard(
                                    provider: provider,
                                    onTap: () {
                                      // Navigate to booking confirmation
                                      Navigator.pushNamed(
                                        context,
                                        '/booking-confirmation',
                                        arguments: {
                                          'provider': provider,
                                          'category': category,
                                          'service': service,
                                          'price': price ?? provider.hourlyRate,
                                          'isCustomRequest': isCustomRequest,
                                        },
                                      );
                                    },
                                  );
                                },
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

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _applyFilters();
      },
      backgroundColor: Colors.grey[200],
      selectedColor: AppConstants.primaryColor.withOpacity(0.2),
      checkmarkColor: AppConstants.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppConstants.primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
