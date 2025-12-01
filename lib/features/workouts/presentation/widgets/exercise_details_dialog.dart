import 'package:flutter/material.dart';

class ExerciseDetailsDialog extends StatelessWidget {
  final dynamic exercise;

  const ExerciseDetailsDialog({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise.name ?? 'Ejercicio',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content with scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Difficulty
                    _buildDetailRow(
                      icon: Icons.bar_chart_rounded,
                      label: 'Dificultad',
                      value: _getDifficultyName(exercise.difficulty),
                      valueColor: _getDifficultyColor(exercise.difficulty),
                    ),

                    const SizedBox(height: 16),

                    // Muscle Group
                    _buildDetailRow(
                      icon: Icons.accessibility_new,
                      label: 'Grupo Muscular',
                      value: exercise.muscleGroup ?? 'No especificado',
                    ),

                    const SizedBox(height: 16),

                    // Equipment
                    _buildDetailRow(
                      icon: Icons.fitness_center,
                      label: 'Equipamiento',
                      value: exercise.equipment ?? 'No especificado',
                    ),

                    const SizedBox(height: 24),

                    // Description section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 20,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Descripción',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            exercise.description ?? 'Sin descripción disponible',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getDifficultyName(String? difficulty) {
    if (difficulty == null) return 'No especificada';
    return switch (difficulty.toUpperCase()) {
      'BAJA' => 'Baja',
      'MEDIA' => 'Media',
      'ALTA' => 'Alta',
      _ => difficulty,
    };
  }

  Color _getDifficultyColor(String? difficulty) {
    if (difficulty == null) return Colors.grey;
    return switch (difficulty.toUpperCase()) {
      'BAJA' => Colors.green,
      'MEDIA' => Colors.orange,
      'ALTA' => Colors.red,
      _ => Colors.grey,
    };
  }

  // Static method to show the dialog
  static Future<void> show(BuildContext context, dynamic exercise) {
    return showDialog(
      context: context,
      builder: (context) => ExerciseDetailsDialog(exercise: exercise),
    );
  }
}