import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workoutmate_app/features/workouts/domain/usecases/get_predefined_exercises_usecase.dart';
import 'package:workoutmate_app/features/workouts/presentation/pages/workouts_state.dart';
import '../domain/entities/workout.dart';
import '../domain/usecases/create_workout_usecase.dart';
import '../domain/usecases/get_user_workouts_usecase.dart';
import '../domain/usecases/update_workout_usecase.dart';
import '../domain/usecases/delete_workout_usecase.dart';
import '../domain/usecases/search_workout_usecase.dart';
import '../domain/usecases/generate_share_link_usecase.dart';


class WorkoutNotifier extends StateNotifier<WorkoutState> {
  final CreateWorkoutUseCase _createWorkoutUseCase;
  final GetUserWorkoutsUseCase _getUserWorkoutsUseCase;
  final UpdateWorkoutUseCase _updateWorkoutUseCase;
  final DeleteWorkoutUseCase _deleteWorkoutUseCase;
  final SearchWorkoutsUseCase _searchWorkoutsUseCase;
  final GenerateShareLinkUseCase _generateShareLinkUseCase;
  final GetPredefinedExercisesUseCase _getPredefinedExercisesUseCase;

  WorkoutNotifier({
    required CreateWorkoutUseCase createWorkoutUseCase,
    required GetUserWorkoutsUseCase getUserWorkoutsUseCase,
    required UpdateWorkoutUseCase updateWorkoutUseCase,
    required DeleteWorkoutUseCase deleteWorkoutUseCase,
    required SearchWorkoutsUseCase searchWorkoutsUseCase,
    required GenerateShareLinkUseCase generateShareLinkUseCase,
    required GetPredefinedExercisesUseCase getPredefinedExercisesUseCase,
  })  : _createWorkoutUseCase = createWorkoutUseCase,
        _getUserWorkoutsUseCase = getUserWorkoutsUseCase,
        _updateWorkoutUseCase = updateWorkoutUseCase,
        _deleteWorkoutUseCase = deleteWorkoutUseCase,
        _searchWorkoutsUseCase = searchWorkoutsUseCase,
        _generateShareLinkUseCase = generateShareLinkUseCase,
        _getPredefinedExercisesUseCase = getPredefinedExercisesUseCase,
        super(const WorkoutInitial());

  Future<void> loadUserWorkouts(String userId) async {
    state = const WorkoutLoading();

    final result = await _getUserWorkoutsUseCase(userId);

    result.fold(
          (failure) => state = WorkoutError(failure.message),
          (workouts) => state = WorkoutsLoaded(workouts),
    );
  }

  Future<void> createWorkout({
    required String userId,
    required String name,
    required WorkoutCategory category,
    required List<Map<String, dynamic>> exercises,
    bool isPublic = false,
  }) async {
    state = const WorkoutLoading();

    final result = await _createWorkoutUseCase(
      userId: userId,
      name: name,
      category: category,
      exercises: exercises,
      isPublic: isPublic,
    );

    result.fold(
          (failure) => state = WorkoutError(failure.message),
          (workout) async {
        // Recargar la lista de workouts
        await loadUserWorkouts(userId);
      },
    );
  }

  Future<void> updateWorkout({
    required String workoutId,
    required String userId,
    String? name,
    WorkoutCategory? category,
    List<Map<String, dynamic>>? exercises,
    bool? isPublic,
  }) async {
    state = const WorkoutLoading();

    final result = await _updateWorkoutUseCase(
      workoutId: workoutId,
      userId: userId,
      name: name,
      category: category,
      exercises: exercises,
      isPublic: isPublic,
    );

    result.fold(
          (failure) => state = WorkoutError(failure.message),
          (workout) async {
        // Recargar la lista de workouts
        await loadUserWorkouts(userId);
      },
    );
  }

  Future<void> deleteWorkout({
    required String workoutId,
    required String userId,
  }) async {
    state = const WorkoutLoading();

    final result = await _deleteWorkoutUseCase(
      workoutId: workoutId,
      userId: userId,
    );

    result.fold(
          (failure) => state = WorkoutError(failure.message),
          (_) async {
        // Recargar la lista de workouts
        await loadUserWorkouts(userId);
      },
    );
  }

  Future<void> searchWorkouts({
    String? query,
    String? category,
    String? userId,
  }) async {
    state = const WorkoutLoading();

    final result = await _searchWorkoutsUseCase(
      query: query,
      category: category,
      userId: userId,
    );

    result.fold(
          (failure) => state = WorkoutError(failure.message),
          (workouts) => state = WorkoutsLoaded(workouts),
    );
  }

  Future<void> generateShareLink({
    required String workoutId,
    required String userId,
  }) async {
    state = const WorkoutLoading();

    final result = await _generateShareLinkUseCase(
      workoutId: workoutId,
      userId: userId,
    );

    result.fold(
          (failure) => state = WorkoutError(failure.message),
          (data) => state = WorkoutShareLinkGenerated(
        shareLink: data['share_link']!,
        fullUrl: data['full_url']!,
      ),
    );
  }

  Future<void> loadPredefinedExercises({
    String? muscleGroup,
    String? difficulty,
    String? equipment,
  }) async {
    state = const WorkoutLoading();

    final result = await _getPredefinedExercisesUseCase(
      muscleGroup: muscleGroup,
      difficulty: difficulty,
      equipment: equipment,
    );

    result.fold(
          (failure) => state = WorkoutError(failure.message),
          (exercises) => state = PredefinedExercisesLoaded(exercises),
    );
  }
}