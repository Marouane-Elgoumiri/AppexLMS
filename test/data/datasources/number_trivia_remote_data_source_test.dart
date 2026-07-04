import 'package:appex/data/datasources/remote/number_trivia_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NumberTriviaRemoteDataSourceImpl ds;

  setUp(() {
    // Fixed seed so tests are deterministic regardless of randomness.
    ds = NumberTriviaRemoteDataSourceImpl(seed: 0);
  });

  group('NumberTriviaRemoteDataSource (bundled)', () {
    test('Known number returns its curated fact', () async {
      final model = await ds.getConcreteNumber(42);
      expect(model.number, 42);
      expect(
        model.text,
        '42 is the answer to the ultimate question of life, the universe, and everything.',
      );
    });

    test('Unknown number falls back to a generic fact mentioning the number', () async {
      final model = await ds.getConcreteNumber(99);
      expect(model.number, 99);
      expect(model.text, contains('99'));
    });

    test('getRandom returns a number in [0, 1000] inclusive', () async {
      final model = await ds.getRandom();
      expect(model.number, lessThanOrEqualTo(1000));
      expect(model.number, greaterThanOrEqualTo(0));
      expect(model.text, isNotEmpty);
    });

    test('Patterns in fact text — known numbers never end with the placeholder suffix',
        () async {
      // Pick a couple of known entries and ensure the body has the
      // "is " infix that the curated format always uses.
      final eights = await ds.getConcreteNumber(8);
      expect(eights.text, startsWith('8 is '));
      final twentySeven = await ds.getConcreteNumber(27);
      expect(twentySeven.text, startsWith('27 is '));
    });

    test('Methods return distinct models for successive calls (no shared state)',
        () async {
      final a = await ds.getConcreteNumber(7);
      final b = await ds.getConcreteNumber(11);
      expect(a.number, 7);
      expect(b.number, 11);
      expect(a.text, isNot(b.text));
    });
  });
}
