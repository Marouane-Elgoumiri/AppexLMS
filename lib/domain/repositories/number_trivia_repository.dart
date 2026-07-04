import '../../core/either.dart';
import '../../core/errors/failures.dart';
import '../entities/number_trivia.dart';

abstract class NumberTriviaRepository {
  Future<Either<Failure, NumberTrivia>> getConcreteNumber(int number);
  Future<Either<Failure, NumberTrivia>> getRandom();
}
