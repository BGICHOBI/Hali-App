import 'dart:html' as html; // to read window.location
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _auth      = FirebaseAuth.instance;
  final _analytics = FirebaseAnalytics.instance;

  bool _isSending  = false;
  bool _isChecking = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _analytics.logEvent(name: 'verify_email_screen_view');
    _handleIncomingLink();
  }

  /// If someone lands here with ?oobCode=xxx, try to apply it immediately.
  Future<void> _handleIncomingLink() async {
    final uri = Uri.parse(html.window.location.href);
    final code = uri.queryParameters['oobCode'];
    if (code != null) {
      setState(() => _isChecking = true);
      try {
        await _auth.applyActionCode(code);
        setState(() => _message = 'Email successfully verified!');
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e, st) {
        await FirebaseCrashlytics.instance.recordError(e, st, fatal: false);
        setState(() => _message = 'Invalid or expired verification link.');
      } finally {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _sendVerification() async {
    setState(() => _isSending = true);
    try {
      final user = _auth.currentUser!;
      await user.sendEmailVerification(
        ActionCodeSettings(
          url: 'https://your-app.web.app/verify-email',   // ← must be in your Authorized Domains
          handleCodeInApp: true,
          iOSBundleId: 'com.yourcompany.yourapp',
          androidPackageName: 'com.yourcompany.yourapp',
          androidInstallApp: true,
          androidMinimumVersion: '1',
          // dynamicLinkDomain: 'yourcustom.page.link',   // if using Dynamic Links
        ),
      );
      await _analytics.logEvent(name: 'verification_email_sent');
      setState(() => _message = 'Verification email sent – check your inbox!');
    } on FirebaseAuthException catch (e, st) {
      await FirebaseCrashlytics.instance.recordError(e, st, fatal: false);
      setState(() => _message = 'Error: ${e.message}');
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('✉️ Verify Your Email')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'We sent a link to your email. '
              'Please click it, then tap “I’ve Verified” below.',
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(_message!, style: TextStyle(color: Colors.teal)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSending ? null : _sendVerification,
              child: _isSending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Resend Verification Email'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isChecking
                  ? null
                  : () => _handleIncomingLink(), // manual re-check
              child: _isChecking
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('I’ve Verified'),
            ),
          ],
        ),
      ),
    );
  }
}
