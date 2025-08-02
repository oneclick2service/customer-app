import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import 'profile_setup_screen.dart';

class AccountTypeSelectionScreen extends StatefulWidget {
  const AccountTypeSelectionScreen({super.key});

  @override
  State<AccountTypeSelectionScreen> createState() => _AccountTypeSelectionScreenState();
}

class _AccountTypeSelectionScreenState extends State<AccountTypeSelectionScreen> {
  bool _isIndividual = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Type'),
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
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.paddingXLarge),
                
                // Header
                Text(
                  'Choose Account Type',
                  style: AppConstants.headingStyle.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConstants.paddingMedium),
                
                Text(
                  'Select the type of account that best describes you',
                  style: AppConstants.bodyStyle.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConstants.paddingXLarge),
                
                // Individual Account Card
                _buildAccountTypeCard(
                  title: 'Individual Account',
                  subtitle: 'Personal use for home services',
                  icon: Icons.person,
                  features: [
                    'Personal service bookings',
                    'Individual payment methods',
                    'Personal booking history',
                    'Standard pricing',
                  ],
                  isSelected: _isIndividual,
                  onTap: () => setState(() => _isIndividual = true),
                ),
                
                const SizedBox(height: AppConstants.paddingMedium),
                
                // Corporate Account Card
                _buildAccountTypeCard(
                  title: 'Corporate Account',
                  subtitle: 'Business use with special features',
                  icon: Icons.business,
                  features: [
                    'Multiple user management',
                    'Corporate billing options',
                    'Bulk service bookings',
                    'Priority support',
                    'Custom pricing plans',
                  ],
                  isSelected: !_isIndividual,
                  onTap: () => setState(() => _isIndividual = false),
                ),
                
                const Spacer(),
                
                // Continue Button
                CustomButton(
                  onPressed: _isLoading ? null : _continueToProfileSetup,
                  text: _isLoading ? 'Loading...' : 'Continue',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> features,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: AppConstants.elevatedShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: isSelected ? AppConstants.primaryColor : Colors.grey[300],
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppConstants.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppConstants.subheadingStyle.copyWith(
                          color: AppConstants.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppConstants.captionStyle.copyWith(
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppConstants.primaryColor,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    color: isSelected ? AppConstants.primaryColor : Colors.grey[600],
                    size: 16,
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppConstants.captionStyle.copyWith(
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _continueToProfileSetup() async {
    setState(() => _isLoading = true);
    
    try {
      // Update the current user's account type
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        final updatedUser = authProvider.currentUser!.copyWith(
          isCorporate: !_isIndividual,
          updatedAt: DateTime.now(),
        );
        await authProvider.updateUserLocation(updatedUser);
      }
      
      // Navigate to profile setup
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileSetupScreen(
              isCorporate: !_isIndividual,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
} 