import 'package:appex/core/errors/exceptions.dart';
import 'package:appex/core/errors/failures.dart';
import 'package:appex/data/datasources/remote/number_trivia_remote_data_source.dart';
import 'package:appex/data/models/number_trivia_model.dart';
import 'package:appex/data/repositories/number_trivia_repository_impl.dart';
import 'package:appex/domain/entities/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRemote implements NumberTriviaRemoteDataSource {
  _FakeRemote({this.shouldThrow = false});
  final bool shouldThrow;

  @override
  Future<NumberTriviaModel> getConcreteNumber(int number) async {
    if (shouldThrow) {
      throw ServerException('boom');
    }
    return NumberTriviaModel(number: number, text: 'Trivia for $number');
  }

  @override
  Future<NumberTriviaModel> getRandom() async {
    if (shouldThrow) {
      throw ServerException('boom');
    }
    return const NumberTriviaModel(number: 13, text: 'Thirteen!');
  }
}

void main() {
  group('NumberTriviaRepositoryImpl', () {
    test('getConcreteNumber returns Right(entity) on success', () async {
      final fake = _FakeRemote();
      final repo = NumberTriviaRepositoryImpl(remote: fake);

      final result = await repo.getConcreteNumber(42);

      expect(result.isRight, isTrue);
      result.fold(
        (f) => fail('expected success, got $f'),
        (trv) {
          expect(trv, isA<NumberTrivia>());
          expect(trv.number, 42);
          expect(trv.text, 'Trivia for 42');
        },
      );
    });

    test('getConcreteNumber returns Left(ServerFailure) on error', () async {
      final fake = _FakeRemote(shouldThrow: true);
      final repo = NumberTriviaRepositoryImpl(remote: fake);

      final result = await repo.getConcreteNumber(7);

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'boom');
        },
        (trv) => fail('expected failure, got $trv'),
      );
    });

    test('getRandom returns Right(entity) on success', () async {
      final fake = _FakeRemote();
      final repo = NumberTriviaRepositoryImpl(remote: fake);

      final result = await repo.getRandom();

      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('expected success'),
        (trv) {
          expect(trv.number, 13);
          expect(trv.text, 'Thirteen!');
        },
      );
    });
  });
}
