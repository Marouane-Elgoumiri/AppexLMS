/// Supabase project configuration.
///
/// NOTE: the URL and publishable key below are committed plaintext and are
/// already in git history. They are safe to expose (the publishable key is
/// the anon-key equivalent and is sent to clients by design), but they
/// should be **rotated** in the Supabase Dashboard before any real
/// production deployment of this app.
abstract class SupabaseConfig {
  SupabaseConfig._();

  /// Rotate in Dashboard → Project Settings → API → "-publishable key".
  static const String url = 'https://npqrpcnpgfshazeozmkr.supabase.co';
  static const String publishableKey =
      'sb_publishable_0QFs6SfsC1NVOOXK9gA1DA_jzaNRNaQ';
}
