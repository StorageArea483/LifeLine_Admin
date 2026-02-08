import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:life_line_admin/firebase_options.dart';
import 'package:life_line_admin/utils/styles.dart';
import 'package:life_line_admin/widgets/global/admin_authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://npczrptqrtrbyqhzptil.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5wY3pycHRxcnRyYnlxaHpwdGlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2Nzg1NzgsImV4cCI6MjA4MDI1NDU3OH0.ZGxwwksLTeTqZ1cxoP7nj-dG2sRMzCmPVJt4ovO5y3Q',
  );
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LifeLine Admin',
      theme: AppTheme.lightTheme,
      home: const AdminAuthentication(),
    );
  }
}
