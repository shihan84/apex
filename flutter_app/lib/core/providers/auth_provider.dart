import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../constants/app_constants.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  String? _refreshToken;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize auth state
  Future<void> initialize() async {
    _setLoading(true);
    try {
      final token = await StorageService.getString(AppConstants.userTokenKey);
      if (token != null) {
        _token = token;
        _isAuthenticated = true;
        
        // Load user data
        final userData = await StorageService.getString(AppConstants.userDataKey);
        if (userData != null) {
          _user = UserModel.fromJson(jsonDecode(userData));
        }
        
        // Verify token with server
        await _verifyToken();
      }
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
      await logout();
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final request = LoginRequest(
        email: email,
        password: password,
        deviceId: await _getDeviceId(),
        deviceType: 'mobile',
      );
      
      final response = await ApiService(Dio()).login(request);
      
      _token = response.token;
      _refreshToken = response.refreshToken;
      _user = response.user;
      _isAuthenticated = true;
      
      // Save to storage
      await _saveAuthData();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? dateOfBirth,
    String? gender,
    List<String> preferredLanguages = const ['en'],
    List<String> favoriteGenres = const [],
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        password: password,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        preferredLanguages: preferredLanguages,
        favoriteGenres: favoriteGenres,
        deviceId: await _getDeviceId(),
        deviceType: 'mobile',
      );
      
      final response = await ApiService(Dio()).register(request);
      
      _token = response.token;
      _refreshToken = response.refreshToken;
      _user = response.user;
      _isAuthenticated = true;
      
      // Save to storage
      await _saveAuthData();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Registration failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      if (_token != null) {
        await ApiService(Dio()).logout();
      }
    } catch (e) {
      // Ignore logout errors
    }
    
    // Clear local data
    _user = null;
    _token = null;
    _refreshToken = null;
    _isAuthenticated = false;
    _clearError();
    
    // Clear storage
    await StorageService.remove(AppConstants.userTokenKey);
    await StorageService.remove(AppConstants.userDataKey);
    await StorageService.remove(AppConstants.subscriptionKey);
    
    notifyListeners();
    _setLoading(false);
  }

  // Refresh token
  Future<bool> refreshAuthToken() async {
    if (_refreshToken == null) return false;
    
    try {
      final request = RefreshTokenRequest(refreshToken: _refreshToken!);
      final response = await ApiService(Dio()).refreshToken(request);
      
      _token = response.token;
      _refreshToken = response.refreshToken;
      _user = response.user;
      
      await _saveAuthData();
      notifyListeners();
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? dateOfBirth,
    String? gender,
    List<String>? preferredLanguages,
    List<String>? favoriteGenres,
  }) async {
    if (_user == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      final request = UpdateProfileRequest(
        name: name,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        preferredLanguages: preferredLanguages,
        favoriteGenres: favoriteGenres,
      );
      
      _user = await ApiService(Dio()).updateProfile(request);
      await _saveAuthData();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Upload avatar
  Future<bool> uploadAvatar(String imagePath) async {
    if (_user == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      final file = File(imagePath);
      final avatarUrl = await ApiService(Dio()).uploadAvatar(file);
      
      _user = _user!.copyWith(avatar: avatarUrl);
      await _saveAuthData();
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to upload avatar: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Forgot password
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      final request = ForgotPasswordRequest(email: email);
      await ApiService(Dio()).forgotPassword(request);
      return true;
    } catch (e) {
      _setError('Failed to send reset email: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String token, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final request = ResetPasswordRequest(token: token, password: password);
      await ApiService(Dio()).resetPassword(request);
      return true;
    } catch (e) {
      _setError('Failed to reset password: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify email
  Future<bool> verifyEmail(String token) async {
    _setLoading(true);
    _clearError();
    
    try {
      final request = VerifyEmailRequest(token: token);
      await ApiService(Dio()).verifyEmail(request);
      
      if (_user != null) {
        _user = _user!.copyWith(isEmailVerified: true);
        await _saveAuthData();
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Failed to verify email: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify phone
  Future<bool> verifyPhone(String phone, String code) async {
    _setLoading(true);
    _clearError();
    
    try {
      final request = VerifyPhoneRequest(phone: phone, code: code);
      await ApiService(Dio()).verifyPhone(request);
      
      if (_user != null) {
        _user = _user!.copyWith(isPhoneVerified: true);
        await _saveAuthData();
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError('Failed to verify phone: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _saveAuthData() async {
    if (_token != null) {
      await StorageService.setString(AppConstants.userTokenKey, _token!);
    }
    if (_user != null) {
      await StorageService.setString(AppConstants.userDataKey, jsonEncode(_user!.toJson()));
    }
  }

  Future<void> _verifyToken() async {
    try {
      _user = await ApiService(Dio()).getProfile();
      await _saveAuthData();
    } catch (e) {
      await logout();
    }
  }

  Future<String> _getDeviceId() async {
    // Implementation to get device ID
    // This would typically use device_info_plus package
    return 'device_id_placeholder';
  }
}
