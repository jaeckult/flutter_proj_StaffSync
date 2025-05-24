import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/providers/providers.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staff sync',
      debugShowCheckedModeBanner: false,
    );
  }
}


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  
  
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileScreen();}
  class _ProfileScreen extends ConsumerState<ProfileScreen>  {
    
     @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userNotifierProvider.notifier).loadUserFromStorage();
      
    });

  }
  
    void _handleLogout()
    {
      ref.read(authNotifierProvider.notifier).logout();
      
      Navigator.pushReplacementNamed(context, '/');

}

void _handleAccountDeletion(){
  

}
void _gotoNotification(){
  Navigator.pushNamed(context, '/setting');


}
void _handlePasswordChange() {
  Navigator.pushNamed(context, '/changePassword');

}
void _handleEditProfile() {
  Navigator.pushNamed(context, '/editProfile');

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
                    backgroundImage: MemoryImage(imageBytes), // Replace with your image URL
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              user.profile.fullName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              user.profile.designation,
              style: TextStyle(color: Colors.grey),
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
                  child: const Text("Edit Profile", style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ProfileOption(icon: Icons.notifications, text: "Notification Settings", function: _gotoNotification,),
            ProfileOption(icon: Icons.vpn_key, text: "Change Password", function: _handlePasswordChange),
            ProfileOption(icon: Icons.logout, text: "Logout", function:_handleLogout),
            ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.pinkAccent),
                title: Text("Delete Account", style: TextStyle(color: Colors.pinkAccent)),
                onTap: () {},
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

  const ProfileOption({required this.icon, required this.text, required this.function, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(text),
      onTap: function
      ,
    );
  }
}
