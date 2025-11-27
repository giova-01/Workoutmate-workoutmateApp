import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';

abstract class WorkoutState {
  const WorkoutState();
}

class WorkoutInitial extends WorkoutState {
  const WorkoutInitial();
}

class WorkoutLoading extends WorkoutState {
  const WorkoutLoading();
}

class WorkoutsLoaded extends WorkoutState {
  final List<Workout> workouts;

  const WorkoutsLoaded(this.workouts);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutsLoaded && other.workouts == workouts;
  }

  @override
  int get hashCode => workouts.hashCode;
}

class WorkoutError extends WorkoutState {
  final String message;

  const WorkoutError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class WorkoutShareLinkGenerated extends WorkoutState {
  final String shareLink;
  final String fullUrl;

  const WorkoutShareLinkGenerated({
    required this.shareLink,
    required this.fullUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutShareLinkGenerated &&
        other.shareLink == shareLink &&
        other.fullUrl == fullUrl;
  }

  @override
  int get hashCode => shareLink.hashCode ^ fullUrl.hashCode;
}

class PredefinedExercisesLoaded extends WorkoutState {
  final List<Exercise> exercises;

  const PredefinedExercisesLoaded(this.exercises);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PredefinedExercisesLoaded && other.exercises == exercises;
  }

  @override
  int get hashCode => exercises.hashCode;
}