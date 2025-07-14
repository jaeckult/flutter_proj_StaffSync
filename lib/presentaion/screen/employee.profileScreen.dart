import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:staffsync/application/bloc/user/user_cubit.dart';
import 'package:staffsync/presentaion/widgets/profile_picture_widget.dart';

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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserCubit>().loadUserFromStorage();
    });
  }

  void _handleLogout() async {
    try {
      // If you have an AuthBloc, you can dispatch a logout event here.
      // For now, just navigate to login.
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
      // Implement deletion via a dedicated cubit or repository if needed.
      // For now, show not implemented to avoid accidental destructive action.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deletion via BLoC not implemented yet.')),
        );
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
    final user = context.watch<UserCubit>().state;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: ProfilePictureWidget(
                profilePicture: user.profile.profilePicture,
                radius: 50,
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
