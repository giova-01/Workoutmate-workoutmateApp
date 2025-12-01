import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/workout.dart';

class WorkoutCompletedDialog extends StatelessWidget {
  final Workout workout;
  final int elapsedSeconds;

  const WorkoutCompletedDialog({
    super.key,
    required this.workout,
    required this.elapsedSeconds,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total sets
    final totalSets = workout.exercises.fold<int>(
      0,(sum, exercise) => sum + (exercise.sets ?? 0),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    '¡Rutina Completada!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      size: 64,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 20,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tiempo total de descanso',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTime(elapsedSeconds),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Workout summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCompletionStat(
                        icon: Icons.fitness_center,
                        value: '${workout.exercises.length}',
                        label: 'Ejercicios',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      _buildCompletionStat(
                        icon: Icons.repeat,
                        value: '$totalSets',
                        label: 'Series',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Footer button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Finalizar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[700]),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  // Static method to show the dialog
  static Future<void> show(
    BuildContext context,
    Workout workout,
    int elapsedSeconds,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WorkoutCompletedDialog(
        workout: workout,
        elapsedSeconds: elapsedSeconds,
      ),
    );
  }
}
