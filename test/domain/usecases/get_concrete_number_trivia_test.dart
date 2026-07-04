import 'package:appex/core/either.dart';
import 'package:appex/core/errors/failures.dart';
import 'package:appex/domain/entities/number_trivia.dart';
import 'package:appex/domain/repositories/number_trivia_repository.dart';
import 'package:appex/domain/usecases/number_trivia/get_concrete_number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepo implements NumberTriviaRepository {
  int? received;
  int fakeCalls = 0;

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumber(int number) async {
    fakeCalls++;
    received = number;
    return Right<Failure, NumberTrivia>(NumberTrivia(
      number: number,
      text: 'Mock trivia for $number',
    ));
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandom() async =>
      const Right<Failure, NumberTrivia>(NumberTrivia(
        number: 1,
        text: 'mock random',
      ));
}

void main() {
  group('GetConcreteNumberTrivia use case', () {
    test('valid integer input delegates to repository', () async {
      final repo = _FakeRepo();
      final useCase = GetConcreteNumberTrivia(repo);

      final result = await useCase('42');

      expect(repo.fakeCalls, 1);
      expect(repo.received, 42);
      expect(result.isRight, isTrue);
      result.fold(
        (f) => fail('expected success, got $f'),
        (trv) {
          expect(trv.number, 42);
          expect(trv.text, 'Mock trivia for 42');
        },
      );
    });

    test('non-numeric input returns Left(ValidationFailure)', () async {
      final repo = _FakeRepo();
      final useCase = GetConcreteNumberTrivia(repo);

      final result = await useCase('not a number');

      expect(repo.fakeCalls, 0);
      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (trv) => fail('expected failure, got $trv'),
      );
    });

    test('trims whitespace around the number', () async {
      final repo = _FakeRepo();
      final useCase = GetConcreteNumberTrivia(repo);

      final result = await useCase('  9 ');

      expect(repo.received, 9);
      expect(result.isRight, isTrue);
    });
  });
}
