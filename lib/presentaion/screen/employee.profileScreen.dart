import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staffsync/application/providers/providers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Staff sync',
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreen();
}

class _ProfileScreen extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userNotifierProvider.notifier).loadUserFromStorage();
    });
  }

  void _handleLogout() async {
    try {
      await ref.read(authNotifierProvider.notifier).logout();
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: ${e.toString()}')),
        );
      }
    }
  }

  void _handleAccountDeletion() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        final user = ref.read(userNotifierProvider);
        final token = await ref.read(authNotifierProvider.notifier).getToken();

        if (user != null && token != null) {
          await ref
              .read(bulkUserNotifierProvider.notifier)
              .deleteEmployee(user.id, token);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account deleted successfully.')),
            );
            context.go('/');
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Unable to delete account: User or token not found.',
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete account: ${e.toString()}'),
            ),
          );
        }
      }
    }
  }

  void _gotoNotification() {
    context.push('/setting');
  }

  void _handlePasswordChange() {
    context.push('/changePassword');
  }

  void _handleEditProfile() {
    context.push('/editProfile');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final imageUrl = user.profile.profilePicture;
    Uint8List imageBytes = base64Decode(imageUrl);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: MemoryImage(
                      imageBytes,
                    ), // Replace with your image URL
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              user.profile.fullName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              user.profile.designation,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: _handleEditProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ProfileOption(
              icon: Icons.notifications,
              text: "Notification Settings",
              function: _gotoNotification,
            ),
            ProfileOption(
              icon: Icons.vpn_key,
              text: "Change Password",
              function: _handlePasswordChange,
            ),
            ProfileOption(
              icon: Icons.logout,
              text: "Logout",
              function: _handleLogout,
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_forever,
                color: Colors.pinkAccent,
              ),
              title: const Text(
                "Delete Account",
                style: TextStyle(color: Colors.pinkAccent),
              ),
              onTap: _handleAccountDeletion,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback function;

  const ProfileOption({
    required this.icon,
    required this.text,
    required this.function,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(text),
      onTap: function,
    );
  }
}
