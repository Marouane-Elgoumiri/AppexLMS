import 'package:appex/core/errors/failures.dart';
import 'package:appex/data/datasources/mock/mock_user_data_source.dart';
import 'package:appex/data/repositories/user_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockUserDataSource dataSource;
  late UserRepositoryImpl repo;

  setUp(() {
    dataSource = MockUserDataSource();
    repo = UserRepositoryImpl(dataSource: dataSource);
  });

  group('MockUserRepository — CRUD operations (3.5)', () {
    test('getById returns Right(User) for known id', () async {
      final result = await repo.getUserById('u_demo');
      expect(result.isRight, isTrue);
      await result.fold(
        (f) => fail('expected success, got ${f.message}'),
        (user) async {
          expect(user.email, 'student@appex.dev');
          expect(user.displayName, 'Demo Student');
        },
      );
    });

    test('getById returns Left(NotFoundFailure) for unknown id', () async {
      final result = await repo.getUserById('u_nope');
      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (user) => fail('expected failure, got $user'),
      );
    });

    test('getCurrent returns Left when no user is signed in', () async {
      final result = await repo.getCurrentUser();
      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (user) => fail('expected failure, got $user'),
      );
    });

    test('after authenticate then getCurrent returns Right', () async {
      await dataSource.authenticate(
        email: 'student@appex.dev',
        password: 'password',
      );
      final result = await repo.getCurrentUser();
      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('expected success'),
        (user) => expect(user.email, 'student@appex.dev'),
      );
    });
  });
}
