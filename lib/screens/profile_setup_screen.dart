import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'home_screen.dart';
import 'location_picker_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isCorporate;
  
  const ProfileSetupScreen({
    super.key,
    this.isCorporate = false,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();

  bool _isCorporate = false;
  bool _isLoading = false;
  String? _error;
  final AuthProvider _authProvider = AuthProvider();

  @override
  void initState() {
    super.initState();
    _isCorporate = widget.isCorporate;
    _loadUserData();
  }

  void _loadUserData() {
    if (_authProvider.currentUser != null) {
      final user = _authProvider.currentUser!;
      _nameController.text = user.name ?? '';
      _emailController.text = user.email ?? '';
      _addressController.text = user.address ?? '';
      _cityController.text = user.city ?? '';
      _stateController.text = user.state ?? '';
      _pincodeController.text = user.pincode ?? '';
      _companyNameController.text = user.companyName ?? '';
      _isCorporate = user.isCorporate;
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _error = 'Name is required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final success = await _authProvider.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (success) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        setState(() {
          _error = _authProvider.error ?? 'Failed to save profile';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
    );

    if (result != null) {
      final location = result['location'] as LatLng;
      final address = result['address'] as String;

      setState(() {
        _addressController.text = address;
        _cityController.text = 'Vijayawada';
        _stateController.text = 'Andhra Pradesh';
      });
    }
  }

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
            colors: [AppConstants.primaryColor, Color(0xFF1976D2)],
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
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusLarge,
                          ),
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

                // Profile Form
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
                        'Complete Your Profile',
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

                      // Name Field
                      CustomTextField(
                        controller: _nameController,
                        hintText: 'Full Name',
                        prefixIcon: const Icon(Icons.person),
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Email Address',
                        prefixIcon: const Icon(Icons.email),
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Location Picker Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickLocation,
                          icon: const Icon(Icons.location_on),
                          label: const Text('Set Primary Location'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppConstants.primaryColor,
                            side: BorderSide(color: AppConstants.primaryColor),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppConstants.paddingMedium,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Address Field
                      CustomTextField(
                        controller: _addressController,
                        hintText: 'Address',
                        prefixIcon: const Icon(Icons.home),
                        readOnly: true,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // City and State Row
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _cityController,
                              hintText: 'City',
                              prefixIcon: const Icon(Icons.location_city),
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: AppConstants.paddingSmall),
                          Expanded(
                            child: CustomTextField(
                              controller: _stateController,
                              hintText: 'State',
                              prefixIcon: const Icon(Icons.map),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Pincode Field
                      CustomTextField(
                        controller: _pincodeController,
                        hintText: 'Pincode',
                        prefixIcon: const Icon(Icons.pin_drop),
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Corporate Account Toggle
                      SwitchListTile(
                        title: const Text('Corporate Account'),
                        subtitle: const Text('Enable for business services'),
                        value: _isCorporate,
                        onChanged: (value) {
                          setState(() {
                            _isCorporate = value;
                          });
                        },
                        activeColor: AppConstants.primaryColor,
                      ),

                      // Company Name Field (only if corporate)
                      if (_isCorporate) ...[
                        const SizedBox(height: AppConstants.paddingMedium),
                        CustomTextField(
                          controller: _companyNameController,
                          hintText: 'Company Name',
                          prefixIcon: const Icon(Icons.business),
                        ),
                      ],

                      const SizedBox(height: AppConstants.paddingLarge),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          text: _isLoading ? 'Saving...' : 'Save Profile',
                        ),
                      ),

                      const SizedBox(height: AppConstants.paddingMedium),

                      // Skip Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Skip for Now',
                            style: TextStyle(
                              color: AppConstants.textSecondaryColor,
                            ),
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }
}
