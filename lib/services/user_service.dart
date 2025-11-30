import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fact_flash/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  Future<void> createUserProfile(UserProfile user) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(uid).update(data);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({'role': role});
    } catch (e) {
      debugPrint('Error updating user role: $e');
      rethrow;
    }
  }

  Future<List<UserProfile>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map(
            (doc) =>
                UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting all users: $e');
      return [];
    }
  }
}
