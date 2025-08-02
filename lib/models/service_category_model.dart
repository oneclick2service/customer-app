import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final double basePrice;
  final List<String> services;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.basePrice,
    required this.services,
  });

  // Predefined service categories
  static const List<ServiceCategory> categories = [
    ServiceCategory(
      id: 'plumbing',
      name: 'Plumbing',
      description: 'Expert plumbing services for your home',
      icon: Icons.plumbing,
      color: Colors.blue,
      basePrice: 299.0,
      services: [
        'Pipe Repair',
        'Tap Installation',
        'Drain Cleaning',
        'Water Heater Repair',
        'Bathroom Fitting',
        'Kitchen Sink Repair',
      ],
    ),
    ServiceCategory(
      id: 'electrical',
      name: 'Electrical',
      description: 'Professional electrical services',
      icon: Icons.electrical_services,
      color: Colors.orange,
      basePrice: 199.0,
      services: [
        'Switch/Socket Repair',
        'Fan Installation',
        'Light Fitting',
        'MCB Repair',
        'Wiring Work',
        'Appliance Repair',
      ],
    ),
    ServiceCategory(
      id: 'cleaning',
      name: 'Cleaning',
      description: 'Comprehensive cleaning services',
      icon: Icons.cleaning_services,
      color: Colors.green,
      basePrice: 499.0,
      services: [
        'Deep Cleaning',
        'Regular Cleaning',
        'Kitchen Cleaning',
        'Bathroom Cleaning',
        'Carpet Cleaning',
        'Window Cleaning',
      ],
    ),
    ServiceCategory(
      id: 'appliance',
      name: 'Appliance Repair',
      description: 'Repair and maintenance for all appliances',
      icon: Icons.build,
      color: Colors.purple,
      basePrice: 449.0,
      services: [
        'AC Service',
        'Refrigerator Repair',
        'Washing Machine',
        'Microwave Repair',
        'Geyser Service',
        'RO Service',
      ],
    ),
    ServiceCategory(
      id: 'carpentry',
      name: 'Carpentry',
      description: 'Professional carpentry and woodwork',
      icon: Icons.handyman,
      color: Colors.brown,
      basePrice: 399.0,
      services: [
        'Furniture Repair',
        'Door Repair',
        'Window Repair',
        'Cabinet Making',
        'Shelf Installation',
        'Wood Polishing',
      ],
    ),
    ServiceCategory(
      id: 'painting',
      name: 'Painting',
      description: 'Interior and exterior painting services',
      icon: Icons.format_paint,
      color: Colors.red,
      basePrice: 799.0,
      services: [
        'Interior Painting',
        'Exterior Painting',
        'Wall Texture',
        'Primer Coating',
        'Touch-up Work',
        'Color Consultation',
      ],
    ),
  ];

  // Get category by ID
  static ServiceCategory? getById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Convert to Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'services': services,
    };
  }

  // Create from Map for JSON deserialization
  factory ServiceCategory.fromMap(Map<String, dynamic> map) {
    return ServiceCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      icon: _getIconFromString(map['icon'] ?? ''),
      color: _getColorFromString(map['color'] ?? ''),
      basePrice: (map['basePrice'] ?? 0.0).toDouble(),
      services: List<String>.from(map['services'] ?? []),
    );
  }

  // Helper method to get icon from string
  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'build':
        return Icons.build;
      case 'handyman':
        return Icons.handyman;
      case 'format_paint':
        return Icons.format_paint;
      default:
        return Icons.category;
    }
  }

  // Helper method to get color from string
  static Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'brown':
        return Colors.brown;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
