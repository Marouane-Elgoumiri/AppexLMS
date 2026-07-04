import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'] as String,
      displayName: (json['display_name'] ?? json['name'] ?? json['email']) as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
      };

  User toEntity() => User(
        id: id,
        email: email,
        displayName: displayName,
      );
}
