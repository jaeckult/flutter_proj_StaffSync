import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:staffsync/application/providers/providers.dart';
import 'package:intl/intl.dart';

enum UserRole { MANAGER, EMPLOYEE }
enum EmploymentType { PERMANENT, CONTRACTUAL, INTERNSHIP }
enum Gender { MALE, FEMALE}

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool passwordVisible = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _designationController = TextEditingController();
  DateTime? _dateOfBirth;
  EmploymentType _selectedEmploymentType = EmploymentType.PERMANENT;
  UserRole _selectedRole = UserRole.EMPLOYEE;
  Gender _selectedGender = Gender.MALE;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _fullnameController.dispose();

    _designationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      if (_dateOfBirth == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date of birth')),
        );
        return;
      }

      try {
        await ref
            .read(authNotifierProvider.notifier)
            .signup(
              _usernameController.text,
              _passwordController.text,
              _emailController.text,
              _fullnameController.text,
              _selectedGender.name,
              _selectedEmploymentType.name,
              _designationController.text,
              _dateOfBirth!.toIso8601String(),
              _selectedRole.name,
            );
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(child:Column(
        children: [
          const SizedBox(
            child: Image(
              height: 200,
              image: AssetImage('assets/signup_illustration.png'),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.2),
            child: Form(
              key: _formKey,
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.deepOrange,
                    secondary: Colors.deepOrange,
                  ),
                ),
                child: SizedBox(height: MediaQuery.of(context).size.height * 0.9, child: Stepper(
                  margin: const EdgeInsets.all(16),
                  type: StepperType.horizontal,
                  controlsBuilder: (context, details) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep != 0)
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: ElevatedButton(
                            onPressed: details.onStepCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(color: Color.fromARGB(255, 88, 84, 84)),
                            ),
                          ),
                        ),
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton(
                          onPressed: _currentStep == 2 ? _handleSignup : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            
                            _currentStep == 2 ? 'Sign Up' : 'Next',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < 2) {
                      setState(() {
                        _currentStep += 1;
                      });
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep -= 1;
                      });
                    }
                  },
                  steps: [
                    Step(
                      title: const Text('Account'),
                      content: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Username',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your username',
                              prefixIcon: Icon(Icons.person),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepOrange),
                              ),
                              focusColor: Colors.deepOrange,
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Username is required'
                                        : null,
                          ),
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Password',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                          TextFormField(
                          controller: _passwordController,
                          obscureText: !passwordVisible,
                  
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your password' : null,
                    decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepOrange),
                              ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                    
                  ),
                ),
            
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Email',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your email',
                              prefixIcon: Icon(Icons.email),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepOrange),
                              ),
                              focusColor: Colors.deepOrange,
                            ),
                            validator: _validateEmail,
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                    ),
                    Step(
                      title: const Text('Personal'),
                      content: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Full Name',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                           TextFormField(
                            controller: _fullnameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter your full name',
                              prefixIcon: Icon(Icons.person_outline),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepOrange),
                              ),
                              focusColor: Colors.deepOrange,
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Full name is required'
                                        : null,
                          ),
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Gender',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                          DropdownButtonFormField<Gender>(
                            value: _selectedGender,
                            decoration: const InputDecoration(
                              border:  OutlineInputBorder(),
                              prefixIcon:  Icon(Icons.male_rounded),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepOrange),
                              ),
                              focusColor: Colors.deepOrange,
                            ),
                            items:
                                Gender.values.map((role) {
                                  return DropdownMenuItem(
                                    value: role,
                                    child: Text(role.name.toUpperCase()),
                                  );
                                }).toList(),
                            onChanged: (Gender? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedGender = newValue;
                                });
                              }
                            },
                            validator:
                                (value) =>
                                    value == null ? 'Please select a Gender' : null,
                          ),
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Date of Birth',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                border:  OutlineInputBorder(),
                                prefixIcon: Icon(Icons.calendar_today),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                focusColor: Colors.deepOrange,
                              ),
                              child: Text(
                                _dateOfBirth == null
                                    ? 'Select date of birth'
                                    : DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(_dateOfBirth!),
                              ),
                            ),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 1,
                    ),
                    Step(
                      title: const Text('Work'),
                      content: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Employment Type',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                          
                            DropdownButtonFormField<EmploymentType>(
                            value: _selectedEmploymentType,
                            decoration: const InputDecoration(
                              border:  OutlineInputBorder(),
                              prefixIcon:  Icon(Icons.work),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepOrange),
                              ),
                              focusColor: Colors.deepOrange,
                            ),
                            items:
                                EmploymentType.values.map((role) {
                                  return DropdownMenuItem(
                                    value: role,
                                    child: Text(role.name.toUpperCase()),
                                  );
                                }).toList(),
                            onChanged: (EmploymentType? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedEmploymentType = newValue;
                                });
                              }
                            },
                            validator:
                                (value) =>
                                    value == null ? 'Please select an Employment Type' : null,
                          ),
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Designation',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                          TextFormField(
                            controller: _designationController,
                            decoration: const InputDecoration(
                              border:  OutlineInputBorder(),
                              hintText: 'Enter your designation',
                              prefixIcon: Icon(Icons.badge),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepOrange),
                              ),
                              focusColor: Colors.deepOrange,
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Designation is required'
                                        : null,
                          ),
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Role',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                          DropdownButtonFormField<UserRole>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              border:  OutlineInputBorder(),
                              prefixIcon:  Icon(Icons.admin_panel_settings),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.deepOrange),
                              ),
                              focusColor: Colors.deepOrange,
                            ),
                            items:
                                UserRole.values.map((role) {
                                  return DropdownMenuItem(
                                    value: role,
                                    child: Text(role.name.toUpperCase()),
                                  );
                                }).toList(),
                            onChanged: (UserRole? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedRole = newValue;
                                });
                              }
                            },
                            validator:
                                (value) =>
                                    value == null ? 'Please select a role' : null,
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 2,
                    ),
                  ],)
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.deepOrange),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )));
  }
}
