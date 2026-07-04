import 'package:appex/core/errors/failures.dart';
import 'package:appex/core/unit.dart';
import 'package:appex/data/repositories/supabase/supabase_auth_repository_impl.dart';
import 'package:appex/domain/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotrue/gotrue.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User, AuthException;

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _FakeGoTrueUser extends Fake implements User {}

void main() {
  late _MockSupabaseClient client;
  late AuthRepository repo;

  setUpAll(() {
    registerFallbackValue(_FakeGoTrueUser());
  });

  setUp(() {
    client = _MockSupabaseClient();
    repo = SupabaseAuthRepositoryImpl(client: client);
  });

  group('SupabaseAuthRepositoryImpl', () {
    test('login → Right(User) on success', () async {
      final auth = MockGoTrueClient();
      final fakeUser = User(
        id: 'u-demo',
        appMetadata: const {},
        userMetadata: const {'display_name': 'Demo Student'},
        aud: 'authenticated',
        email: 'student@appex.dev',
        phone: '',
        createdAt: DateTime.utc(2024, 1, 1).toIso8601String(),
      );
      when(() => client.auth).thenReturn(auth);
      when(() => auth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => AuthResponse(user: fakeUser));

      final result = await repo.login(
        email: 'student@appex.dev',
        password: 'password123',
      );

      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('expected success'),
        (u) {
          expect(u.id, 'u-demo');
          expect(u.email, 'student@appex.dev');
          expect(u.displayName, 'Demo Student');
        },
      );
    });

    test('login → Left(ServerFailure) when signIn throws AuthException', () async {
      final auth = MockGoTrueClient();
      when(() => client.auth).thenReturn(auth);
      when(() => auth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(
        AuthException('Invalid login credentials', code: 'invalid_grant'),
      );

      final result = await repo.login(
        email: 'bad@appex.dev',
        password: 'wrong',
      );

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Invalid login'));
        },
        (_) => fail('expected failure'),
      );
    });

    test('login → Left(UnauthenticatedFailure) when signIn returns null user',
        () async {
      final auth = MockGoTrueClient();
      when(() => client.auth).thenReturn(auth);
      when(() => auth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => AuthResponse(user: null));

      final result = await repo.login(
        email: 'ghost@appex.dev',
        password: 'password123',
      );

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnauthenticatedFailure>()),
        (_) => fail('expected failure'),
      );
    });

    test('logout → Right(Unit) on success', () async {
      final auth = MockGoTrueClient();
      when(() => client.auth).thenReturn(auth);
      when(() => auth.signOut()).thenAnswer((_) async {});

      final result = await repo.logout();

      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('expected success'),
        (unit) => expect(unit, Unit.instance),
      );
    });

    test('logout → Left(ServerFailure) if AuthException is thrown', () async {
      final auth = MockGoTrueClient();
      when(() => client.auth).thenReturn(auth);
      when(() => auth.signOut()).thenThrow(AuthException('oops'));

      final result = await repo.logout();

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('expected failure'),
      );
    });
  });
}

// Concrete mock for GoTrueClient (the actual class behind client.auth).
class MockGoTrueClient extends Mock implements GoTrueClient {}
