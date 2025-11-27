import 'package:dartz/dartz.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/workouts_repository.dart';
import '../data_sources/workouts_remote_datasource.dart';


class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutRemoteDataSource remoteDataSource;

  WorkoutRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, Workout>> createWorkout({
    required String userId,
    required String name,
    required WorkoutCategory category,
    required List<Map<String, dynamic>> exercises,
    bool isPublic = false,
  }) async {
    try {
      final workoutModel = await remoteDataSource.createWorkout(
        userId: userId,
        name: name,
        category: category.name,
        exercises: exercises,
        isPublic: isPublic,
      );

      return Right(workoutModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('[WorkoutRepository] - Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Workout>>> getUserWorkouts(String userId) async {
    try {
      final workoutModels = await remoteDataSource.getUserWorkouts(userId);
      final workouts = workoutModels.map((model) => model.toEntity()).toList();
      return Right(workouts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('[WorkoutRepository] - Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Workout>> updateWorkout({
    required String workoutId,
    required String userId,
    String? name,
    WorkoutCategory? category,
    List<Map<String, dynamic>>? exercises,
    bool? isPublic,
  }) async {
    try {
      final workoutModel = await remoteDataSource.updateWorkout(
        workoutId: workoutId,
        userId: userId,
        name: name,
        category: category?.name,
        exercises: exercises,
        isPublic: isPublic,
      );

      return Right(workoutModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('[WorkoutRepository] - Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWorkout({
    required String workoutId,
    required String userId,
  }) async {
    try {
      await remoteDataSource.deleteWorkout(
        workoutId: workoutId,
        userId: userId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('[WorkoutRepository] - Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Workout>>> searchWorkouts({
    String? query,
    String? category,
    String? userId,
  }) async {
    try {
      final workoutModels = await remoteDataSource.searchWorkouts(
        query: query,
        category: category,
        userId: userId,
      );
      final workouts = workoutModels.map((model) => model.toEntity()).toList();
      return Right(workouts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('[WorkoutRepository] - Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> generateShareLink({
    required String workoutId,
    required String userId,
  }) async {
    try {
      final result = await remoteDataSource.generateShareLink(
        workoutId: workoutId,
        userId: userId,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('[WorkoutRepository] - Error inesperado: $e'));
    }
  }

  ///Exercises
  @override
  Future<Either<Failure, List<Exercise>>> getPredefinedExercises({
    String? muscleGroup,
    String? difficulty,
    String? equipment,
  }) async {
    try {
      final models = await remoteDataSource.getPredefinedExercises(
        muscleGroup: muscleGroup,
        difficulty: difficulty,
        equipment: equipment,
      );

      final exercises = models.map((model) => model.toEntity()).toList();
      return Right(exercises);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('[WorkoutRepository] - Error inesperado: $e'));
    }
  }
}