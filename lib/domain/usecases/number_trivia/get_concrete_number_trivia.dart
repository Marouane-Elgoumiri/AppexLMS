import '../../../core/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/number_trivia.dart';
import '../../repositories/number_trivia_repository.dart';

class GetConcreteNumberTrivia {
  const GetConcreteNumberTrivia(this.repository);
  final NumberTriviaRepository repository;

  Future<Either<Failure, NumberTrivia>> call(String number) async {
    final parsed = int.tryParse(number.trim());
    if (parsed == null) {
      return const Left(
        ValidationFailure('Please enter a valid integer.'),
      );
    }
    return repository.getConcreteNumber(parsed);
  }
}
