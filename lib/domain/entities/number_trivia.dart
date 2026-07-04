import 'package:equatable/equatable.dart';

class NumberTrivia extends Equatable {
  const NumberTrivia({
    required this.number,
    required this.text,
  });

  final int number;
  final String text;

  @override
  List<Object?> get props => [number, text];
}
