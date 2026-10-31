import 'package:supabase_flutter/supabase_flutter.dart';

/// Password/username flows return tokens directly and never use an OAuth/PKCE
/// redirect. These clients intentionally have no persistent session storage.
SupabaseClient createEphemeralAuthClient(String url, String key) =>
    SupabaseClient(
      url,
      key,
      authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );
