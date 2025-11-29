import 'dart:convert';
import '../../domain/entities/workout.dart';
import 'exercise_model.dart';

class WorkoutModel {
  final String id;
  final String userId;
  final String name;
  final String category;
  final List<ExerciseModel> exercises;
  final bool isPublic;
  final String? shareLink;
  final String? qrCodePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkoutModel({
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

  factory WorkoutModel.fromEntity(Workout workout) {
    return WorkoutModel(
      id: workout.id,
      userId: workout.userId,
      name: workout.name,
      category: workout.category.name,
      exercises: workout.exercises
          .map((e) => ExerciseModel.fromEntity(e))
          .toList(),
      isPublic: workout.isPublic,
      shareLink: workout.shareLink,
      qrCodePath: workout.qrCodePath,
      createdAt: workout.createdAt,
      updatedAt: workout.updatedAt,
    );
  }

  Workout toEntity() {
    return Workout(
      id: id,
      userId: userId,
      name: name,
      category: WorkoutCategory.values.firstWhere(
            (e) => e.name == category,
        orElse: () => WorkoutCategory.MIXED,
      ),
      exercises: exercises.map((e) => e.toEntity()).toList(),
      isPublic: isPublic,
      shareLink: shareLink,
      qrCodePath: qrCodePath,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    List<ExerciseModel> exercises = [];

    try {
      if (json['exercises'] != null) {
        if (json['exercises'] is String) {
          // Si es un string, intentar parsearlo como JSON
          final exercisesStr = json['exercises'] as String;
          if (exercisesStr.isNotEmpty && exercisesStr != 'null') {
            try {
              final decoded = jsonDecode(exercisesStr);
              if (decoded is List) {
                for (var item in decoded) {
                  try {
                    exercises.add(ExerciseModel.fromJson(item as Map<String, dynamic>));
                  } catch (e) {
                    // Saltar ejercicios mal formados
                    continue;
                  }
                }
              }
            } catch (e) {
              // Si falla el parseo del JSON, dejar lista vacía
              exercises = [];
            }
          }
        } else if (json['exercises'] is List) {
          // Si ya es una lista, procesarla directamente
          final exercisesList = json['exercises'] as List;
          for (var item in exercisesList) {
            try {
              exercises.add(ExerciseModel.fromJson(item as Map<String, dynamic>));
            } catch (e) {
              // Saltar ejercicios mal formados
              continue;
            }
          }
        }
      }
    } catch (e) {
      // Cualquier error, dejar lista vacía
      exercises = [];
    }

    return WorkoutModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      exercises: exercises,
      isPublic: json['is_public'] == 1 || json['is_public'] == true,
      shareLink: json['share_link'],
      qrCodePath: json['qr_code_path'],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'is_public': isPublic,
      'share_link': shareLink,
      'qr_code_path': qrCodePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory WorkoutModel.fromJsonString(String jsonString) {
    return WorkoutModel.fromJson(jsonDecode(jsonString));
  }

  WorkoutModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    List<ExerciseModel>? exercises,
    bool? isPublic,
    String? shareLink,
    String? qrCodePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutModel(
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
}