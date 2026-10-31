import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/manager_identity.dart';

abstract final class UsernameAuthConfiguration {
  static Future<void> ensureReady({
    required String url,
    required String key,
    bool requireAnonymous = false,
  }) async {
    final response = await http
        .get(Uri.parse('$url/auth/v1/settings'), headers: {'apikey': key})
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw const ManagerAuthException('cloudSetupFailed');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    // Refuse provisioning while confirmation is enabled, rather than sending
    // an unwanted message or creating an unusable internal-address account.
    if (data['mailer_autoconfirm'] != true) {
      throw const ManagerAuthException('emailConfirmationStillEnabled');
    }
    if (requireAnonymous &&
        (data['external'] as Map?)?['anonymous_users'] != true) {
      throw const ManagerAuthException('anonymousSignInNotEnabled');
    }
  }
}
