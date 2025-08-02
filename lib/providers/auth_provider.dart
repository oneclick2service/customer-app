import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/session_service.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SessionService _sessionService = SessionService();
  final SupabaseService _supabaseService = SupabaseService();

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

  // Session Management
  Future<bool> checkAutoLogin() async {
    try {
      _isLoading = true;
      notifyListeners();

      final isLoggedIn = await _sessionService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _sessionService.getCurrentUser();
        if (user != null) {
          _currentUser = user;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> saveSession() async {
    if (_currentUser != null) {
      await _sessionService.saveSession(_currentUser!, 'session_token_${DateTime.now().millisecondsSinceEpoch}');
    }
  }

  Future<void> clearSession() async {
    await _sessionService.clearSession();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  Future<void> setAutoLogin(bool enabled) async {
    await _sessionService.setAutoLogin(enabled);
  }

  Future<bool> isAutoLoginEnabled() async {
    return await _sessionService.isAutoLoginEnabled();
  }

  // Supabase Integration
  Future<bool> saveUserToSupabase() async {
    if (_currentUser != null) {
      try {
        final savedUser = await _supabaseService.createUser(_currentUser!);
        if (savedUser != null) {
          _currentUser = savedUser;
          notifyListeners();
          return true;
        }
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
    return false;
  }

  Future<bool> updateUserInSupabase() async {
    if (_currentUser != null) {
      try {
        final success = await _supabaseService.updateUser(_currentUser!);
        if (success) {
          await _sessionService.updateUserInSession(_currentUser!);
          notifyListeners();
          return true;
        }
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
    return false;
  }
}
