import 'package:flutter/material.dart';
import 'package:le_chat/chat_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _controller.text.trim();
    final client = Supabase.instance.client;

    // Check if username already exists
    final existing = await client
        .from('users')
        .select()
        .eq('username', username)
        .maybeSingle();

    if (existing != null) {
      // Show error if username exists
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Username '$username' already taken")),
      );
      return;
    }

    // Insert new user
    await client.from('users').insert({'username': username});

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChatPage(username: username)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Login Chat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Username :'),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: _controller,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a username';
                          }
                          return null; // valid
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: const Text("Login"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}