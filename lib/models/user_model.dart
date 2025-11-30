import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime joinedDate;
  final String role; // 'admin' or 'user'

  UserProfile({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.joinedDate,
    this.role = 'user', // Default role
  });

  factory UserProfile.fromMap(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      joinedDate: (data['joinedDate'] as Timestamp).toDate(),
      role: data['role'] ?? 'user', // Treat null as 'user'
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'joinedDate': Timestamp.fromDate(joinedDate),
      'role': role,
    };
  }
}
