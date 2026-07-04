import '../../domain/entities/enrollment.dart';

class EnrollmentModel extends Enrollment {
  const EnrollmentModel({
    required super.id,
    required super.userId,
    required super.courseId,
    required super.enrolledAt,
    super.completedLessonIds = const [],
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    final rawCompleted = (json['completed_lesson_ids'] ?? const <dynamic>[])
        as List<dynamic>;
    return EnrollmentModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      courseId: json['course_id'].toString(),
      enrolledAt: DateTime.parse(json['enrolled_at'] as String),
      completedLessonIds:
          rawCompleted.map((e) => e.toString()).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'course_id': courseId,
        'enrolled_at': enrolledAt.toIso8601String(),
        'completed_lesson_ids': completedLessonIds,
      };

  Enrollment toEntity() => Enrollment(
        id: id,
        userId: userId,
        courseId: courseId,
        enrolledAt: enrolledAt,
        completedLessonIds: completedLessonIds,
      );
}
