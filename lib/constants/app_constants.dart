import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConstants {
  // App Information
  static const String appName = 'One Click';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Service Marketplace for Vijayawada';
  
  // Colors
  static const Color primaryColor = Color(0xFF2196F3); // Blue
  static const Color secondaryColor = Color(0xFFFFD700); // Gold
  static const Color accentColor = Color(0xFF4CAF50); // Green
  static const Color errorColor = Color(0xFFF44336); // Red
  static const Color warningColor = Color(0xFFFF9800); // Orange
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Styles
  static TextStyle get headingStyle => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static TextStyle get subheadingStyle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static TextStyle get bodyStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
  );

  static TextStyle get captionStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
  );

  static TextStyle get buttonStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;
  static const double marginXLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // Service Categories
  static const List<Map<String, dynamic>> serviceCategories = [
    {
      'id': 'electrical',
      'name': 'Electrical Services',
      'icon': '⚡',
      'description': 'Wiring, repairs, installations',
      'color': Color(0xFFFFD700),
    },
    {
      'id': 'plumbing',
      'name': 'Plumbing Services',
      'icon': '🔧',
      'description': 'Repairs, installations, maintenance',
      'color': Color(0xFF2196F3),
    },
    {
      'id': 'cleaning',
      'name': 'Cleaning Services',
      'icon': '🧹',
      'description': 'Home, office, specialized cleaning',
      'color': Color(0xFF4CAF50),
    },
    {
      'id': 'glass',
      'name': 'Glass Work',
      'icon': '🪟',
      'description': 'Repairs, installations, replacements',
      'color': Color(0xFF9C27B0),
    },
    {
      'id': 'mechanical',
      'name': 'Mechanical Services',
      'icon': '🔨',
      'description': 'Appliance repairs, installations',
      'color': Color(0xFFFF9800),
    },
  ];

  // Booking Status
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusAssigned = 'assigned';
  static const String statusEnRoute = 'en_route';
  static const String statusArrived = 'arrived';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Payment Methods
  static const String paymentUPI = 'upi';
  static const String paymentCash = 'cash';
  static const String paymentCard = 'card';

  // API Endpoints (will be configured with Supabase)
  static const String baseUrl = 'https://your-supabase-project.supabase.co';
  static const String apiKey = 'your-supabase-anon-key';

  // Location
  static const String defaultCity = 'Vijayawada';
  static const double defaultLatitude = 16.5062;
  static const double defaultLongitude = 80.6480;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Image Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImage = 'assets/images/placeholder.png';
  static const String defaultAvatar = 'assets/images/default_avatar.png';

  // App Store Links
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.oneclick.app';
  static const String appStoreUrl = 'https://apps.apple.com/app/one-click-service-marketplace';

  // Support
  static const String supportEmail = 'support@oneclick.com';
  static const String supportPhone = '+91-9876543210';
  static const String websiteUrl = 'https://oneclick.com';

  // Terms & Privacy
  static const String termsUrl = 'https://oneclick.com/terms';
  static const String privacyUrl = 'https://oneclick.com/privacy';
} 