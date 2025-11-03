import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool loading = false;
  // NEW: State variables for password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  static const Color _boxFillColor = Color(0xFFD5D6D9);
  static const double _fillOpacity = 0.15;
  static const Color _loginTextColor = Color(0xFF464C56);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    // Basic input validation
    if (_email.text.trim().isEmpty ||
        _password.text.trim().isEmpty ||
        _name.text.trim().isEmpty ||
        _confirmPassword.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill in all fields.")));
      return;
    }

    if (_password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match.")));
      return;
    }

    setState(() => loading = true);
    try {
      final userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      // Optionally update user's display name
      await userCredential.user?.updateDisplayName(_name.text.trim());

      // Navigate back to LoginScreen upon successful signup
      if (mounted) {
        Navigator.pushReplacement(
          // FIX: Removed 'const'
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                e.message ?? "An unexpected error occurred during signup.")));
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
            color: Colors.black.withOpacity(0.5),
          ),

          // 3. Sign Up Content
          Center(
            child: SingleChildScrollView(
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
                    "Create New Account",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)]),
                  ),
                  const SizedBox(height: 40),

                  // Name Field
                  TextField(
                    controller: _name,
                    keyboardType: TextInputType.name,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Name",
                      prefixIcon:
                      const Icon(Icons.person, color: Colors.white70),
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: _boxFillColor.withOpacity(_fillOpacity),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

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
                      filled: true,
                      fillColor: _boxFillColor.withOpacity(_fillOpacity),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
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
                      // Suffix Icon (Toggle Eye)
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: _boxFillColor.withOpacity(_fillOpacity),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password Field
                  TextField(
                    controller: _confirmPassword,
                    obscureText: !_isConfirmPasswordVisible,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      prefixIcon:
                      const Icon(Icons.lock_reset, color: Colors.white70),
                      labelStyle: const TextStyle(color: Colors.white70),
                      // Suffix Icon (Toggle Eye)
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: _boxFillColor.withOpacity(_fillOpacity),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Create Account
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : _signup,
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
                        "Create Account",
                        style: TextStyle(
                            fontSize: 18, color: _loginTextColor),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Back to Login
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                        "Already have an account? Go back to Login",
                        style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline)),
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
