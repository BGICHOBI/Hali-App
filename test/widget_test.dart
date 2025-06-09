// test/widget_test.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hali/main.dart'; // ← your pubspec name

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 1×1 transparent PNG
  final pngBytes = Uint8List.fromList(<int>[
    0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,
    0x00,0x00,0x00,0x0D,0x49,0x48,0x44,0x52,
    0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x01,
    0x08,0x02,0x00,0x00,0x00,0x90,0x77,0x53,0xDE,
    0x00,0x00,0x00,0x00,0x49,0x45,0x4E,0x44,
    0xAE,0x42,0x60,0x82,
  ]);
  final pngData = ByteData.view(pngBytes.buffer);

  setUpAll(() {
    ServicesBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        if (message == null) return null;

        String? key;

        // Try MethodCall API ("load")
        try {
          final call = const StandardMethodCodec().decodeMethodCall(message);
          if (call.method == 'load') {
            key = call.arguments as String;
          }
        } catch (_) {
          // Not a MethodCall, fall through
        }

        // Try structured API ("loadStructuredBinaryData")
        if (key == null) {
          try {
            final decoded = const StandardMessageCodec().decodeMessage(message);
            if (decoded is String) {
              key = decoded;
            }
          } catch (_) {
            // give up
          }
        }

        if (key == null) return null;

        // Your logo
        if (key == 'assets/images/hali_logo.png') {
          return pngData;
        }

        // AssetManifest.bin wants a Map<String,List<String>>, encoded with StandardMessageCodec
        if (key == 'AssetManifest.bin') {
          final manifestMap = {
            'assets/images/hali_logo.png': ['assets/images/hali_logo.png']
          };
          final manifestData =
              const StandardMessageCodec().encodeMessage(manifestMap)!;
          return ByteData.view(manifestData.buffer);
        }

        // Any other .json (FontManifest.json, etc.) → empty JSON
        if (key.endsWith('.json')) {
          final empty = utf8.encoder.convert('{}');
          return ByteData.view(Uint8List.fromList(empty).buffer);
        }

        return null;
      },
    );
  });

  testWidgets('LoginScreen renders correctly', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HaliApp()));
    await tester.pumpAndSettle();

    // your login button is labeled "Log In"
    expect(find.text('Log In'), findsOneWidget);
  });
}
