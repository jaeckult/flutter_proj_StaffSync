import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/providers/providers.dart';


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
  
    final imageUrl = user.profile.profilePicture;
    Uint8List imageBytes = base64Decode(imageUrl); 

    

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
            GestureDetector(child:
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
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                  )
                ],
              ),
            ), onTap: () => {
              _showUploadModal()
              
             
            }
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
            _buildTextField("Employeement Type", experienceController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {

                final userNotifier = ref.read(userNotifierProvider.notifier);
                await userNotifier.editProfile(user.id, nameController.text, designationController.text, emailController.text, experienceController.text, profilePictureController.text);
           

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
