import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/exercise.dart';
import '../repositories/workouts_repository.dart';

class GetPredefinedExercisesUseCase {
  final WorkoutRepository repository;

  GetPredefinedExercisesUseCase(this.repository);

  Future<Either<Failure, List<Exercise>>> call({
    String? muscleGroup,
    String? difficulty,
    String? equipment,
  }) async {
    return await repository.getPredefinedExercises(
      muscleGroup: muscleGroup,
      difficulty: difficulty,
      equipment: equipment,
    );
  }
}