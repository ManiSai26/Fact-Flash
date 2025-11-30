import 'package:flutter/material.dart';
import 'package:fact_flash/services/auth_service.dart';
import 'package:fact_flash/models/user_model.dart';
import 'package:fact_flash/services/user_service.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final UserService userService = UserService();
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user logged in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<UserProfile?>(
        future: userService.getUserProfile(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final userProfile = snapshot.data;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userProfile?.photoUrl != null
                      ? NetworkImage(userProfile!.photoUrl!)
                      : null,
                  child: userProfile?.photoUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  userProfile?.displayName ?? 'No Name',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  userProfile?.email ?? '',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                if (userProfile != null)
                  Text(
                    'Joined: ${DateFormat.yMMMd().format(userProfile.joinedDate)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
