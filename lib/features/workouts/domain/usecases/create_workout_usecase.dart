import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/workout.dart';
import '../repositories/workouts_repository.dart';

class CreateWorkoutUseCase {
  final WorkoutRepository repository;

  CreateWorkoutUseCase(this.repository);

  Future<Either<Failure, Workout>> call({
    required String userId,
    required String name,
    required WorkoutCategory category,
    required List<Map<String, dynamic>> exercises,
    bool isPublic = false,
  }) async {
    return await repository.createWorkout(
      userId: userId,
      name: name,
      category: category,
      exercises: exercises,
      isPublic: isPublic,
    );
  }
}