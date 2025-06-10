import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/providers/providers.dart';
import 'package:staffsync/presentaion/widgets/profile_picture_widget.dart';


final fullNameProvider = StateProvider<String>((ref) => "");
final designationProvider = StateProvider<String>((ref) => "");
final emailProvider = StateProvider<String>((ref) => "");
final experienceProvider = StateProvider<String>((ref) => "");
final profilePictureProvider = StateProvider<String>((ref) => "");

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  File? _image;
  String? _base64Image;
  late TextEditingController nameController;
  late TextEditingController designationController;
  late TextEditingController emailController;
  late TextEditingController experienceController;
  late TextEditingController profilePictureController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    designationController = TextEditingController();
    emailController = TextEditingController();
    experienceController = TextEditingController();
    profilePictureController = TextEditingController();
    
    // Load user data and initialize controllers
    Future.microtask(() async {
      await ref.read(userNotifierProvider.notifier).loadUserFromStorage();
      final user = ref.read(userNotifierProvider);
      if (user != null) {
        nameController.text = user.profile.fullName;
        designationController.text = user.profile.designation;
        emailController.text = user.email;
        experienceController.text = user.profile.employmentType;
        profilePictureController.text = user.profile.profilePicture;
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    designationController.dispose();
    emailController.dispose();
    experienceController.dispose();
    profilePictureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator())
      );
    }

    final imageUrl = user.profile.profilePicture;
    Uint8List? imageBytes;
    try {
      if (imageUrl.isNotEmpty) {
        imageBytes = base64Decode(imageUrl);
      }
    } catch (e) {
      print('Error decoding image: $e');
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _showUploadModal,
                child: ProfilePictureWidget(
                  profilePicture: user.profile.profilePicture,
                  onTap: _showUploadModal,
                ),
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
              _buildTextField("Employment Type", experienceController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final userNotifier = ref.read(userNotifierProvider.notifier);
                    await userNotifier.editProfile(
                      user.id,
                      nameController.text,
                      designationController.text,
                      emailController.text,
                      experienceController.text,
                      _base64Image ?? user.profile.profilePicture,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Profile updated successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error updating profile: ${e.toString()}"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20), // Add extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final base64String = await _imageToBase64(imageFile);
     
       if (base64String != null){
        setState(() {
        _image = imageFile;
        _base64Image = base64String;
        });

       }
   



    }
  }


Future<String?> _imageToBase64(File imageFile) async {
  try {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  } catch (e) {
    print('Error converting image to base64: $e');
    return null;
  }
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
  
  Future<void> _showUploadModal() async {
  showModalBottomSheet(
    context: context,
    builder: (context) => Wrap(
      children: [
       
        ListTile(
          leading: Icon(Icons.photo_library),
          title: Text('Choose from Gallery'),
          onTap: () {
            Navigator.pop(context);
            _pickImage(ImageSource.gallery);
          },
        ),
      ],
    ),
  );
}

}
