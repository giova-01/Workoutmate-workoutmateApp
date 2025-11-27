class Exercise {
  final String id;
  final String workoutId;
  final String name;
  final int sets;
  final int repetitions;
  final int restTime;
  final String? notes;
  final int orderIndex;

  const Exercise({
    required this.id,
    required this.workoutId,
    required this.name,
    required this.sets,
    required this.repetitions,
    required this.restTime,
    this.notes,
    required this.orderIndex,
  });

  Exercise copyWith({
    String? id,
    String? workoutId,
    String? name,
    int? sets,
    int? repetitions,
    int? restTime,
    String? notes,
    int? orderIndex,
  }) {
    return Exercise(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Exercise && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}