import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/workouts_repository.dart';

class GenerateShareLinkUseCase {
  final WorkoutRepository repository;

  GenerateShareLinkUseCase(this.repository);

  Future<Either<Failure, Map<String, String>>> call({
    required String workoutId,
    required String userId,
  }) async {
    return await repository.generateShareLink(
      workoutId: workoutId,
      userId: userId,
    );
  }
}