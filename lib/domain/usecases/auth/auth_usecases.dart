import '../../../core/either.dart';
import '../../../core/errors/failures.dart';
import '../../../core/unit.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) {
    if (email.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Email cannot be empty.')),
      );
    }
    if (password.length < 6) {
      return Future.value(
        const Left(ValidationFailure('Password must be at least 6 characters.')),
      );
    }
    return repository.login(email: email.trim(), password: password);
  }
}

class RegisterUseCase {
  const RegisterUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    if (email.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Email cannot be empty.')),
      );
    }
    if (password.length < 6) {
      return Future.value(
        const Left(ValidationFailure('Password must be at least 6 characters.')),
      );
    }
    if (displayName.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Display name cannot be empty.')),
      );
    }
    return repository.register(
      email: email.trim(),
      password: password,
      displayName: displayName.trim(),
    );
  }
}

class LogoutUseCase {
  const LogoutUseCase(this.repository);
  final AuthRepository repository;

  Future<Either<Failure, Unit>> call() => repository.logout();
}
