class Exercise {
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

  const Exercise({
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

  Exercise copyWith({
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
    return Exercise(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}