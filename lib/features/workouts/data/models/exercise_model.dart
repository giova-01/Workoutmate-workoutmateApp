import 'dart:convert';
import '../../domain/entities/exercise.dart';

class ExerciseModel {
  final String id;
  final String workoutId;
  final String name;
  final int sets;
  final int repetitions;
  final int restTime;
  final String? notes;
  final int orderIndex;

  ExerciseModel({
    required this.id,
    required this.workoutId,
    required this.name,
    required this.sets,
    required this.repetitions,
    required this.restTime,
    this.notes,
    required this.orderIndex,
  });

  factory ExerciseModel.fromEntity(Exercise exercise) {
    return ExerciseModel(
      id: exercise.id,
      workoutId: exercise.workoutId,
      name: exercise.name,
      sets: exercise.sets,
      repetitions: exercise.repetitions,
      restTime: exercise.restTime,
      notes: exercise.notes,
      orderIndex: exercise.orderIndex,
    );
  }

  Exercise toEntity() {
    return Exercise(
      id: id,
      workoutId: workoutId,
      name: name,
      sets: sets,
      repetitions: repetitions,
      restTime: restTime,
      notes: notes,
      orderIndex: orderIndex,
    );
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      workoutId: json['workout_id'] as String? ?? '',
      name: json['name'] as String,
      sets: json['sets'] as int,
      repetitions: json['repetitions'] as int,
      restTime: json['rest_time'] as int,
      notes: json['notes'] as String?,
      orderIndex: json['order_index'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workout_id': workoutId,
      'name': name,
      'sets': sets,
      'repetitions': repetitions,
      'rest_time': restTime,
      'notes': notes,
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
    int? sets,
    int? repetitions,
    int? restTime,
    String? notes,
    int? orderIndex,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      repetitions: repetitions ?? this.repetitions,
      restTime: restTime ?? this.restTime,
      notes: notes ?? this.notes,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}