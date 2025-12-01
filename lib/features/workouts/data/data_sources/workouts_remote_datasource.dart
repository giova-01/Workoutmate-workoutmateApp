import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:workoutmate_app/features/workouts/data/models/exercise_model.dart';
import '../models/workout_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/api_constants.dart';

abstract class WorkoutRemoteDataSource {
  Future<WorkoutModel> createWorkout({
    required String userId,
    required String name,
    required String category,
    required List<Map<String, dynamic>> exercises,
    bool isPublic = false,
  });

  Future<List<WorkoutModel>> getUserWorkouts(String userId);

  Future<WorkoutModel> updateWorkout({
    required String workoutId,
    required String userId,
    String? name,
    String? category,
    List<Map<String, dynamic>>? exercises,
    bool? isPublic,
  });

  Future<void> deleteWorkout({
    required String workoutId,
    required String userId,
  });

  Future<List<WorkoutModel>> searchWorkouts({
    String? query,
    String? category,
    String? userId,
  });

  Future<Map<String, String>> generateShareLink({
    required String workoutId,
    required String userId,
  });

  /// Exercises
  Future<List<ExerciseModel>> getPredefinedExercises({
    String? muscleGroup,
    String? difficulty,
    String? equipment,
  });
}

class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSource {
  final Dio dio;

  WorkoutRemoteDataSourceImpl(this.dio);

