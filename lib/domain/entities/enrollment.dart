import 'package:equatable/equatable.dart';

class Enrollment extends Equatable {
  const Enrollment({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.enrolledAt,
    this.completedLessonIds = const [],
  });

  final String id;
  final String userId;
  final String courseId;
  final DateTime enrolledAt;
  final List<String> completedLessonIds;

  double get progress {
    if (completedLessonIds.isEmpty) return 0.0;
    return completedLessonIds.length / completedLessonIds.length.clamp(1, 9999);
  }

  @override
  List<Object?> get props =>
      [id, userId, courseId, enrolledAt, completedLessonIds];
}
