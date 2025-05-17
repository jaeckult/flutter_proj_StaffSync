import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 300,
              width: 300,
              color: Colors.grey[200], // Placeholder background
              child: Image.asset('signup_illustration.png'),
            ),
            const SizedBox(height: 20),

            const Text(
              'Sign up as',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // Handle Employee sign-up
                Navigator.pushReplacementNamed(context, '/employee_signup');
              },

              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: Size(250, 50),
                backgroundColor: Colors.orange[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Employee', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                // Handle Manager sign-up
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                minimumSize: Size(250, 50),
                backgroundColor: Colors.orange[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text('Manager', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Handle navigation to login screen
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Have an account? ',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: SignupScreen()));
}
