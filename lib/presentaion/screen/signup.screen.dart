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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme,
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
                              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            child: Text('Back', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                          ),
                        ),
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton(
                          onPressed: _currentStep == 2 ? _handleSignup : details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
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
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
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
                      title: Text('Account', style: Theme.of(context).textTheme.labelLarge),
                      content: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Username', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'Enter your username',
                              prefixIcon: const Icon(Icons.person),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Username is required'
                                        : null,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Password', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ),
                          TextFormField(
                          controller: _passwordController,
                          obscureText: !passwordVisible,
                  
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your password' : null,
                    decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
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
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Email', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'Enter your email',
                              prefixIcon: const Icon(Icons.email),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            validator: _validateEmail,
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                    ),
                    Step(
                      title: Text('Personal', style: Theme.of(context).textTheme.labelLarge),
                      content: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Full Name', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ),
                           TextFormField(
                            controller: _fullnameController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'Enter your full name',
                              prefixIcon: const Icon(Icons.person_outline),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Full name is required'
                                        : null,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Gender', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ),
                          DropdownButtonFormField<Gender>(
                            value: _selectedGender,
                            decoration: InputDecoration(
                              border:  const OutlineInputBorder(),
                              prefixIcon:  const Icon(Icons.male_rounded),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
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
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Date of Birth', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border:  const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.calendar_today),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
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
                      title: Text('Work', style: Theme.of(context).textTheme.labelLarge),
                      content: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Employment Type', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ),
                          
                            DropdownButtonFormField<EmploymentType>(
                            value: _selectedEmploymentType,
                            decoration: InputDecoration(
                              border:  const OutlineInputBorder(),
                              prefixIcon:  const Icon(Icons.work),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
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
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Designation', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ),
                          TextFormField(
                            controller: _designationController,
                            decoration: InputDecoration(
                              border:  const OutlineInputBorder(),
                              hintText: 'Enter your designation',
                              prefixIcon: const Icon(Icons.badge),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Designation is required'
                                        : null,
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Role', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ),
                          DropdownButtonFormField<UserRole>(
                            value: _selectedRole,
                            decoration: InputDecoration(
                              border:  const OutlineInputBorder(),
                              prefixIcon:  const Icon(Icons.admin_panel_settings),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
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
                Text("Already have an account?", style: Theme.of(context).textTheme.bodyMedium),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text('Login', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            ),
          ),
        ],
      ),
    )));
  }
}
