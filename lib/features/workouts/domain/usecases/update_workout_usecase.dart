import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/workout.dart';
import '../repositories/workouts_repository.dart';

class UpdateWorkoutUseCase {
  final WorkoutRepository repository;

  UpdateWorkoutUseCase(this.repository);

  Future<Either<Failure, Workout>> call({
    required String workoutId,
    required String userId,
    String? name,
    WorkoutCategory? category,
    List<Map<String, dynamic>>? exercises,
    bool? isPublic,
  }) async {
    return await repository.updateWorkout(
      workoutId: workoutId,
      userId: userId,
      name: name,
      category: category,
      exercises: exercises,
      isPublic: isPublic,
    );
  }
}