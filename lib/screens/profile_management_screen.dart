import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../constants/app_constants.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = false;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Management'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Personal'),
            Tab(text: 'Addresses'),
            Tab(text: 'Preferences'),
            Tab(text: 'Security'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalInfoTab(),
          _buildAddressesTab(),
          _buildPreferencesTab(),
          _buildSecurityTab(),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildPersonalInfoForm(),
          const SizedBox(height: 24),
          _buildAccountActions(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: _currentUser?.profileImage != null
                  ? NetworkImage(_currentUser!.profileImage!)
                  : null,
              child: _currentUser?.profileImage == null
                  ? Text(
                      _currentUser?.name?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentUser?.name ?? 'User Name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentUser?.email ?? 'user@example.com',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified Account',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _editProfileImage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nameController,
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              labelText: 'Email Address',
              prefixIcon: const Icon(Icons.email),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              labelText: 'Phone Number',
              prefixIcon: const Icon(Icons.phone),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _addressController,
              labelText: 'Primary Address',
              prefixIcon: const Icon(Icons.location_on),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: _isLoading ? 'Saving...' : 'Save Changes',
                onPressed: _isLoading ? null : _savePersonalInfo,
                backgroundColor: AppConstants.primaryColor,
                textColor: Colors.white,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionItem(
              'Export My Data',
              'Download all your data',
              Icons.download,
              _exportData,
            ),
            _buildActionItem(
              'Delete Account',
              'Permanently delete your account',
              Icons.delete_forever,
              _deleteAccount,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saved Addresses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CustomButton(
                text: 'Add New',
                onPressed: _addNewAddress,
                backgroundColor: AppConstants.primaryColor,
                textColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAddressList(),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    final addresses = _currentUser?.address != null ? [_currentUser!.address!] : [];

    if (addresses.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No addresses saved',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first address to get started',
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Add Address',
                onPressed: _addNewAddress,
                backgroundColor: AppConstants.primaryColor,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: addresses.map((address) => _buildAddressCard(address)).toList(),
    );
  }

  Widget _buildAddressCard(String address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Primary Address',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editAddress(address);
                } else if (value == 'delete') {
                  _deleteAddress(address);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'App Preferences',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPreferenceSection(
            'Notifications',
            [
              _buildSwitchPreference(
                'Push Notifications',
                'Receive push notifications for bookings and updates',
                true,
                (value) => _updateNotificationPreference(value),
              ),
              _buildSwitchPreference(
                'Email Notifications',
                'Receive email notifications for important updates',
                false,
                (value) => _updateEmailPreference(value),
              ),
              _buildSwitchPreference(
                'SMS Notifications',
                'Receive SMS notifications for urgent updates',
                true,
                (value) => _updateSMSPreference(value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPreferenceSection(
            'Privacy',
            [
              _buildSwitchPreference(
                'Share Location',
                'Allow app to access your location for better service',
                true,
                (value) => _updateLocationPreference(value),
              ),
              _buildSwitchPreference(
                'Profile Visibility',
                'Make your profile visible to service providers',
                true,
                (value) => _updateProfileVisibility(value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPreferenceSection(
            'Language & Region',
            [
              _buildDropdownPreference(
                'Language',
                'English',
                ['English', 'Telugu', 'Hindi'],
                (value) => _updateLanguage(value),
              ),
              _buildDropdownPreference(
                'Currency',
                'INR (₹)',
                ['INR (₹)', 'USD ($)', 'EUR (€)'],
                (value) => _updateCurrency(value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchPreference(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownPreference(
    String title,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DropdownButton<String>(
            value: currentValue,
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSecuritySection(
            'Account Security',
            [
              _buildSecurityItem(
                'Change Password',
                'Update your account password',
                Icons.lock,
                _changePassword,
              ),
              _buildSecurityItem(
                'Two-Factor Authentication',
                'Add an extra layer of security',
                Icons.security,
                _setupTwoFactor,
              ),
              _buildSecurityItem(
                'Login History',
                'View your recent login activity',
                Icons.history,
                _viewLoginHistory,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSecuritySection(
            'Data & Privacy',
            [
              _buildSecurityItem(
                'Privacy Policy',
                'Read our privacy policy',
                Icons.privacy_tip,
                _viewPrivacyPolicy,
              ),
              _buildSecurityItem(
                'Terms of Service',
                'Read our terms of service',
                Icons.description,
                _viewTermsOfService,
              ),
              _buildSecurityItem(
                'Data Usage',
                'Manage how your data is used',
                Icons.data_usage,
                _manageDataUsage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildActionItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppConstants.primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Action methods
  void _editProfileImage() {
    // TODO: Implement profile image editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile image editing coming soon')),
    );
  }

  void _savePersonalInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement save personal info
      await Future.delayed(const Duration(seconds: 1));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal information saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving information: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _exportData() {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export feature coming soon')),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion feature coming soon'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addNewAddress() {
    // TODO: Implement add new address
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add address feature coming soon')),
    );
  }

  void _editAddress(String address) {
    // TODO: Implement edit address
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit address feature coming soon')),
    );
  }

  void _deleteAddress(String address) {
    // TODO: Implement delete address
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete address feature coming soon')),
    );
  }

  void _updateNotificationPreference(bool value) {
    // TODO: Implement notification preference update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification preference updated: $value')),
    );
  }

  void _updateEmailPreference(bool value) {
    // TODO: Implement email preference update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email preference updated: $value')),
    );
  }

  void _updateSMSPreference(bool value) {
    // TODO: Implement SMS preference update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('SMS preference updated: $value')),
    );
  }

  void _updateLocationPreference(bool value) {
    // TODO: Implement location preference update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location preference updated: $value')),
    );
  }

  void _updateProfileVisibility(bool value) {
    // TODO: Implement profile visibility update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile visibility updated: $value')),
    );
  }

  void _updateLanguage(String value) {
    // TODO: Implement language update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Language updated: $value')),
    );
  }

  void _updateCurrency(String value) {
    // TODO: Implement currency update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Currency updated: $value')),
    );
  }

  void _changePassword() {
    // TODO: Implement change password
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password feature coming soon')),
    );
  }

  void _setupTwoFactor() {
    // TODO: Implement two-factor authentication setup
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Two-factor authentication coming soon')),
    );
  }

  void _viewLoginHistory() {
    // TODO: Implement login history view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login history feature coming soon')),
    );
  }

  void _viewPrivacyPolicy() {
    // TODO: Implement privacy policy view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy feature coming soon')),
    );
  }

  void _viewTermsOfService() {
    // TODO: Implement terms of service view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of service feature coming soon')),
    );
  }

  void _manageDataUsage() {
    // TODO: Implement data usage management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data usage management coming soon')),
    );
  }

  void _loadUserData() {
    // TODO: Load user data from provider
    setState(() {
      _currentUser = UserModel(
        id: 'user1',
        phoneNumber: '+91 9876543210',
        name: 'John Doe',
        email: 'john.doe@example.com',
        address: '123 Main Street, Vijayawada, Andhra Pradesh',
        profileImage: null,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      );
    });

    _nameController.text = _currentUser?.name ?? '';
    _emailController.text = _currentUser?.email ?? '';
    _phoneController.text = _currentUser?.phoneNumber ?? '';
    _addressController.text = _currentUser?.address ?? '';
  }
} 