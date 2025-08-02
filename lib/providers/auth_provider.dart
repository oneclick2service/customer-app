import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Send OTP
  Future<bool> sendOtp(String phoneNumber) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate OTP sending (replace with actual Supabase auth)
      await Future.delayed(const Duration(seconds: 2));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate OTP verification (replace with actual Supabase auth)
      await Future.delayed(const Duration(seconds: 2));

      // Create mock user for demo
      _currentUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        phoneNumber: phoneNumber,
        name: 'Demo User',
        email: 'demo@example.com',
        profileImage: null,
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required String name,
    required String email,
    String? profileImage,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          name: name,
          email: email,
          profileImage: profileImage,
          updatedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update user location
  Future<bool> updateUserLocation(UserModel updatedUser) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentUser = updatedUser;

      // TODO: Save to Supabase database
      // await _supabase.from('users').update(updatedUser.toJson()).eq('id', updatedUser.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
