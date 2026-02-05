import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
    // Show error dialog
    runApp(ErrorApp(error: e.toString()));
    return;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disaster Response System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1B9B8E),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B9B8E),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({required this.error, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        appBar: AppBar(
          title: const Text('Firebase Initialization Error'),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                '❌ Firebase Initialization Failed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Error Details:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Common Causes:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const BulletPoint('google-services.json not found in android/app/'),
              const BulletPoint('google-services.json is corrupted or invalid'),
              const BulletPoint('Firebase project ID mismatch'),
              const BulletPoint('Android build.gradle not updated'),
              const BulletPoint('Google Services plugin not applied'),
              const SizedBox(height: 20),
              const Text(
                'Solutions:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const BulletPoint('Verify google-services.json exists at: android/app/google-services.json'),
              const BulletPoint('Check firebase project ID in google-services.json matches Firebase Console'),
              const BulletPoint('Update android/build.gradle with Google Services plugin'),
              const BulletPoint('Update android/app/build.gradle: apply plugin \'com.google.gms.google-services\''),
              const BulletPoint('Run: flutter clean && flutter pub get && flutter run'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Restart app
                  print('Restarting app...');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}