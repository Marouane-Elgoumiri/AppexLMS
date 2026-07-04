import '../../../core/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/number_trivia.dart';
import '../../repositories/number_trivia_repository.dart';

class GetRandomNumberTrivia {
  const GetRandomNumberTrivia(this.repository);
  final NumberTriviaRepository repository;

  Future<Either<Failure, NumberTrivia>> call() => repository.getRandom();
}
