import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/workout.dart';
import '../repositories/workouts_repository.dart';

class SearchWorkoutsUseCase {
  final WorkoutRepository repository;

  SearchWorkoutsUseCase(this.repository);

  Future<Either<Failure, List<Workout>>> call({
    String? query,
    String? category,
    String? userId,
  }) async {
    return await repository.searchWorkouts(
      query: query,
      category: category,
      userId: userId,
    );
  }
}