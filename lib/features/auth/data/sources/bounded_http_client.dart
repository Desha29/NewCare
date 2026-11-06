import 'dart:async';

import 'package:http/http.dart' as http;

/// Bound the HTTP response before Supabase can parse and publish a session.
/// A late transport response is discarded, rather than a late Auth side effect.
class BoundedHttpClient extends http.BaseClient {
  BoundedHttpClient({
    http.Client? inner,
    this.deadline = const Duration(seconds: 15),
  }) : _inner = inner ?? http.Client();
  final http.Client _inner;
  final Duration deadline;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request).timeout(deadline);
    return http.StreamedResponse(
      response.stream.timeout(deadline),
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  @override
  void close() => _inner.close();
}
