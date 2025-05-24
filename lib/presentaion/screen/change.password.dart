import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ChangePassword(),
    debugShowCheckedModeBanner: false,
  ));
}

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool oldPasswordVisible = false;
  bool newPasswordVisible = false;

  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Change', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set a new password",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Text("Old Password"),
            const SizedBox(height: 8),
            TextField(
              controller: oldPasswordController,
              obscureText: !oldPasswordVisible,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(oldPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      oldPasswordVisible = !oldPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("New Password"),
            const SizedBox(height: 8),
            TextField(
              controller: newPasswordController,
              obscureText: !newPasswordVisible,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(newPasswordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      newPasswordVisible = !newPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Add password change logic here
                  print("Changing password...");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Change Password",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
