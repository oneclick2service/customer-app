import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/service_provider_model.dart';
import '../models/service_category_model.dart';
import '../models/booking_model.dart';
import '../widgets/custom_button.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({Key? key}) : super(key: key);

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  String _selectedPaymentMethod = 'upi';
  bool _isProcessing = false;
  String? _selectedAddress;
  List<String> _savedAddresses = [
    'Home - 123 Main Street, Vijayawada',
    'Office - 456 Business Park, Vijayawada',
    'Apartment - 789 Residency, Vijayawada',
  ];

  @override
  void initState() {
    super.initState();
    _selectedAddress = _savedAddresses.isNotEmpty
        ? _savedAddresses.first
        : null;
  }

  void _processBooking() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate booking processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
    });

    // Navigate to live tracking
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/live-tracking',
        (route) => false,
        arguments: {'bookingId': 'BK${DateTime.now().millisecondsSinceEpoch}'},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final provider = args?['provider'] as ServiceProvider?;
    final category = args?['category'] as ServiceCategory?;
    final service = args?['service'] as String?;
    final price = args?['price'] as double?;
    final isCustomRequest = args?['isCustomRequest'] as bool? ?? false;

    if (provider == null) {
      return Scaffold(
        body: Center(child: Text('Provider information not available')),
      );
    }

    final totalPrice = price ?? provider.hourlyRate;
    final serviceTax = totalPrice * 0.18; // 18% GST
    final finalPrice = totalPrice + serviceTax;

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
                        'Confirm Booking',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Provider Info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: provider.profileImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(25),
                                        child: Image.network(
                                          provider.profileImage!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  color:
                                                      AppConstants.primaryColor,
                                                  size: 25,
                                                );
                                              },
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        color: AppConstants.primaryColor,
                                        size: 25,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${provider.rating} ⭐ (${provider.totalReviews} reviews)',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Service Details
                        const Text(
                          'Service Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Service:',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    isCustomRequest
                                        ? 'Custom Request'
                                        : (service ?? 'General Service'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Category:',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    category?.name ?? 'General',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Estimated Duration:',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '1-2 hours',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Service Address
                        const Text(
                          'Service Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                value: _selectedAddress,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Select service address',
                                ),
                                items: _savedAddresses.map((address) {
                                  return DropdownMenuItem(
                                    value: address,
                                    child: Text(address),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAddress = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  // TODO: Navigate to address management
                                },
                                icon: const Icon(Icons.add_location, size: 16),
                                label: const Text('Add New Address'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Payment Method
                        const Text(
                          'Payment Method',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildPaymentOption(
                                'upi',
                                'UPI',
                                Icons.account_balance_wallet,
                              ),
                              const Divider(),
                              _buildPaymentOption(
                                'card',
                                'Credit/Debit Card',
                                Icons.credit_card,
                              ),
                              const Divider(),
                              _buildPaymentOption(
                                'wallet',
                                'Digital Wallet',
                                Icons.account_balance,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Price Breakdown
                        const Text(
                          'Price Breakdown',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Service Charge'),
                                  Text('₹${totalPrice.toStringAsFixed(0)}'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Service Tax (18%)'),
                                  Text('₹${serviceTax.toStringAsFixed(0)}'),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '₹${finalPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppConstants.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Save for Later',
                                onPressed: () {
                                  // TODO: Save booking for later
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Booking saved for later'),
                                    ),
                                  );
                                },
                                backgroundColor: Colors.grey[200],
                                textColor: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                text: _isProcessing
                                    ? 'Processing...'
                                    : 'Confirm & Pay',
                                onPressed: _isProcessing
                                    ? null
                                    : _processBooking,
                                icon: _isProcessing
                                    ? Icons.hourglass_empty
                                    : Icons.payment,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Terms and Conditions
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'By confirming this booking, you agree to our terms of service and cancellation policy.',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String label, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (newValue) {
        setState(() {
          _selectedPaymentMethod = newValue!;
        });
      },
      title: Row(
        children: [
          Icon(
            icon,
            color: isSelected ? AppConstants.primaryColor : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      activeColor: AppConstants.primaryColor,
    );
  }
}
