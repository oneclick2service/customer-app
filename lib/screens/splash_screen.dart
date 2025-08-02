import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import 'test_screen.dart';
import 'account_type_selection_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check for auto-login
    final isLoggedIn = await authProvider.checkAutoLogin();
    
    if (mounted) {
      if (isLoggedIn) {
        // User is logged in, go to main app
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TestScreen()),
        );
      } else {
        // Check if user has completed onboarding
        final currentUser = authProvider.currentUser;
        if (currentUser != null && currentUser.name != null) {
          // User exists but needs to complete profile
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AccountTypeSelectionScreen()),
          );
        } else {
          // New user, start onboarding
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppConstants.primaryColor, Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge,
                    ),
                    boxShadow: AppConstants.elevatedShadow,
                  ),
                  child: const Icon(
                    Icons.home_repair_service,
                    size: 60,
                    color: AppConstants.primaryColor,
                  ),
                ),

                const SizedBox(height: AppConstants.paddingXLarge),

                // App Name
                Text(
                  'One Click 2 Service',
                  style: AppConstants.headingStyle.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.paddingMedium),

                Text(
                  'Your trusted service provider in Vijayawada',
                  style: AppConstants.bodyStyle.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.paddingXLarge),

                // Loading Indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                Text(
                  'Loading...',
                  style: AppConstants.bodyStyle.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 