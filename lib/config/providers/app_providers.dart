import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/dio_client.dart';
import '../../features/auth/data/data_sources/auth_local_datasource.dart';
import '../../features/auth/data/data_sources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/auth_notifier.dart';
import '../../features/auth/presentation/auth_state.dart';
import '../../features/workouts/data/data_sources/workouts_remote_datasource.dart';
import '../../features/workouts/data/repositories/workouts_repository_impl.dart';
import '../../features/workouts/domain/repositories/workouts_repository.dart';
import '../../features/workouts/domain/usecases/create_workout_usecase.dart';
import '../../features/workouts/domain/usecases/delete_workout_usecase.dart';
import '../../features/workouts/domain/usecases/generate_share_link_usecase.dart';
import '../../features/workouts/domain/usecases/get_predefined_exercises_usecase.dart';
import '../../features/workouts/domain/usecases/get_user_workouts_usecase.dart';
import '../../features/workouts/domain/usecases/search_workout_usecase.dart';
import '../../features/workouts/domain/usecases/update_workout_usecase.dart';
import '../../features/workouts/presentation/pages/workouts_state.dart';
import '../../features/workouts/presentation/workouts_notifier.dart';

// Secure Storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Dio Client
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// ========== AUTH ========== ///

// Data Sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return AuthRemoteDataSourceImpl(dio);
});
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthLocalDataSourceImpl(storage);
});

//Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

// Auth Use cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});
final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

// Auth Notifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
  );
});

/// ========== WORKOUTS ========== ///

// Workout Data Sources
final workoutRemoteDataSourceProvider = Provider<WorkoutRemoteDataSource>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return WorkoutRemoteDataSourceImpl(dio);
});

// Workout Repository
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final remoteDataSource = ref.watch(workoutRemoteDataSourceProvider);
  return WorkoutRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Workout Use Cases
final createWorkoutUseCaseProvider = Provider<CreateWorkoutUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return CreateWorkoutUseCase(repository);
});
final getUserWorkoutsUseCaseProvider = Provider<GetUserWorkoutsUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return GetUserWorkoutsUseCase(repository);
});
final updateWorkoutUseCaseProvider = Provider<UpdateWorkoutUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return UpdateWorkoutUseCase(repository);
});
final deleteWorkoutUseCaseProvider = Provider<DeleteWorkoutUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return DeleteWorkoutUseCase(repository);
});
final searchWorkoutsUseCaseProvider = Provider<SearchWorkoutsUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return SearchWorkoutsUseCase(repository);
});
final generateShareLinkUseCaseProvider = Provider<GenerateShareLinkUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return GenerateShareLinkUseCase(repository);
});
final getPredefinedExercisesUseCaseProvider = Provider<GetPredefinedExercisesUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return GetPredefinedExercisesUseCase(repository);
});

// Workout Notifier Provider
final workoutNotifierProvider = StateNotifierProvider<WorkoutNotifier, WorkoutState>((ref) {
  return WorkoutNotifier(
    createWorkoutUseCase: ref.watch(createWorkoutUseCaseProvider),
    getUserWorkoutsUseCase: ref.watch(getUserWorkoutsUseCaseProvider),
    updateWorkoutUseCase: ref.watch(updateWorkoutUseCaseProvider),
    deleteWorkoutUseCase: ref.watch(deleteWorkoutUseCaseProvider),
    searchWorkoutsUseCase: ref.watch(searchWorkoutsUseCaseProvider),
    generateShareLinkUseCase: ref.watch(generateShareLinkUseCaseProvider),
    getPredefinedExercisesUseCase: ref.watch(getPredefinedExercisesUseCaseProvider),
  );
});