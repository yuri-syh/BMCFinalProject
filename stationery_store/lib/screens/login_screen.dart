import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Import para sa TapGestureRecognizer
import 'package:firebase_auth/firebase_auth.dart';
import 'products_screen.dart'; // Make sure this file exists and is correct
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool loading = false;
  bool _isPasswordVisible = false;

  static const Color _loginTextColor = Color(0xFF464C56);
  static const Color _boxFillColor = Color(0xFFD5D6D9);
  static const double _fillOpacity = 0.15;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Input validation
    if (_email.text.trim().isEmpty || _password.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter both email and password.")));
      return;
    }

    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => ProductsScreen()));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        // Error messages
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  e.message ?? "An unexpected error occurred during login.")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image (Make sure 'assets/images/bg.jpg' is in pubspec.yaml)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Overlay for readability
          Container(
            color: Colors.black.withOpacity(0.5), // Semi-transparent black overlay
          ),

          // 3. Login Content
          Center(
            child: SingleChildScrollView(
              // Added for better handling on small screens
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- DINAGDAG NA LOGO ---
                  // Siguraduhin na mayroon kang 'assets/images/logo.png' sa iyong proyekto
                  // at idinagdag mo ito sa 'pubspec.yaml'
                  Image.asset(
                    'assets/images/logo.png',
                    height: 150, // Pwede mong baguhin ang taas nito
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback kung walang image
                      return const Icon(
                        Icons.store,
                        size: 100,
                        color: Colors.white,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // --- END NG LOGO ---

                  const Text(
                    "Log In",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)]),
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon:
                      const Icon(Icons.email, color: Colors.white70),
                      labelStyle: const TextStyle(color: Colors.white70),
                      // I-activate ang field background fill
                      filled: true,
                      // Updated: Light gray with 15% opacity
                      fillColor: _boxFillColor.withOpacity(_fillOpacity),
                      enabledBorder: OutlineInputBorder(
                        // Border opacity for enabled state
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        // Border opacity for focused state
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextField(
                    controller: _password,
                    // Use _isPasswordVisible to toggle obscurity
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                      labelStyle: const TextStyle(color: Colors.white70),
                      // NEW: Suffix Icon (Toggle Eye)
                      suffixIcon: IconButton(
                        icon: Icon(
                          // Choose the icon based on password visibility
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          // Toggle the state of password visibility
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      // I-activate ang field background fill
                      filled: true,
                      // Updated: Light gray with 15% opacity
                      fillColor: _boxFillColor.withOpacity(_fillOpacity),
                      enabledBorder: OutlineInputBorder(
                        // Border opacity for enabled state
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        // Border opacity for focused state
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: loading
                          ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                          CircularProgressIndicator(strokeWidth: 2))
                          : const Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 18, color: _loginTextColor), // Updated text color
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Create Account Link
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors
                            .white70, // Slightly lighter color for the static part
                        fontSize: 14,
                      ),
                      children: [
                        // Static text
                        const TextSpan(
                          text: "Don't have an account? ",
                        ),
                        // Clickable text
                        TextSpan(
                          text: "Create Account",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: Colors.white, // Full white for emphasis
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SignupScreen()),
                              );
                            },
                        ),
                      ],
                    ),
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
