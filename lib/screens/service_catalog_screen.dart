import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/service_category_model.dart';
import '../widgets/custom_button.dart';

class ServiceCatalogScreen extends StatefulWidget {
  final ServiceCategory category;

  const ServiceCatalogScreen({Key? key, required this.category})
    : super(key: key);

  @override
  State<ServiceCatalogScreen> createState() => _ServiceCatalogScreenState();
}

class _ServiceCatalogScreenState extends State<ServiceCatalogScreen> {
  String? selectedService;
  Map<String, double> servicePrices = {};

  @override
  void initState() {
    super.initState();
    _loadServicePrices();
  }

  void _loadServicePrices() {
    // Load pricing data for the selected category
    switch (widget.category.id) {
      case 'plumbing':
        servicePrices = {
          'Pipe Repair': 299.0,
          'Tap Installation': 199.0,
          'Drain Cleaning': 399.0,
          'Water Heater Repair': 599.0,
          'Bathroom Fitting': 499.0,
          'Kitchen Sink Repair': 349.0,
        };
        break;
      case 'electrical':
        servicePrices = {
          'Switch/Socket Repair': 199.0,
          'Fan Installation': 299.0,
          'Light Fitting': 149.0,
          'MCB Repair': 399.0,
          'Wiring Work': 599.0,
          'Appliance Repair': 449.0,
        };
        break;
      case 'cleaning':
        servicePrices = {
          'Deep Cleaning': 799.0,
          'Regular Cleaning': 499.0,
          'Kitchen Cleaning': 399.0,
          'Bathroom Cleaning': 299.0,
          'Carpet Cleaning': 599.0,
          'Window Cleaning': 249.0,
        };
        break;
      case 'appliance':
        servicePrices = {
          'AC Service': 699.0,
          'Refrigerator Repair': 599.0,
          'Washing Machine': 549.0,
          'Microwave Repair': 399.0,
          'Geyser Service': 449.0,
          'RO Service': 349.0,
        };
        break;
      case 'carpentry':
        servicePrices = {
          'Furniture Repair': 399.0,
          'Door Repair': 299.0,
          'Window Repair': 249.0,
          'Cabinet Making': 899.0,
          'Shelf Installation': 199.0,
          'Wood Polishing': 499.0,
        };
        break;
      case 'painting':
        servicePrices = {
          'Interior Painting': 1299.0,
          'Exterior Painting': 1599.0,
          'Wall Texture': 899.0,
          'Primer Coating': 599.0,
          'Touch-up Work': 299.0,
          'Color Consultation': 199.0,
        };
        break;
      default:
        servicePrices = {
          'Basic Service': 299.0,
          'Standard Service': 499.0,
          'Premium Service': 799.0,
        };
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
                    Expanded(
                      child: Text(
                        widget.category.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the header
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
                      // Category Info
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                widget.category.icon,
                                color: AppConstants.primaryColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.category.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    widget.category.description,
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

                      // Services List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: servicePrices.length,
                          itemBuilder: (context, index) {
                            String serviceName = servicePrices.keys.elementAt(
                              index,
                            );
                            double price = servicePrices.values.elementAt(
                              index,
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: selectedService == serviceName
                                    ? AppConstants.primaryColor.withOpacity(0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: selectedService == serviceName
                                    ? Border.all(
                                        color: AppConstants.primaryColor,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                title: Text(
                                  serviceName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  'Starting from ₹${price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: AppConstants.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppConstants.primaryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '₹${price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedService = serviceName;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      // Action Buttons
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            if (selectedService != null) ...[
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Selected: $selectedService',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '₹${servicePrices[selectedService]!.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: AppConstants.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: 'Custom Request',
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/custom-request',
                                      );
                                    },
                                    backgroundColor: Colors.grey[200],
                                    textColor: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomButton(
                                    text: selectedService != null
                                        ? 'Book Now'
                                        : 'Select Service',
                                    onPressed: selectedService != null
                                        ? () {
                                            // Navigate to provider selection
                                            Navigator.pushNamed(
                                              context,
                                              '/provider-selection',
                                              arguments: {
                                                'category': widget.category,
                                                'service': selectedService,
                                                'price':
                                                    servicePrices[selectedService],
                                              },
                                            );
                                          }
                                        : null,
                                  ),
                                ),
                              ],
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
}
