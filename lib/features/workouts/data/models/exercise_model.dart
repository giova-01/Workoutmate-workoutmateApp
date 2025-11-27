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
    required this.workoutId,
    required this.name,
    required this.category,
    required this.muscleGroup,
    required this.description,
    required this.difficulty,
    required this.equipment,
    required this.sets,
    required this.repetitions,
    required this.restTime,
    required this.orderIndex
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
      id: json['id'] as String? ?? '',
      workoutId: json['workout_id'] as String?,
      name: json['name'] as String? ?? '',
      category: json['category'] as String?,
      muscleGroup: json['muscle_group'] as String?,
      description: json['description'] as String?,
      difficulty: json['difficulty'] as String?,
      equipment: json['equipment'] as String?,
      sets: json['sets'] as int?,
      repetitions: json['repetitions'] as int?,
      restTime: json['rest_time'] as int?,
      orderIndex: json['order_index'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_id': workoutId,
      'name': name,
      'category': category,
      'muscleGroup': muscleGroup,
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
      equipment:equipment ?? this.equipment,
      sets: sets ?? this.sets,
      repetitions: repetitions ?? this.repetitions,
      restTime: restTime ?? this.restTime,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}