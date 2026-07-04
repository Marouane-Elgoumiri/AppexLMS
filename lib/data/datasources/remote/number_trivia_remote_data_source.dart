import 'dart:math';

import '../../models/number_trivia_model.dart';

/// Contract for fetching [NumberTriviaModel]. Implementations may hit the
/// network or — when no reliable public endpoint exists — serve from a
/// bundled fact table. The repository and use cases above depend only on
/// this interface, so swapping impls is a one-line change in the binding.
abstract class NumberTriviaRemoteDataSource {
  Future<NumberTriviaModel> getConcreteNumber(int number);
  Future<NumberTriviaModel> getRandom();
}

/// Bundle-facts implementation.
///
/// Why a bundled table instead of an HTTP call:
///  - The original public host (numbersapi.com) is hijacked by a parking
///    page and returns 404 for every path as of 2024;
///  - other public mirrors are dead/parked/disabled;
///  - the only live variant of the original service (RapidAPI) requires
///    a per-app API key, which isn't appropriate for a learning sandbox.
///
/// Keeping the interface name `NumberTriviaRemoteDataSource` allows Sprint 4
/// to swap this impl for a Supabase/Dio-backed one without touching the
/// domain or presentation layers (Dependency Inversion in action).
class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  NumberTriviaRemoteDataSourceImpl({int? seed}) : _random = Random(seed);

  final Random _random;

  /// Simulated network latency so loading spinners / reactive state still get
  /// exercised by the demo UI.
  static const Duration _latency = Duration(milliseconds: 300);

  /// Curated facts keyed by number. Unknown numbers fall back to the
  /// generic pool below (with the number piped into the sentence).
  static const Map<int, String> _facts = {
    0: '0 is the smallest non-negative integer.',
    1: '1 is the multiplicative identity.',
    2: '2 is the only even prime number.',
    3: '3 is the smallest odd prime number.',
    4: '4 is the smallest composite number.',
    5: '5 is the number of fingers on one human hand.',
    6: '6 is the smallest perfect number (1 + 2 + 3).',
    7: '7 is widely considered a lucky number across cultures.',
    8: '8 is a cube of 2 and a Fibonacci number.',
    9: '9 is the largest single-digit decimal number.',
    10: '10 is the base of the decimal numeral system we use every day.',
    11: '11 is the smallest two-digit prime number.',
    12: '12 is the number of months in a year and hours on a clock face.',
    13: '13 is considered unlucky in many Western cultures (triskaidekaphobia).',
    21: '21 is the number of dots on a standard six-faced die.',
    23: '23 is the number of pairs of chromosomes in a human cell.',
    24: '24 is the number of hours in a day.',
    26: '26 is the number of letters in the English alphabet.',
    27: '27 is the age at which the famed "27 Club" musicians died.',
    36: '36 is the number of inches in a yard.',
    42: '42 is the answer to the ultimate question of life, the universe, and everything.',
    50: '50 is half a century.',
    60: '60 is the smallest number divisible by 1 through 6.',
    64: '64 is the number of squares on a standard chessboard.',
    100: '100 is the smallest three-digit integer in base 10.',
    101: '101 is the 26th prime and famously the introductory course number.',
    144: '144 is a gross and the 12th Fibonacci number.',
    365: '365 is the number of days in a non-leap year.',
    500: '500 is the number of points on a perfect Skee-Ball roll.',
    512: '512 is 2^9, one of the most common RAM capacities.',
    1000: '1000 is the smallest four-digit number and one kilo.',
  };

  /// Generic facts used when the user requests an unknown number. The
  /// caller's number is interpolated in parentheses at the end so the
  /// displayed text still mentions what they asked about.
  static const List<String> _genericFacts = [
    'is a number.',
    'is an integer between its neighbors on the number line.',
    'has no particularly famous property — but it is yours.',
    'is the count of words in a typical haiku (well, close enough).',
    'is a perfectly reasonable number to be curious about.',
    'factors uniquely into primes, like every integer does.',
    'is used somewhere in mathematics every single day.',
    'is part of the infinite lattice of integers.',
    'could be the number of coffee cups you drink per week.',
    'is even or odd — pick your favorite.',
  ];

  @override
  Future<NumberTriviaModel> getConcreteNumber(int number) async {
    await Future<void>.delayed(_latency);
    final known = _facts[number];
    final text = known ?? '$number ${_genericFacts[_random.nextInt(_genericFacts.length)]}';
    return NumberTriviaModel.fromRawText(number: number, rawBody: text);
  }

  @override
  Future<NumberTriviaModel> getRandom() async {
    await Future<void>.delayed(_latency);
    final n = _random.nextInt(1001); // 0..1000 inclusive
    final known = _facts[n];
    final text = known ?? '$n ${_genericFacts[_random.nextInt(_genericFacts.length)]}';
    return NumberTriviaModel.fromRawText(number: n, rawBody: text);
  }
}
