import '../../domain/entities/course.dart';

class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.title,
    required super.instructor,
    required super.category,
    required super.lessonCount,
    super.imageUrl,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'].toString(),
      title: json['title'] as String,
      instructor: json['instructor'] as String,
      category: json['category'] as String? ?? 'General',
      lessonCount: (json['lesson_count'] ?? json['lessonCount'] ?? 0) as int,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'instructor': instructor,
        'category': category,
        'lesson_count': lessonCount,
        'image_url': imageUrl,
      };

  Course toEntity() => Course(
        id: id,
        title: title,
        instructor: instructor,
        category: category,
        lessonCount: lessonCount,
        imageUrl: imageUrl,
      );
}
