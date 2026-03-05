import 'package:flutter/material.dart';
import 'package:le_chat/login_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initSupabase() async {
    await Supabase.initialize(
      url: 'https://arrtcxuszvjrvaxbixqp.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFycnRjeHVzenZqcnZheGJpeHFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI2NzAyOTgsImV4cCI6MjA4ODI0NjI5OH0.P_KB7QJg5TfbXa9sjbHOhEHAmlu8h5780VcaP3pyhhs',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Le\' Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1A3263),
          primary: Color(0xFF1A3263),
          secondary: Color(0xFF547792),
          onPrimary: Color(0xFFFAB95B),
          onSecondary: Color(0xFFE8E2DB),
        ),
      ),
      home: FutureBuilder(
        future: _initSupabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading effect
            return Scaffold(
              body: Center(
                child: LoadingAnimationWidget.fallingDot(
                  color: Theme.of(context).colorScheme.primary,
                  size: 200,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            // Show error if initialization fails
            return Scaffold(
              body: Center(
                child: Column(
                  children: [
                    Icon(Icons.close, color: Colors.grey, size: 200),
                    SizedBox(height: 16),
                    Text('Error initializing Le\' Chat Connection'),
                  ],
                ),
              ),
            );
          } else {
            // Supabase initialized, show login page
            return const LoginPage();
          }
        },
      ),
    );
  }
}
