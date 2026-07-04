import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../models/user_model.dart';
import '../../mock/mock_user_data_source.dart' show UserDataSource;

/// Supabase-backed implementation of [UserDataSource].
///
/// `getCurrent()` reads from `auth.currentUser` (the live JWT session)
/// plus a `.from('profiles').select().eq('id', uid).single()` lookup for
/// the display_name. Auth responsibilities (login/register/logout) are
/// NOT on this interface — those live one layer up in
/// [SupabaseAuthRepositoryImpl] which talks directly to `supabase.auth`.
class SupabaseUserDataSource implements UserDataSource {
  SupabaseUserDataSource({required this.client});
  final SupabaseClient client;

  @override
  Future<UserModel> getCurrent() async {
    final auth = client.auth.currentUser;
    if (auth == null) {
      throw const CacheException('No user is currently signed in.');
    }
    return _fetchProfile(auth.id, fallbackEmail: auth.email);
  }

  @override
  Future<UserModel> getById(String id) async {
    try {
      return await _fetchProfile(id);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<UserModel> _fetchProfile(String id, {String? fallbackEmail}) async {
    try {
      final rows = await client
          .from('profiles')
          .select()
          .eq('id', id)
          .limit(1);
      if (rows.isEmpty) {
        // Fall back to whatever auth gave us when called from getCurrent().
        if (fallbackEmail != null) {
          return UserModel(
            id: id,
            email: fallbackEmail,
            displayName: fallbackEmail.split('@').first,
          );
        }
        throw CacheException('User "$id" not found.');
      }
      return UserModel.fromJson(Map<String, dynamic>.from(rows.first));
    } catch (e) {
      throw e is CacheException
          ? e
          : ServerException(e.toString());
    }
  }
}
