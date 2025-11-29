import 'dart:convert';
import '../../domain/entities/exercise.dart';

class ExerciseModel {
  final String id;
  final String? workoutId;
  final String name;
  final String? category;
  final String? muscleGroup;
  final String? description;
  final String? difficulty;
  final String? equipment;
  final int? sets;
  final int? repetitions;
  final int? restTime;
  final int? orderIndex;

  ExerciseModel({
    required this.id,
    this.workoutId,
    required this.name,
    this.category,
    this.muscleGroup,
    this.description,
    this.difficulty,
    this.equipment,
    this.sets,
    this.repetitions,
    this.restTime,
    this.orderIndex,
  });

  factory ExerciseModel.fromEntity(Exercise exercise) {
    return ExerciseModel(
      id: exercise.id,
      workoutId: exercise.workoutId,
      name: exercise.name,
      category: exercise.category,
      muscleGroup: exercise.muscleGroup,
      description: exercise.description,
      difficulty: exercise.difficulty,
      equipment: exercise.equipment,
      sets: exercise.sets,
      repetitions: exercise.repetitions,
      restTime: exercise.restTime,
      orderIndex: exercise.orderIndex,
    );
  }

  Exercise toEntity() {
    return Exercise(
      id: id,
      workoutId: workoutId,
      name: name,
      category: category,
      muscleGroup: muscleGroup,
      description: description,
      difficulty: difficulty,
      equipment: equipment,
      sets: sets,
      repetitions: repetitions,
      restTime: restTime,
      orderIndex: orderIndex,
    );
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id']?.toString() ?? '',
      workoutId: json['workout_id']?.toString(),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString(),
      muscleGroup: json['muscle_group']?.toString(),
      description: json['description']?.toString(),
      difficulty: json['difficulty']?.toString(),
      equipment: json['equipment']?.toString(),
      sets: _parseInt(json['sets']),
      repetitions: _parseInt(json['repetitions']),
      restTime: _parseInt(json['rest_time']),
      orderIndex: _parseInt(json['order_index']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_id': workoutId,
      'name': name,
      'category': category,
      'muscle_group': muscleGroup,
      'description': description,
      'difficulty': difficulty,
      'equipment': equipment,
      'sets': sets,
      'repetitions': repetitions,
      'rest_time': restTime,
      'order_index': orderIndex,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory ExerciseModel.fromJsonString(String jsonString) {
    return ExerciseModel.fromJson(jsonDecode(jsonString));
  }

  ExerciseModel copyWith({
    String? id,
    String? workoutId,
    String? name,
    String? category,
    String? muscleGroup,
    String? description,
    String? difficulty,
    String? equipment,
    int? sets,
    int? repetitions,
    int? restTime,
    int? orderIndex,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      name: name ?? this.name,
      category: category ?? this.category,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      equipment: equipment ?? this.equipment,
      sets: sets ?? this.sets,
      repetitions: repetitions ?? this.repetitions,
      restTime: restTime ?? this.restTime,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}