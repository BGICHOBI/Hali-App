// lib/screens/signup_screen.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Toggle between phone vs email UI
  bool _useEmail = kIsWeb;

  // Phone controllers/state
  final _phoneCtrl = TextEditingController();
  final _codeCtrl  = TextEditingController();
  String? _verificationId;
  bool _codeSent = false;

  // Email controllers/state
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAnalytics.instance.logEvent(name: 'signup_screen_view');
  }

  /// PHONE: send SMS code
  Future<void> _sendCode() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) return;

    setState(() => _loading = true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (_) { /* auto */ },
      verificationFailed: (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message ?? 'Failed to send code')));
        FirebaseAnalytics.instance.logEvent(
          name: 'send_code_failed',
          parameters: {'message': e.message ?? 'unknown'},
        );
        setState(() => _loading = false);
      },
      codeSent: (id, _) {
        setState(() {
          _verificationId = id;
          _codeSent = true;
          _loading = false;
        });
        FirebaseAnalytics.instance.logEvent(name: 'code_sent');
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// PHONE: verify SMS and create user in Firestore
  Future<void> _verifyCode() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty || _verificationId == null) return;

    setState(() => _loading = true);
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      final res = await FirebaseAuth.instance.signInWithCredential(cred);
      final user = res.user!;
      // add initial Firestore doc
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'phone': user.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'balance': 0,
      });
      await FirebaseAnalytics.instance.logSignUp(signUpMethod: 'phone');
      Navigator.pushReplacementNamed(context, '/verify-email');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Verification failed')));
      FirebaseAnalytics.instance.logEvent(
        name: 'verify_code_failed',
        parameters: {'message': e.message ?? 'unknown'},
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  /// EMAIL: create with email & password
  Future<void> _signUpWithEmail() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passwordCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) return;

    setState(() => _loading = true);
    try {
      final res = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      final user = res.user!;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'balance': 0,
      });
      await FirebaseAnalytics.instance.logSignUp(signUpMethod: 'email');
      Navigator.pushReplacementNamed(context, '/verify-email');
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Sign-up failed')));
      FirebaseAnalytics.instance.logEvent(
        name: 'email_signup_failed',
        parameters: {'message': e.message ?? 'unknown'},
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign up')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Toggle
              if (!kIsWeb)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Phone'),
                      selected: !_useEmail,
                      onSelected: (v) => setState(() => _useEmail = !v),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Email'),
                      selected: _useEmail,
                      onSelected: (v) => setState(() => _useEmail = v),
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // PHONE FLOW
              if (!_useEmail) ...[
                TextField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Phone (e.g. +2547...)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : (_codeSent ? _verifyCode : _sendCode),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_codeSent ? 'Verify & Continue' : 'Send Code'),
                ),
              ],

              // EMAIL FLOW
              if (_useEmail) ...[
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _signUpWithEmail,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign up'),
                ),
              ],

              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  FirebaseAnalytics.instance.logEvent(name: 'tap_go_to_login');
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('← Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
