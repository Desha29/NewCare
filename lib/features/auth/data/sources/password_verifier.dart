import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

abstract interface class PasswordVerifier {
  Future<String> create(String password);
  Future<bool> matches(String password, String encoded);
}

/// Versioned PBKDF2-HMAC-SHA256 verifier, protected again by the encrypted store.
/// The expensive derivation runs outside the Windows UI isolate.
class Pbkdf2PasswordVerifier implements PasswordVerifier {
  static const iterations = 600000;

  @override
  Future<String> create(String password) async {
    final random = Random.secure();
    final salt = List<int>.generate(32, (_) => random.nextInt(256));
    final hash = await compute(_derive, (password, salt));
    return jsonEncode({
      'v': 1,
      'salt': base64Encode(salt),
      'hash': base64Encode(hash),
    });
  }

  @override
  Future<bool> matches(String password, String encoded) async {
    final data = jsonDecode(encoded) as Map<String, dynamic>;
    if (data['v'] != 1) throw const FormatException('Unsupported verifier');
    final salt = base64Decode(data['salt'] as String);
    final expected = base64Decode(data['hash'] as String);
    if (salt.length != 32 || expected.length != 32) {
      throw const FormatException('Invalid verifier');
    }
    final actual = await compute(_derive, (password, salt));
    var difference = 0;
    for (var i = 0; i < expected.length; i++) {
      difference |= expected[i] ^ actual[i];
    }
    return difference == 0;
  }
}

Future<List<int>> _derive((String, List<int>) input) async {
  final key = await Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: Pbkdf2PasswordVerifier.iterations,
    bits: 256,
  ).deriveKey(secretKey: SecretKey(utf8.encode(input.$1)), nonce: input.$2);
  return key.extractBytes();
}