  @override
  Future<WorkoutModel> createWorkout({
    required String userId,
    required String name,
    required String category,
    required List<Map<String, dynamic>> exercises,
    bool isPublic = false,
  }) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}/workouts/create',
        data: {
          'user_id': userId,
          'name': name,
          'category': category,
          'exercises': exercises,
          'is_public': isPublic,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return WorkoutModel.fromJson(response.data['workout']);
      }

      throw const ServerException('Error al crear rutina');
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 403) {
        throw const ServerException('Master Key inválida');
      }
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Error desconocido';
        throw ServerException(message);
      }

      throw const NetworkException('Error de conexión');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<List<WorkoutModel>> getUserWorkouts(String userId) async {
    try {
      debugPrint('[DataSource] Llamando a getUserWorkouts para userId: $userId');
      final response = await dio.get('${ApiConstants.baseUrl}/workouts/list_by_user/$userId');

      debugPrint('[DataSource] Status code: ${response.statusCode}');
      debugPrint('[DataSource] Response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data['workouts'] == null) {
          debugPrint('[DataSource] workouts es null, devolviendo lista vacía');
          return [];
        }

        final workoutsData = response.data['workouts'];
        if (workoutsData is! List) {
          debugPrint('[DataSource] workouts no es una lista: ${workoutsData.runtimeType}');
          return [];
        }

        if (workoutsData.isEmpty) {
          debugPrint('[DataSource] workouts es una lista vacía');
          return [];
        }

        debugPrint('[DataSource] Procesando ${workoutsData.length} workouts');

        final workouts = <WorkoutModel>[];
        for (var i = 0; i < workoutsData.length; i++) {
          try {
            final workoutJson = workoutsData[i];
            debugPrint('[DataSource] Procesando workout $i: $workoutJson');

            if (workoutJson['exercises'] is String) {
              try {
                final exercisesStr = workoutJson['exercises'] as String;
                if (exercisesStr.isNotEmpty && exercisesStr != 'null') {
                  workoutJson['exercises'] = (exercisesStr.startsWith('['))
                      ? exercisesStr
                      : '[]';
                } else {
                  workoutJson['exercises'] = [];
                }
              } catch (e) {
                debugPrint('[DataSource] Error parseando exercises string: $e');
                workoutJson['exercises'] = [];
              }
            }

            final workout = WorkoutModel.fromJson(workoutJson);
            workouts.add(workout);
            debugPrint('[DataSource] Workout $i procesado exitosamente');
          } catch (e) {
            debugPrint('[DataSource] Error procesando workout $i: $e');
          }
        }

        debugPrint('[DataSource] Total de workouts procesados: ${workouts.length}');
        return workouts;
      }

      throw const ServerException('Error al obtener rutinas');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      debugPrint('[DataSource] DioException: status=$status, message=${e.message}');

      if (status == 404) {
        final message = e.response?.data?['message']?.toString().toLowerCase();

        if (message != null && message.contains('usuario no existe')) {
          throw const ServerException('Usuario no encontrado');
        }

        return [];
      }

      throw const NetworkException('Error de conexión');
    } catch (e) {
      debugPrint('[DataSource] Error inesperado: $e');
      throw ServerException('Error inesperado: $e');
    }
  }


  @override
  Future<WorkoutModel> updateWorkout({
    required String workoutId,
    required String userId,
    String? name,
    String? category,
    List<Map<String, dynamic>>? exercises,
    bool? isPublic,
  }) async {
    try {
      final data = {
        'id': workoutId,
        'user_id': userId,
      };

      if (name != null) data['name'] = name;
      if (category != null) data['category'] = category;
      if (exercises != null) data['exercises'] = exercises as String;
      if (isPublic != null) data['is_public'] = isPublic as String;

      final response = await dio.put(
        '${ApiConstants.baseUrl}/workouts/update',
        data: data,
      );

      if (response.statusCode == 200) {
        return WorkoutModel.fromJson(response.data['workout']);
      }

      throw const ServerException('Error al actualizar rutina');
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 403) {
        throw const ServerException('Master Key inválida');
      }
      if (status == 404) {
        throw const ServerException('Rutina no encontrada');
      }

      throw const NetworkException('Error de conexión');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<void> deleteWorkout({
    required String workoutId,
    required String userId,
  }) async {
    try {
      final response = await dio.delete(
        '${ApiConstants.baseUrl}/workouts/delete/$workoutId',
        data: {'user_id': userId},
      );

      if (response.statusCode != 200) {
        throw const ServerException('Error al eliminar rutina');
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 403) {
        throw const ServerException('Master Key inválida');
      }
      if (status == 404) {
        throw const ServerException('Rutina no encontrada');
      }

      throw const NetworkException('Error de conexión');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<List<WorkoutModel>> searchWorkouts({
    String? query,
    String? category,
    String? userId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query != null) queryParams['query'] = query;
      if (category != null) queryParams['category'] = category;
      if (userId != null) queryParams['user_id'] = userId;

      final response = await dio.get(
        '${ApiConstants.baseUrl}/workouts/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final workouts = (response.data['workouts'] as List)
            .map((workout) => WorkoutModel.fromJson(workout))
            .toList();
        return workouts;
      }

      throw const ServerException('Error al buscar rutinas');
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 403) {
        throw const ServerException('Master Key inválida');
      }

      throw const NetworkException('Error de conexión');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<Map<String, String>> generateShareLink({
    required String workoutId,
    required String userId,
  }) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}/workouts/share',
        data: {
          'workout_id': workoutId,
          'user_id': userId,
        },
      );

      if (response.statusCode == 200) {
        return {
          'share_link': response.data['share_link'] as String,
          'full_url': response.data['full_url'] as String,
        };
      }

      throw const ServerException('Error al generar link');
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 403) {
        throw const ServerException('Master Key inválida');
      }
      if (status == 404) {
        throw const ServerException('Rutina no encontrada');
      }

      throw const NetworkException('Error de conexión');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  ///Exercises
  @override
  Future<List<ExerciseModel>> getPredefinedExercises({
    String? muscleGroup,
    String? difficulty,
    String? equipment,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (muscleGroup != null) queryParams['muscle_group'] = muscleGroup;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (equipment != null) queryParams['equipment'] = equipment;

      final response = await dio.get(
        '${ApiConstants.baseUrl}/exercises/list_predefined',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        // Backend returns: { success: true, exercises: [...] }
        final exercises = (response.data['exercises'] as List)
            .map((exercise) => ExerciseModel.fromJson(exercise))
            .toList();
        return exercises;
      }

      throw const ServerException('Error al obtener ejercicios');
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 403) {
        throw const ServerException('Master Key inválida');
      }
      if (e.response != null) {
        final message = e.response?.data['message'] ?? 'Error desconocido';
        throw ServerException(message);
      }

      throw const NetworkException('Error de conexión');
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }
}