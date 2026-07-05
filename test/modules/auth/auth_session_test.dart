import 'package:appex/core/errors/failures.dart';
import 'package:appex/core/either.dart';
import 'package:appex/domain/entities/user.dart';
import 'package:appex/domain/repositories/user_repository.dart';
import 'package:appex/modules/auth/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUserRepo implements UserRepository {
  _FakeUserRepo({this.currentUser, this.failureOnGetCurrent = false});
  User? currentUser;
  bool failureOnGetCurrent;

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    if (failureOnGetCurrent) {
      return const Left(UnauthenticatedFailure());
    }
    if (currentUser == null) {
      return const Left(UnauthenticatedFailure());
    }
    return Right<Failure, User>(currentUser!);
  }

  @override
  Future<Either<Failure, User>> getUserById(String id) async {
    if (currentUser == null) {
      return const Left(UnauthenticatedFailure());
    }
    return Right<Failure, User>(currentUser!);
  }
}

User _makeUser([String id = 'u1']) =>
    User(id: id, email: 'a@b.com', displayName: 'Alice');

void main() {
  group('AuthSession', () {
    test('bootstrap() with restored session → isAuthenticated true', () async {
      final repo = _FakeUserRepo(currentUser: _makeUser());
      final session = AuthSession(userRepository: repo);

      expect(session.isAuthenticated, isFalse);
      final result = await session.bootstrap();

      expect(result.isRight, isTrue);
      expect(session.isAuthenticated, isTrue);
      expect(session.currentUser.value?.id, 'u1');
      expect(session.isBootstrapped.value, isTrue);
    });

    test('bootstrap() when repo returns UnauthenticatedFailure → isAuthenticated false',
        () async {
      final repo = _FakeUserRepo(failureOnGetCurrent: true);
      final session = AuthSession(userRepository: repo);

      final result = await session.bootstrap();

      expect(result.isLeft, isTrue);
      expect(session.isAuthenticated, isFalse);
      expect(session.currentUser.value, isNull);
    });

    test('setUser makes isAuthenticated true immediately', () {
      final repo = _FakeUserRepo();
      final session = AuthSession(userRepository: repo);

      expect(session.isAuthenticated, isFalse);
      session.setUser(_makeUser('u2'));
      expect(session.isAuthenticated, isTrue);
      expect(session.currentUser.value?.id, 'u2');
    });

    test('clear() removes the active user', () async {
      final repo = _FakeUserRepo(currentUser: _makeUser());
      final session = AuthSession(userRepository: repo);

      await session.bootstrap();
      expect(session.isAuthenticated, isTrue);

      await session.clear();
      expect(session.isAuthenticated, isFalse);
      expect(session.currentUser.value, isNull);
    });
  });
}
