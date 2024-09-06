import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isPasswordVisible = false;

  void _signUp() async {
    // Check if email and password fields are not empty
    if (_emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Show success message
        Get.snackbar(
          'Success',
          'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Add a delay to show the success message before navigation
        await Future.delayed(Duration(seconds: 2));

        // Navigate back to the welcome screen after successful signup
        Get.offAllNamed('/'); // This navigates to the root route of the app
      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred, please try again.';
        if (e.code == 'email-already-in-use') {
          message = 'An account already exists for that email.';
        }
        Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('Error', e.toString(),
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      // Doesn't really run because the button will be disabled in this case but acts as a safety backup
      Get.snackbar('Error', 'Please fill in all fields',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _validateEmail(String email) {
    setState(() {
      _isEmailValid =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$')
              .hasMatch(email.trim());
    });
  }

  void _validatePassword(String password) {
    setState(() {
      _isPasswordValid = password.length >= 6;
    });
  }

  void _forgotPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      Get.snackbar('Success',
          'Password reset email sent, if email exists in the system!',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send reset email.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Transform.translate(
                offset: const Offset(-15.0, 0.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_sharp),
                    onPressed: () {
                      Get.back(); // Pop the current screen off the stack
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Sign up with email',
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Enter your email and password',
                style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 35.0),
              TextField(
                controller: _emailController,
                onChanged: (value) => _validateEmail(value.trim()),
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  labelStyle: TextStyle(color: Colors.grey),
                  suffixIcon: _isEmailValid
                      ? Icon(Icons.check_circle_sharp, color: Colors.black)
                      : null,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                onChanged: _validatePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: (_isEmailValid && _isPasswordValid)
                      ? _forgotPassword
                      : null,
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: (_isEmailValid && _isPasswordValid)
                          ? Colors.blue
                          : Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: (_isEmailValid && _isPasswordValid) ? _signUp : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_isEmailValid && _isPasswordValid)
                      ? Colors.black
                      : Color.fromARGB(141, 188, 192, 192),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 20.0),
              FractionallySizedBox(
                widthFactor: 0.80,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: 'By continuing, you agree to our ',
                    style: const TextStyle(
                      fontSize: 13.0,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Terms of Use.',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
