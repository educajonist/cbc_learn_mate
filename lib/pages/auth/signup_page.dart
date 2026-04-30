import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final auth = AuthService();

  bool loading = false;

  void signUp() async {
    setState(() => loading = true);

    try {
      await auth.signUp(email.text.trim(), password.text.trim());
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign up failed: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Sign Up", style: TextStyle(fontSize: 24)),
              TextField(
                  controller: email,
                  decoration: const InputDecoration(labelText: "Email")),
              TextField(
                  controller: password,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : signUp,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
