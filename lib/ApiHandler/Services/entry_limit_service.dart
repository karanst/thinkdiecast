import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class EntryLimitService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize user with default settings
  static Future<void> initializeUser(String userId, String email, String name) async {
    try {
      await _firestore.collection('Users').doc(userId).set({
        'uid': userId,
        'email': email,
        'name': name,
        'entries': 0,
        'limit': 5,
        'plan': 'free',
        'profilePicture': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('User initialized successfully with default limits');
    } catch (e) {
      print('Error initializing user: $e');
      rethrow;
    }
  }

  // Sync entries count with actual products
  static Future<void> syncUserEntries(String userId) async {
    try {
      // Count actual products
      final productsSnapshot = await _firestore
          .collection('Products')
          .where('createdBy', isEqualTo: userId)
          .get();

      final actualCount = productsSnapshot.docs.length;

      // Update user document
      await _firestore.collection('Users').doc(userId).update({
        'entries': actualCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Synced user entries: $actualCount');
    } catch (e) {
      print('Error syncing user entries: $e');
      rethrow;
    }
  }

  // Check if user can add more entries
  static Future<bool> canAddEntry(String userId) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(userId).get();

      if (!userDoc.exists) return false;

      final data = userDoc.data() as Map<String, dynamic>;
      final entries = int.tryParse(data['entries'].toString()) ?? 0;
      final limit = int.tryParse(data['limit'].toString()) ?? 5;

      return entries < limit;
    } catch (e) {
      print('Error checking entry limit: $e');
      return false;
    }
  }

  // Update user plan and limit
  static Future<void> updateUserPlan(String userId, String planName, int newLimit) async {
    try {
      await _firestore.collection('Users').doc(userId).update({
        'plan': planName,
        'limit': newLimit,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Updated user plan: $planName with limit: $newLimit');
    } catch (e) {
      print('Error updating user plan: $e');
      rethrow;
    }
  }

  // Get user entry status
  static Future<Map<String, dynamic>> getUserEntryStatus(String userId) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(userId).get();

      if (!userDoc.exists) {
        return {'entries': 0, 'limit': 5, 'percentage': 0.0, 'canAdd': true};
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final entries = int.tryParse(data['entries'].toString()) ?? 0;
      final limit = int.tryParse(data['limit'].toString()) ?? 5;
      final percentage = limit > 0 ? entries / limit : 0.0;
      final canAdd = entries < limit;

      return {
        'entries': entries,
        'limit': limit,
        'percentage': percentage,
        'canAdd': canAdd,
        'remaining': limit - entries,
      };
    } catch (e) {
      print('Error getting user entry status: $e');
      return {'entries': 0, 'limit': 5, 'percentage': 0.0, 'canAdd': true};
    }
  }
}
