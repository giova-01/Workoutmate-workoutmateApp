import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/workouts_repository.dart';

class DeleteWorkoutUseCase {
  final WorkoutRepository repository;

  DeleteWorkoutUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String workoutId,
    required String userId,
  }) async {
    return await repository.deleteWorkout(
      workoutId: workoutId,
      userId: userId,
    );
  }
}