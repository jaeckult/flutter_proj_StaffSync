import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:staffsync/application/providers/providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreen();
}

class _SignupScreen extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _employmentTypeController = TextEditingController();
  final _designationController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _roleController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  int _currentStep = 0;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _genderController.dispose();
    _employmentTypeController.dispose();
    _designationController.dispose();
    _dateOfBirthController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authNotifier = ref.read(authNotifierProvider.notifier);
        await authNotifier.signup(
          _usernameController.text,
          _passwordController.text,
          _emailController.text,
          _fullNameController.text,
          _genderController.text,
          _employmentTypeController.text,
          _designationController.text,
          _dateOfBirthController.text,
          _roleController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully signed up!')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _stepTapped(int step) {
    setState(() => _currentStep = step);
  }

  void _stepContinue() {
    if (_currentStep < 8) {
      setState(() => _currentStep += 1);
    } else {
      _handleSignup();
    }
  }

  void _stepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Expanded(
            child: Image(
              image: AssetImage('signup_illustration.png'),
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: Stepper(
                margin: const EdgeInsets.all(20),
                type: StepperType.horizontal,
                controlsBuilder:
                    (context, details) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                232,
                                117,
                                35,
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : Text(
                                      _currentStep == 8
                                          ? 'Sign Up'
                                          : 'Continue',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : details.onStepCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                232,
                                117,
                                35,
                              ),
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                physics: const ScrollPhysics(),
                currentStep: _currentStep,
                onStepTapped: _stepTapped,
                onStepContinue: _stepContinue,
                onStepCancel: _stepCancel,
                steps: [
                  Step(
                    stepStyle: StepStyle(color: Colors.orange[700]),
                    title: const Text('Username'),
                    content: TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(gapPadding: 4.0),
                        hintText: 'Enter your username',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),

                    isActive: _currentStep >= 0,
                    state:
                        _currentStep > 0
                            ? StepState.complete
                            : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Email'),
                    stepStyle: StepStyle(color: Colors.orange[700]),
                    content: TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    isActive: _currentStep >= 1,
                    state:
                        _currentStep > 1
                            ? StepState.complete
                            : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Full Name'),
                    stepStyle: StepStyle(color: Colors.orange[700]),
                    content: TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    isActive: _currentStep >= 2,
                    state:
                        _currentStep > 2
                            ? StepState.complete
                            : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Gender'),
                    stepStyle: StepStyle(color: Colors.orange[700]),
                    content: TextFormField(
                      controller: _genderController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your gender',
                        prefixIcon: Icon(Icons.people),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your gender';
                        }
                        return null;
                      },
                    ),
                    isActive: _currentStep >= 3,
                    state:
                        _currentStep > 3
                            ? StepState.complete
                            : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Employment Type'),
                    stepStyle: StepStyle(color: Colors.orange[700]),
                    content: TextFormField(
                      controller: _employmentTypeController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your employment type',
                        prefixIcon: Icon(Icons.work),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your employment type';
                        }
                        return null;
                      },
                    ),
                    isActive: _currentStep >= 4,
                    state:
                        _currentStep > 4
                            ? StepState.complete
                            : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Designation'),
                    stepStyle: StepStyle(color: Colors.orange[700]),
                    content: TextFormField(
                      controller: _designationController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your designation',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your designation';
                        }
                        return null;
                      },
                    ),
                    isActive: _currentStep >= 5,
                    state:
                        _currentStep > 5
                            ? StepState.complete
                            : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Date of Birth'),
                    stepStyle: StepStyle(color: Colors.orange[700]),
                    content: TextFormField(
                      controller: _dateOfBirthController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your date of birth',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your date of birth';
                        }
                        return null;
                      },
                    ),
                    isActive: _currentStep >= 6,
                    state:
                        _currentStep > 6
                            ? StepState.complete
                            : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Role'),
                    stepStyle: StepStyle(color: Colors.orange[700]),
                    content: TextFormField(
                      controller: _roleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your role',
                        prefixIcon: Icon(Icons.assignment_ind),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your role';
                        }
                        return null;
                      },
                    ),
                    isActive: _currentStep >= 7,
                    state:
                        _currentStep > 7
                            ? StepState.complete
                            : StepState.indexed,
                  ),
                  Step(
                    title: const Text('Password'),
                    stepStyle: StepStyle(color: Colors.orange[700]),
                    content: TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    isActive: _currentStep >= 8,
                    state:
                        _currentStep > 8
                            ? StepState.complete
                            : StepState.indexed,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
