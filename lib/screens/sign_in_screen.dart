import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'todo_list_screen.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isPasswordVisible = false;

  void _signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      Get.offAll(() => TodoListScreen());
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred, please try again. ${e.code}';
      if (e.code == 'invalid-credential') {
        message = 'Email or password is incorrect';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts, please try later';
      }
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
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
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar('Error', 'Please enter your email to reset your password.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!_isEmailValid) {
      Get.snackbar('Error', 'Please enter a valid email address.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

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
                'Sign in with email',
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
                onChanged: (value) => _validatePassword(value),
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: (_isEmailValid && _isPasswordValid) ? _signIn : null,
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
                  'Sign In',
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 16.0),
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
