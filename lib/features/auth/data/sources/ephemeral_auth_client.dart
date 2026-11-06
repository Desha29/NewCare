import 'package:supabase_flutter/supabase_flutter.dart';
import 'bounded_http_client.dart';

/// Password/username flows return tokens directly and never use an OAuth/PKCE
/// redirect. These clients intentionally have no persistent session storage.
SupabaseClient createEphemeralAuthClient(String url, String key) =>
    SupabaseClient(
      url,
      key,
      httpClient: BoundedHttpClient(),
      authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );
