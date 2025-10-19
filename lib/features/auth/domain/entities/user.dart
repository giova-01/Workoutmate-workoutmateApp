class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.role == role;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    email.hashCode ^
    firstName.hashCode ^
    lastName.hashCode ^
    role.hashCode;
  }
}