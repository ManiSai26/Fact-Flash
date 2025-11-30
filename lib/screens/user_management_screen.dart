import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fact_flash/services/auth_service.dart';
import 'package:fact_flash/services/user_service.dart';
import 'package:fact_flash/models/user_model.dart';
import 'package:intl/intl.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  List<UserProfile> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    final users = await _userService.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _updateUserRole(UserProfile user, String newRole) async {
    try {
      await _userService.updateUserRole(user.uid, newRole);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Updated ${user.displayName ?? user.email} to $newRole',
          ),
        ),
      );
      _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Management',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6200EA),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF3E5F5),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? const Center(child: Text('No users found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final isCurrentUser = user.uid == currentUserId;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.role == 'admin'
                          ? Colors.deepPurple
                          : Colors.grey,
                      child: Icon(
                        user.role == 'admin'
                            ? Icons.admin_panel_settings
                            : Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      user.displayName ?? 'No Name',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        Text(
                          'Joined: ${DateFormat.yMMMd().format(user.joinedDate)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: isCurrentUser
                        ? Chip(
                            label: Text(
                              user.role.toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: user.role == 'admin'
                                ? Colors.deepPurple.shade100
                                : Colors.grey.shade300,
                          )
                        : DropdownButton<String>(
                            value: user.role,
                            items: const [
                              DropdownMenuItem(
                                value: 'user',
                                child: Text('User'),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Admin'),
                              ),
                            ],
                            onChanged: (newRole) {
                              if (newRole != null && newRole != user.role) {
                                _updateUserRole(user, newRole);
                              }
                            },
                          ),
                  ),
                );
              },
            ),
    );
  }
}
