import 'package:appex/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel', () {
    test('fromJson produces a populated model (3.1)', () {
      final model = UserModel.fromJson(<String, dynamic>{
        'id': 42,
        'email': 'student@appex.dev',
        'display_name': 'Demo',
      });

      expect(model.id, '42');
      expect(model.email, 'student@appex.dev');
      expect(model.displayName, 'Demo');
    });

    test('falls back to email when display_name missing', () {
      final model = UserModel.fromJson(<String, dynamic>{
        'id': '1',
        'email': 'fallback@example.com',
      });
      expect(model.displayName, 'fallback@example.com');
    });

    test('round-trips through toJson', () {
      final model = UserModel.fromJson(<String, dynamic>{
        'id': 42,
        'email': 'student@appex.dev',
        'display_name': 'Demo',
      });
      final json = model.toJson();
      expect(json['id'], '42');
      expect(json['email'], 'student@appex.dev');
      expect(json['display_name'], 'Demo');
    });
  });
}
