import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'otp_verification_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _error;

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
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              children: [
                const Spacer(),

                // Welcome Header
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusLarge,
                          ),
                          boxShadow: AppConstants.elevatedShadow,
                        ),
                        child: const Icon(
                          Icons.home_repair_service,
                          size: 50,
                          color: AppConstants.primaryColor,
                        ),
                      ),

                      const SizedBox(height: AppConstants.paddingLarge),

                      Text(
                        'Welcome to One Click 2 Service',
                        style: AppConstants.headingStyle.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      Text(
                        'Get reliable service providers at your doorstep in Vijayawada',
                        style: AppConstants.bodyStyle.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.paddingXLarge),

                // Features List
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why Choose Us?',
                        style: AppConstants.subheadingStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      _buildFeatureItem(
                        icon: Icons.verified,
                        title: 'Verified Providers',
                        subtitle: 'Background-checked service professionals',
                      ),

                      _buildFeatureItem(
                        icon: Icons.schedule,
                        title: 'Instant Booking',
                        subtitle: 'Book services in just one click',
                      ),

                      _buildFeatureItem(
                        icon: Icons.location_on,
                        title: 'Real-time Tracking',
                        subtitle: 'Track your service provider live',
                      ),

                      _buildFeatureItem(
                        icon: Icons.payment,
                        title: 'Transparent Pricing',
                        subtitle: 'No hidden charges, clear pricing',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.paddingXLarge),

                // Phone Number Input
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Get Started',
                        style: AppConstants.subheadingStyle.copyWith(
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Error Message
                      if (_error != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(
                            AppConstants.paddingSmall,
                          ),
                          margin: const EdgeInsets.only(
                            bottom: AppConstants.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusSmall,
                            ),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      CustomTextField(
                        controller: _phoneController,
                        hintText: 'Enter your phone number',
                        prefixIcon: const Icon(Icons.phone),
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      Text(
                        'We\'ll send you a verification code',
                        style: AppConstants.captionStyle.copyWith(
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),

                      const SizedBox(height: AppConstants.paddingLarge),

                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          onPressed: _isLoading ? null : _sendOtp,
                          text: _isLoading ? 'Sending...' : 'Continue',
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

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingSmall),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusSmall,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppConstants.bodyStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppConstants.captionStyle.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendOtp() async {
    final phoneNumber = _phoneController.text.trim();
    
    if (phoneNumber.isEmpty) {
      setState(() {
        _error = 'Please enter your phone number';
      });
      return;
    }

    if (phoneNumber.length < 10) {
      setState(() {
        _error = 'Please enter a valid phone number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.sendOtp(phoneNumber);

      if (success && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(phoneNumber: phoneNumber),
          ),
        );
      } else if (mounted) {
        setState(() {
          _error = authProvider.error ?? 'Failed to send OTP';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
} 