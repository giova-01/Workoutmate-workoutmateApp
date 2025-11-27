import 'exercise.dart';

enum WorkoutCategory {
  STRENGTH,
  CARDIO,
  FLEXIBILITY,
  FUNCTIONAL,
  MIXED,
}

class Workout {
  final String id;
  final String userId;
  final String name;
  final WorkoutCategory category;
  final List<Exercise> exercises;
  final bool isPublic;
  final String? shareLink;
  final String? qrCodePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Workout({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.exercises,
    required this.isPublic,
    this.shareLink,
    this.qrCodePath,
    required this.createdAt,
    required this.updatedAt,
  });

  Workout copyWith({
    String? id,
    String? userId,
    String? name,
    WorkoutCategory? category,
    List<Exercise>? exercises,
    bool? isPublic,
    String? shareLink,
    String? qrCodePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Workout(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      exercises: exercises ?? this.exercises,
      isPublic: isPublic ?? this.isPublic,
      shareLink: shareLink ?? this.shareLink,
      qrCodePath: qrCodePath ?? this.qrCodePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Workout && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}