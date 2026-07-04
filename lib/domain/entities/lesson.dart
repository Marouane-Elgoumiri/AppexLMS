import 'package:equatable/equatable.dart';

class Lesson extends Equatable {
  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.order,
    required this.durationSeconds,
  });

  final String id;
  final String courseId;
  final String title;
  final int order;
  final int durationSeconds;

  @override
  List<Object?> get props =>
      [id, courseId, title, order, durationSeconds];
}
