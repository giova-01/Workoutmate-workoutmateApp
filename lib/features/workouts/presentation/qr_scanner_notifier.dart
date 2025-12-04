import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../domain/entities/workout.dart';
import '../data/models/workout_model.dart';

/// Notifier separado SOLO para funcionalidad de QR Scanner
/// No afecta al WorkoutNotifier existente
class QrScannerNotifier extends StateNotifier<QrScannerState> {
  final Dio _dio;

  QrScannerNotifier(this._dio) : super(const QrScannerInitial());

  Future<Workout?> getWorkoutByShareLink(String shareLink) async {
    try {
      state = const QrScannerLoading();

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/workouts/get_by_share_link/$shareLink',
      );

      if (response.statusCode == 200 && response.data['workout'] != null) {
        final workoutModel = WorkoutModel.fromJson(response.data['workout']);
        final workout = workoutModel.toEntity();
        state = QrScannerWorkoutLoaded(workout);
        return workout;
      }

      state = const QrScannerError('Rutina no encontrada');
      return null;
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Error de conexión';
      state = QrScannerError(message);
      return null;
    } catch (e) {
      state = QrScannerError('Error: $e');
      return null;
    }
  }

  Future<bool> cloneWorkout(String shareLink, String userId) async {
    try {
      state = const QrScannerLoading();

      final response = await _dio.post(
        '${ApiConstants.baseUrl}/workouts/clone',
        data: {
          'share_link': shareLink,
          'user_id': userId,
        },
      );

      if (response.statusCode == 200) {
        state = const QrScannerSuccess('Rutina guardada exitosamente');
        return true;
      }

      state = const QrScannerError('Error al guardar');
      return false;
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Error de conexión';
      state = QrScannerError(message);
      return false;
    } catch (e) {
      state = QrScannerError('Error: $e');
      return false;
    }
  }

  void reset() {
    state = const QrScannerInitial();
  }
}

// Estados separados para QR Scanner
abstract class QrScannerState {
  const QrScannerState();
}

class QrScannerInitial extends QrScannerState {
  const QrScannerInitial();
}

class QrScannerLoading extends QrScannerState {
  const QrScannerLoading();
}

class QrScannerWorkoutLoaded extends QrScannerState {
  final Workout workout;
  const QrScannerWorkoutLoaded(this.workout);
}

class QrScannerSuccess extends QrScannerState {
  final String message;
  const QrScannerSuccess(this.message);
}

class QrScannerError extends QrScannerState {
  final String message;
  const QrScannerError(this.message);
}