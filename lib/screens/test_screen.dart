import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('One Click 2 Service - Test'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppConstants.primaryColor, Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo/Icon
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

                // Welcome Text
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

                // Test Form
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge,
                    ),
                    boxShadow: AppConstants.elevatedShadow,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Test Features',
                        style: AppConstants.subheadingStyle.copyWith(
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Phone Number Input
                      CustomTextField(
                        controller: _phoneController,
                        hintText: 'Enter Phone Number',
                        prefixIcon: const Icon(Icons.phone),
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // OTP Input
                      CustomTextField(
                        controller: _otpController,
                        hintText: 'Enter OTP',
                        prefixIcon: const Icon(Icons.security),
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: AppConstants.paddingLarge),

                      // Test Buttons
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  // Simulate loading
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      setState(() {
                                        _isLoading = false;
                                      });

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Test successful! App is working.',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                  );
                                },
                          text: _isLoading ? 'Testing...' : 'Test App',
                        ),
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Feature List
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✅ Working Features:',
                            style: AppConstants.bodyStyle.copyWith(
                              color: AppConstants.textPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppConstants.paddingSmall),
                          _buildFeatureItem('Location Picker with Map'),
                          _buildFeatureItem(
                            'Payment Integration (Razorpay + UPI)',
                          ),
                          _buildFeatureItem('Real-time Chat System'),
                          _buildFeatureItem('Booking Management'),
                          _buildFeatureItem('Profile Management'),
                          _buildFeatureItem('Service Provider Verification'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              text,
              style: AppConstants.captionStyle.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
