import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

abstract class UserDataSource {
  Future<UserModel> getCurrent();
  Future<UserModel> getById(String id);
}

class MockUserDataSource implements UserDataSource {
  MockUserDataSource() {
    _seed();
  }

  final List<UserModel> _users = [];
  String? _currentUserId;

  void _seed() {
    _users.addAll(const [
      UserModel(
        id: 'u_demo',
        email: 'student@appex.dev',
        displayName: 'Demo Student',
      ),
      UserModel(
        id: 'u_admin',
        email: 'admin@appex.dev',
        displayName: 'Appex Admin',
      ),
    ]);
    _currentUserId = null; // nothing signed-in by default
  }

  @override
  Future<UserModel> getCurrent() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (_currentUserId == null) {
      throw const CacheException('No user is currently signed in.');
    }
    return _users.firstWhere((u) => u.id == _currentUserId);
  }

  @override
  Future<UserModel> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final found = _users.where((u) => u.id == id);
    if (found.isEmpty) {
      throw CacheException('User "$id" not found.');
    }
    return found.first;
  }

  /// Helpers used by `MockAuthRepository` (kept here because the user store is
  /// the source of truth for the demo app).
  Future<UserModel> authenticate({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final found = _users.where((u) => u.email == email.trim().toLowerCase());
    if (found.isEmpty) {
      throw const ServerException('No account with that email.');
    }
    if (password.length < 6) {
      throw const ValidationException('Password must be at least 6 characters.');
    }
    final user = found.first;
    _currentUserId = user.id;
    return user;
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final exists = _users.any(
      (u) => u.email == email.trim().toLowerCase(),
    );
    if (exists) {
      throw const ServerException('That email is already registered.');
    }
    if (password.length < 6) {
      throw const ValidationException('Password must be at least 6 characters.');
    }
    final created = UserModel(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      email: email.trim().toLowerCase(),
      displayName: displayName.trim(),
    );
    _users.add(created);
    _currentUserId = created.id;
    return created;
  }

  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _currentUserId = null;
  }
}

class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;
}
