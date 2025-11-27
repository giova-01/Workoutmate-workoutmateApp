import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/exercise.dart';
import '../entities/workout.dart';

abstract class WorkoutRepository {
  Future<Either<Failure, Workout>> createWorkout({
    required String userId,
    required String name,
    required WorkoutCategory category,
    required List<Map<String, dynamic>> exercises,
    bool isPublic = false,
  });

  Future<Either<Failure, List<Workout>>> getUserWorkouts(String userId);

  Future<Either<Failure, Workout>> updateWorkout({
    required String workoutId,
    required String userId,
    String? name,
    WorkoutCategory? category,
    List<Map<String, dynamic>>? exercises,
    bool? isPublic,
  });

  Future<Either<Failure, void>> deleteWorkout({
    required String workoutId,
    required String userId,
  });

  Future<Either<Failure, List<Workout>>> searchWorkouts({
    String? query,
    String? category,
    String? userId,
  });

  Future<Either<Failure, Map<String, String>>> generateShareLink({
    required String workoutId,
    required String userId,
  });

  ///Exercises
  Future<Either<Failure, List<Exercise>>> getPredefinedExercises({
    String? muscleGroup,
    String? difficulty,
    String? equipment,
  });
}