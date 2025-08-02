import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryColor,
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              children: [
                const Spacer(),
                
                // Profile Setup Header
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                          boxShadow: AppConstants.elevatedShadow,
                        ),
                        child: const Icon(
                          Icons.person_add,
                          size: 40,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      Text(
                        'Complete Your Profile',
                        style: AppConstants.headingStyle.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: AppConstants.paddingMedium),
                      
                      Text(
                        'Help us personalize your experience',
                        style: AppConstants.bodyStyle.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppConstants.paddingXLarge),
                
                // Profile Form Placeholder
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                    boxShadow: AppConstants.elevatedShadow,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Profile Setup',
                        style: AppConstants.subheadingStyle.copyWith(
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      
                      const SizedBox(height: AppConstants.paddingMedium),
                      
                      Text(
                        'This screen will contain form fields for:\n• Full Name\n• Email Address\n• Address\n• City\n• State\n• Pincode\n• Corporate Account (Optional)',
                        style: AppConstants.captionStyle.copyWith(
                          color: AppConstants.textSecondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to home screen
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.paddingMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                            ),
                          ),
                          child: Text(
                            'Skip for Now',
                            style: AppConstants.buttonStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 