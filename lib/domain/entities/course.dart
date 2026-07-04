import 'package:equatable/equatable.dart';

class Course extends Equatable {
  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.category,
    required this.lessonCount,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String instructor;
  final String category;
  final int lessonCount;
  final String? imageUrl;

  @override
  List<Object?> get props =>
      [id, title, instructor, category, lessonCount, imageUrl];
}
