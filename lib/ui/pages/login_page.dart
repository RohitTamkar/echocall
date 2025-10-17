import 'package:flutter/material.dart';
import 'package:echocall/auth_service.dart';
import 'package:echocall/ui/pages/signup_page.dart';
import 'package:echocall/ui/app_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _mobileCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    bool success = await _auth.login(
      _mobileCtrl.text.trim(),
      _pinCtrl.text.trim(),
    );
    setState(() => _loading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid Mobile or PIN")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Login", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              TextField(
                controller: _mobileCtrl,
                decoration: const InputDecoration(labelText: "Mobile Number"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pinCtrl,
                obscureText: true,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "PIN"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
              // TextButton(
              //   onLongPress: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (_) => const SignupPage()),
              //     );
              //   },
              //   onPressed: () {  },
              //   // child: const Text("Create Account"),
              //   child: const Text(""),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
