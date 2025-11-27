import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/workout.dart';
import '../repositories/workouts_repository.dart';

class GetUserWorkoutsUseCase {
  final WorkoutRepository repository;

  GetUserWorkoutsUseCase(this.repository);

  Future<Either<Failure, List<Workout>>> call(String userId) async {
    return await repository.getUserWorkouts(userId);
  }
}