import 'package:appex/core/errors/exceptions.dart';
import 'package:appex/core/errors/failures.dart';
import 'package:appex/data/datasources/mock/mock_user_data_source.dart'
    show UserDataSource;
import 'package:appex/data/models/user_model.dart';
import 'package:appex/data/repositories/supabase/supabase_user_repository_impl.dart';
import 'package:appex/domain/repositories/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeUserDataSource implements UserDataSource {
  FakeUserDataSource({
    this.current,
    this.byId,
    this.throwOnCurrent = false,
    this.throwOnById = false,
  });

  UserModel? current;
  UserModel? byId;
  bool throwOnCurrent;
  bool throwOnById;

  @override
  Future<UserModel> getCurrent() async {
    if (throwOnCurrent) throw const CacheException('not signed in');
    return current!;
  }

  @override
  Future<UserModel> getById(String _) async {
    if (throwOnById) throw const CacheException('user not found');
    return byId!;
  }
}

UserModel _u(String id) => UserModel(
      id: id,
      email: '$id@appex.dev',
      displayName: 'User $id',
    );

void main() {
  late FakeUserDataSource ds;
  late UserRepository repo;

  setUp(() {
    ds = FakeUserDataSource();
    repo = SupabaseUserRepositoryImpl(dataSource: ds);
  });

  group('SupabaseUserRepositoryImpl (4a.1–4a.3)', () {
    test('getCurrentUser → Right(User) on success', () async {
      ds.current = _u('u_demo');

      final result = await repo.getCurrentUser();

      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('expected success'),
        (u) {
          expect(u.id, 'u_demo');
          expect(u.email, 'u_demo@appex.dev');
        },
      );
    });

    test('getCurrentUser signed-out → Left(UnauthenticatedFailure)', () async {
      ds.throwOnCurrent = true;

      final result = await repo.getCurrentUser();

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<UnauthenticatedFailure>()),
        (_) => fail('expected failure'),
      );
    });

    test('getUserById → Right(User) on success', () async {
      ds.byId = _u('u_target');

      final result = await repo.getUserById('u_target');

      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('expected success'),
        (u) => expect(u.id, 'u_target'),
      );
    });

    test('getUserById not-found → Left(NotFoundFailure)', () async {
      ds.throwOnById = true;

      final result = await repo.getUserById('nope');

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('expected failure'),
      );
    });
  });
}
