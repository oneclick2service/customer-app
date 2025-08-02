import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Remove Firebase initialization for now
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final phoneNumber = _phoneController.text.trim();
    
    final success = await authProvider.sendOtp(phoneNumber);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully! Check your phone.'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to send OTP'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Header
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                child: Column(
                  children: [
                    // App Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                        boxShadow: AppConstants.elevatedShadow,
                      ),
                      child: const Icon(
                        Icons.touch_app,
                        size: 40,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppConstants.marginMedium),
                    
                    // App Title
                    Text(
                      AppConstants.appName,
                      style: AppConstants.headingStyle.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: AppConstants.marginSmall),
                    
                    // App Description
                    Text(
                      AppConstants.appDescription,
                      style: AppConstants.captionStyle.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Features Section
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Column(
                    children: [
                      // Feature Cards
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppConstants.marginMedium,
                          mainAxisSpacing: AppConstants.marginMedium,
                          children: [
                            _buildFeatureCard(
                              icon: Icons.flash_on,
                              title: 'Instant Booking',
                              description: 'Book services instantly',
                              color: AppConstants.secondaryColor,
                            ),
                            _buildFeatureCard(
                              icon: Icons.location_on,
                              title: 'Real-time Tracking',
                              description: 'Track service providers',
                              color: AppConstants.accentColor,
                            ),
                            _buildFeatureCard(
                              icon: Icons.payment,
                              title: 'Transparent Pricing',
                              description: 'No hidden charges',
                              color: AppConstants.successColor,
                            ),
                            _buildFeatureCard(
                              icon: Icons.verified,
                              title: 'Verified Providers',
                              description: 'Trusted professionals',
                              color: AppConstants.warningColor,
                            ),
                          ],
                        ),
                      ),

                      // Phone Number Form
                      Container(
                        padding: const EdgeInsets.all(AppConstants.paddingLarge),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                          boxShadow: AppConstants.elevatedShadow,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Enter your phone number',
                                style: AppConstants.subheadingStyle,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppConstants.marginMedium),
                              
                              CustomTextField(
                                controller: _phoneController,
                                hintText: 'Phone Number',
                                prefixIcon: const Icon(Icons.phone),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  if (value.length < 10) {
                                    return 'Please enter a valid phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppConstants.marginMedium),
                              
                              CustomButton(
                                text: 'Continue',
                                onPressed: _isLoading ? null : _sendOtp,
                                isLoading: _isLoading,
                              ),
                            ],
                          ),
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: AppConstants.marginSmall),
          Text(
            title,
            style: AppConstants.subheadingStyle.copyWith(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.marginSmall),
          Text(
            description,
            style: AppConstants.captionStyle.copyWith(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
} 