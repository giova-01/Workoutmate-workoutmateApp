import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';
import 'exercise_config_dialog.dart';
import 'workout_name_dialog.dart';

class CreateWorkoutDialog extends ConsumerStatefulWidget {
  final String userId;
  final Function(
      String name,
      WorkoutCategory category,
      List<Map<String, dynamic>> exercises,
      bool isPublic,
      ) onCreateWorkout;
  final List<Exercise> availableExercises;

  const CreateWorkoutDialog({
    super.key,
    required this.userId,
    required this.onCreateWorkout,
    required this.availableExercises,
  });

  @override
  ConsumerState<CreateWorkoutDialog> createState() =>
      _CreateWorkoutDialogState();
}

class _CreateWorkoutDialogState extends ConsumerState<CreateWorkoutDialog> {
  final _searchController = TextEditingController();

  WorkoutCategory _selectedCategory = WorkoutCategory.STRENGTH;
  bool _isPublic = false;
  final List<_ExerciseWithConfig> _selectedExercises = [];
  String _searchQuery = '';
  String? _selectedFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Computed property for filtered exercises
  List<Exercise> get _filteredExercises {
    var exercises = widget.availableExercises;

    if (_searchQuery.isNotEmpty) {
      exercises = exercises.where((exercise) {
        return exercise.name.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        ) ||
            (exercise.muscleGroup?.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ??
                false);
      }).toList();
    }

    if (_selectedFilter != null) {
      exercises = exercises.where((exercise) {
        return exercise.category?.toLowerCase() ==
            _selectedFilter?.toLowerCase() ||
            exercise.muscleGroup?.toLowerCase() ==
                _selectedFilter?.toLowerCase();
      }).toList();
    }

    return exercises;
  }

  void _addExercise(Exercise exercise) {
    setState(() {
      _selectedExercises.add(
        _ExerciseWithConfig(
          exercise: exercise,
          sets: 3,
          repetitions: 10,
          restTime: 60,
        ),
      );
    });
  }

  void _removeExercise(_ExerciseWithConfig exerciseConfig) {
    setState(() {
      _selectedExercises.remove(exerciseConfig);
    });
  }

  bool _isExerciseSelected(Exercise exercise) {
    return _selectedExercises.any((e) => e.exercise.id == exercise.id);
  }

  int _getExerciseOrderIndex(Exercise exercise) {
    return _selectedExercises.indexWhere((e) => e.exercise.id == exercise.id) +
        1;
  }

  void _showWorkoutNameDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => WorkoutNameDialog(
        initialCategory: _selectedCategory,
        initialIsPublic: _isPublic,
        onConfirm: (name, category, isPublic) {
          _selectedCategory = category;
          _isPublic = isPublic;
          _createWorkout(name);
        },
      ),
    );
  }

  void _createWorkout(String name) {
    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes agregar al menos un ejercicio'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final exercises = _selectedExercises.asMap().entries.map((entry) {
      return {
        'name': entry.value.exercise.name,
        'category': entry.value.exercise.category,
        'muscle_group': entry.value.exercise.muscleGroup,
        'description': entry.value.exercise.description,
        'difficulty': entry.value.exercise.difficulty,
        'equipment': entry.value.exercise.equipment,
        'sets': entry.value.sets,
        'repetitions': entry.value.repetitions,
        'rest_time': entry.value.restTime,
      };
    }).toList();

    widget.onCreateWorkout(
      name.isNotEmpty ? name : 'Nueva Rutina',
      _selectedCategory,
      exercises,
      _isPublic,
    );

    Navigator.pop(context);
  }

  void _showExerciseConfigDialog(_ExerciseWithConfig exerciseConfig) {
    showDialog(
      context: context,
      builder: (dialogContext) => ExerciseConfigDialog(
        exercise: exerciseConfig.exercise,
        sets: exerciseConfig.sets,
        repetitions: exerciseConfig.repetitions,
        restTime: exerciseConfig.restTime,
        onSave: (sets, repetitions, restTime) {
          setState(() {
            exerciseConfig.sets = sets;
            exerciseConfig.repetitions = repetitions;
            exerciseConfig.restTime = restTime;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Agregar Ejercicios',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: _selectedExercises.isEmpty ? Colors.grey : Colors.green,
            ),
            onPressed:
            _selectedExercises.isEmpty ? null : _showWorkoutNameDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Category filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const SizedBox(width: 8),
                _buildFilterChip('Brazos', Icons.fitness_center),
                const SizedBox(width: 8),
                _buildFilterChip('Piernas', Icons.directions_run),
                const SizedBox(width: 8),
                _buildFilterChip('Pecho', Icons.accessibility_new),
                const SizedBox(width: 8),
                _buildFilterChip('Espalda', Icons.accessibility),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Exercise list
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center(
              child: Text(
                'No se encontraron ejercicios',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = _filteredExercises[index];
                final isSelected = _isExerciseSelected(exercise);
                final orderIndex = isSelected
                    ? _getExerciseOrderIndex(exercise)
                    : null;

                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      final config = _selectedExercises.firstWhere(
                            (e) => e.exercise.id == exercise.id,
                      );
                      _removeExercise(config);
                    } else {
                      _addExercise(exercise);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.green
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        if (!isSelected)
                          BoxShadow(
                            color: Colors.grey[200]!,
                            blurRadius: 1,
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Exercise icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Exercise info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                exercise.muscleGroup ??
                                    exercise.category ??
                                    'General',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Order number indicator
                        if (isSelected && orderIndex != null)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                orderIndex.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Bottom bar with selected exercises
      bottomNavigationBar: _selectedExercises.isNotEmpty
          ? Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selected exercises horizontal list
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedExercises.length,
                  itemBuilder: (context, index) {
                    final config = _selectedExercises[index];
                    return GestureDetector(
                      onTap: () => _showExerciseConfigDialog(config),
                      child: Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Order number badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius:
                                    BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    config.exercise.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _removeExercise(config),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${config.sets} series × ${config.repetitions} reps',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Descanso: ${config.restTime}s',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Action row with counter and button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedExercises.length} seleccionados',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _showWorkoutNameDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = isSelected ? null : label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///========================= Exercise With Config ========================= ///

class _ExerciseWithConfig {
  final Exercise exercise;
  int sets;
  int repetitions;
  int restTime;

  _ExerciseWithConfig({
    required this.exercise,
    required this.sets,
    required this.repetitions,
    required this.restTime,
  });
}