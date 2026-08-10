

import 'package:thinkdiecast/ApiHandler/ApiServices/api_services.dart';
import 'package:thinkdiecast/models/user_model.dart';

class UserService {
  final ApiService _apiService = ApiService();

  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  /// Get user profile by ID
  ///
  /// Parameters:
  /// - userId: The ID of the user to fetch
  Future<User> getUserProfile(String userId) async {
    try {
      final response = await _apiService.get('/Users/$userId');

      if (response is Map<String, dynamic>) {
        final user = User.fromJson(response);
        await _apiService.saveUserData(user.toJson());
        return user;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Update user profile
  ///
  /// Parameters:
  /// - userId: The ID of the user to update
  /// - name: Updated user name
  /// - city: Updated city
  /// - phone: Updated phone number
  /// - email1: Updated email (optional)
  /// - plan: Updated plan (optional)
  /// - limit: Updated limit (optional)
  Future<User> updateUserProfile(
      String userId, {
        String? name,
        String? city,
        String? phone,
        String? email1,
        String? plan,
        int? limit,
      }) async {
    try {
      final body = <String, dynamic>{};

      if (name != null) body['name'] = name;
      if (city != null) body['City'] = city;
      if (phone != null) body['phone'] = phone;
      if (email1 != null) body['email1'] = email1;
      if (plan != null) body['plan'] = plan;
      if (limit != null) body['limit'] = limit;

      final response = await _apiService.put(
        '/Users/update',
        body: body,
      );

      if (response is Map<String, dynamic>) {
        final user = User.fromJson(response);
        await _apiService.saveUserData(user.toJson());
        return user;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Delete user account
  ///
  /// Parameters:
  /// - userId: The ID of the user to delete
  Future<void> deleteUserAccount(String userId) async {
    try {
      await _apiService.delete('/Users/$userId');
      await _apiService.clearAllData();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  /// Get cached user data from local storage
  Future<User?> getCachedUserData() async {
    final userData = await _apiService.getUserData();
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }

  /// Update local user data cache
  Future<void> updateCachedUserData(User user) async {
    await _apiService.saveUserData(user.toJson());
  }

  /// Clear cached user data
  Future<void> clearCachedUserData() async {
    await _apiService.clearUserData();
  }
}
