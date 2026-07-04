import '../../domain/entities/lesson.dart';

class LessonModel extends Lesson {
  const LessonModel({
    required super.id,
    required super.courseId,
    required super.title,
    required super.order,
    required super.durationSeconds,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'].toString(),
      courseId: json['course_id'].toString(),
      title: json['title'] as String,
      order: json['order'] as int,
      durationSeconds: (json['duration_seconds'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_id': courseId,
        'title': title,
        'order': order,
        'duration_seconds': durationSeconds,
      };

  Lesson toEntity() => Lesson(
        id: id,
        courseId: courseId,
        title: title,
        order: order,
        durationSeconds: durationSeconds,
      );
}
