import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/providers/providers.dart';

final fullNameProvider = StateProvider<String>((ref) => "");
final designationProvider = StateProvider<String>((ref) => "");
final emailProvider = StateProvider<String>((ref) => "");
final experienceProvider = StateProvider<String>((ref) => "");

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  late TextEditingController nameController;
  late TextEditingController designationController;
  late TextEditingController emailController;
  late TextEditingController experienceController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: ref.read(fullNameProvider));
    designationController = TextEditingController(text: ref.read(designationProvider));
    emailController = TextEditingController(text: ref.read(emailProvider));
    experienceController = TextEditingController(text: ref.read(experienceProvider));
    ref.read(userNotifierProvider.notifier).loadUserFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);
    const avatarRadius = 40.0;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator())

      );
    }
    final Uint8List profile = base64Decode(user.profile.profilePicture);
    

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: 

      Padding(
        
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundImage: MemoryImage(profile),
            ),
            const SizedBox(height: 10),
            Text(
              user.profile.fullName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
             Text(
              user.profile.designation,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildTextField("Full Name", nameController),
            _buildTextField("Designation", designationController),
            _buildTextField("Email", emailController),
            _buildTextField("Years of Experience", experienceController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref.read(fullNameProvider.notifier).state = nameController.text;
                ref.read(designationProvider.notifier).state = designationController.text;
                ref.read(emailProvider.notifier).state = emailController.text;
                ref.read(experienceProvider.notifier).state = experienceController.text;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Submitted Successfully")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
             child: const Text(
                 "Submit",
                  style: TextStyle(fontSize: 16, color: Color.fromRGBO(255, 255, 255, 1)),
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.orange),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orange),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.deepOrange),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
