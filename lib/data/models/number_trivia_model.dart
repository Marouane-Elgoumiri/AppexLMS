import '../../domain/entities/number_trivia.dart';

class NumberTriviaModel extends NumberTrivia {
  const NumberTriviaModel({
    required super.number,
    required super.text,
  });

  /// Parses a numbersapi.com response. The plain trivia endpoint returns the
  /// text body as just a string (e.g. `"42 is the meaning of life."`), not
  /// JSON. We treat the raw response as the text and reuse the parsed `number`
  /// we sent up.
  factory NumberTriviaModel.fromRawText({
    required int number,
    required String rawBody,
  }) {
    return NumberTriviaModel(number: number, text: rawBody.trim());
  }

  factory NumberTriviaModel.fromJson(Map<String, dynamic> json) {
    return NumberTriviaModel(
      number: json['number'] as int,
      text: json['text'] as String,
    );
  }

  NumberTrivia toEntity() => NumberTrivia(number: number, text: text);
}
