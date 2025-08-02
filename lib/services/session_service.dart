import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class SessionService {
  static const String _userKey = 'current_user';
  static const String _sessionKey = 'session_token';
  static const String _lastLoginKey = 'last_login';
  static const String _autoLoginKey = 'auto_login_enabled';

  final SupabaseClient _supabase = Supabase.instance.client;

  // Save user session
  Future<void> saveSession(UserModel user, String sessionToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setString(_sessionKey, sessionToken);
    await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
    await prefs.setBool(_autoLoginKey, true);
  }

  // Get current session
  Future<Map<String, dynamic>?> getCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    final sessionToken = prefs.getString(_sessionKey);
    final lastLogin = prefs.getString(_lastLoginKey);
    final autoLoginEnabled = prefs.getBool(_autoLoginKey) ?? false;

    if (userJson != null && sessionToken != null && autoLoginEnabled) {
      try {
        final user = UserModel.fromJson(jsonDecode(userJson));
        return {
          'user': user,
          'sessionToken': sessionToken,
          'lastLogin': lastLogin != null ? DateTime.parse(lastLogin) : null,
        };
      } catch (e) {
        // Invalid session data, clear it
        await clearSession();
        return null;
      }
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final session = await getCurrentSession();
    if (session == null) return false;

    // Check if session is still valid (not expired)
    final lastLogin = session['lastLogin'] as DateTime?;
    if (lastLogin != null) {
      final daysSinceLogin = DateTime.now().difference(lastLogin).inDays;
      // Session expires after 30 days
      if (daysSinceLogin > 30) {
        await clearSession();
        return false;
      }
    }

    return true;
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final session = await getCurrentSession();
    return session?['user'] as UserModel?;
  }

  // Update user data in session
  Future<void> updateUserInSession(UserModel updatedUser) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(updatedUser.toJson()));
  }

  // Clear session
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_sessionKey);
    await prefs.remove(_lastLoginKey);
    await prefs.setBool(_autoLoginKey, false);
  }

  // Enable/disable auto-login
  Future<void> setAutoLogin(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoLoginKey, enabled);
  }

  // Check if auto-login is enabled
  Future<bool> isAutoLoginEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoLoginKey) ?? false;
  }

  // Refresh session with Supabase
  Future<bool> refreshSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        // Session is still valid
        return true;
      } else {
        // Try to refresh the session
        final response = await _supabase.auth.refreshSession();
        return response.session != null;
      }
    } catch (e) {
      // Session refresh failed
      await clearSession();
      return false;
    }
  }

  // Validate session with server
  Future<bool> validateSessionWithServer() async {
    try {
      final session = await getCurrentSession();
      if (session == null) return false;

      // Here you would typically make an API call to validate the session
      // For now, we'll just check if the session exists and is not expired
      return await isLoggedIn();
    } catch (e) {
      await clearSession();
      return false;
    }
  }

  // Get session statistics
  Future<Map<String, dynamic>> getSessionStats() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLogin = prefs.getString(_lastLoginKey);
    final autoLoginEnabled = prefs.getBool(_autoLoginKey) ?? false;

    return {
      'lastLogin': lastLogin != null ? DateTime.parse(lastLogin) : null,
      'autoLoginEnabled': autoLoginEnabled,
      'isLoggedIn': await isLoggedIn(),
      'sessionValid': await validateSessionWithServer(),
    };
  }
} 