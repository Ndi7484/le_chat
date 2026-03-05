import 'package:flutter/material.dart';
import 'package:le_chat/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://arrtcxuszvjrvaxbixqp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFycnRjeHVzenZqcnZheGJpeHFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI2NzAyOTgsImV4cCI6MjA4ODI0NjI5OH0.P_KB7QJg5TfbXa9sjbHOhEHAmlu8h5780VcaP3pyhhs',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1A3263),
          primary: Color(0xFF1A3263),
          secondary: Color(0xFF547792),
          onPrimary: Color(0xFFFAB95B),
          onSecondary: Color(0xFFE8E2DB),
        )),
      home: LoginPage(),
    );
  }
}