import 'package:gotrue/gotrue.dart' as gt show AuthException, User;
import 'package:supabase_flutter/supabase_flutter.dart' hide User, AuthException;

import '../../../core/either.dart';
import '../../../core/errors/failures.dart';
import '../../../core/unit.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';

/// Supabase-Auth-backed implementation of [AuthRepository].
///
/// This repository speaks directly to `SupabaseClient.auth` — no
/// intervening data source. The reason: Supabase Auth is a service-level
/// concern (manages JWTs, sessions, refresh tokens) that doesn't fit
/// the "table-shaped data source" pattern. Encapsulating it here keeps
/// presentation-layer dependencies clean (`AuthController` still only
/// knows about the abstract `AuthRepository`).
class SupabaseAuthRepositoryImpl implements AuthRepository {
  SupabaseAuthRepositoryImpl({required this.client});
  final SupabaseClient client;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = res.user;
      if (user == null) {
        return const Left(UnauthenticatedFailure());
      }
      return Right(_userEntityFromAuth(user));
    } on gt.AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final res = await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'display_name': displayName.trim()},
      );
      final user = res.user;
      if (user == null) {
        return const Left(ServerFailure(
          'Check your inbox to confirm your email before signing in.',
        ));
      }
      return Right(_userEntityFromAuth(user));
    } on gt.AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await client.auth.signOut();
      return const Right(Unit.instance);
    } on gt.AuthException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Build a [User] entity from the live `auth.users` record. Prefer the
  /// `display_name` user_metadata set during `signUp(data: {...})`; fall
  /// back to the local-part of the email.
  User _userEntityFromAuth(gt.User gotrueUser) {
    final id = gotrueUser.id;
    final email = gotrueUser.email ?? '';
    final displayName =
        (gotrueUser.userMetadata?['display_name'] as String?) ??
            email.split('@').first;
    return UserModel(
      id: id,
      email: email,
      displayName: displayName,
    ).toEntity();
  }
}
