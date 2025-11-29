import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();

  WorkoutCategory _selectedCategory = WorkoutCategory.STRENGTH;
  bool _isPublic = false;
  final List<_ExerciseWithConfig> _selectedExercises = [];
  String _searchQuery = '';
  String? _selectedFilter;

  @override
  void dispose() {
    _nameController.dispose();
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

  void _showWorkoutNameDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    size: 48,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Crear Rutina',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    // Workout name input
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de la rutina',
                        hintText: 'Ej: Rutina de Fuerza',
                        prefixIcon: const Icon(Icons.edit),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa un nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Category dropdown
                    DropdownButtonFormField<WorkoutCategory>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: WorkoutCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(category),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(_getCategoryName(category)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => _selectedCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Public workout switch
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Rutina pública',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Otros usuarios podrán ver esta rutina',
                          style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        value: _isPublic,
                        activeColor: Colors.green,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                        onChanged: (value) {
                          setDialogState(() => _isPublic = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(dialogContext);
                          _createWorkout();
                        }
                      },
                      child: const Text(
                        'Crear',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  void _createWorkout() {
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
      _nameController.text.isNotEmpty ? _nameController.text : 'Nueva Rutina',
      _selectedCategory,
      exercises,
      _isPublic,
    );

    Navigator.pop(context);
  }

  void _showExerciseConfigDialog(_ExerciseWithConfig exerciseConfig) {
    final restController = TextEditingController(
      text: exerciseConfig.restTime.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.settings,
                    size: 48,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  exerciseConfig.exercise.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Configura las series y repeticiones',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  // Sets counter
                  _buildCounterRow(
                    label: 'Series',
                    icon: Icons.format_list_numbered,
                    value: exerciseConfig.sets,
                    onIncrement: () {
                      setDialogState(() {
                        if (exerciseConfig.sets < 20) exerciseConfig.sets++;
                      });
                    },
                    onDecrement: () {
                      setDialogState(() {
                        if (exerciseConfig.sets > 1) exerciseConfig.sets--;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Repetitions counter
                  _buildCounterRow(
                    label: 'Rep.',
                    icon: Icons.repeat,
                    value: exerciseConfig.repetitions,
                    onIncrement: () {
                      setDialogState(() {
                        if (exerciseConfig.repetitions < 100) {
                          exerciseConfig.repetitions++;
                        }
                      });
                    },
                    onDecrement: () {
                      setDialogState(() {
                        if (exerciseConfig.repetitions > 1) {
                          exerciseConfig.repetitions--;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Rest time input
                  TextField(
                    controller: restController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Descanso (segundos)',
                      hintText: '60',
                      prefixIcon: Icon(Icons.timer, color: Colors.blue[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        BorderSide(color: Colors.blue[700]!, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        exerciseConfig.restTime =
                            int.tryParse(restController.text) ?? 60;
                        Navigator.pop(dialogContext);
                        setState(() {});
                      },
                      child: const Text(
                        'Guardar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildCounterRow({
    required String label,
    required IconData icon,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: onDecrement,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.remove,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onIncrement,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.add,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

                        // Check indicator
                        if (isSelected)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
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

  // Helper methods for category styling
  Color _getCategoryColor(WorkoutCategory category) {
    return switch (category) {
      WorkoutCategory.STRENGTH => Colors.red[700]!,
      WorkoutCategory.CARDIO => Colors.orange[700]!,
      WorkoutCategory.FLEXIBILITY => Colors.purple[700]!,
      WorkoutCategory.FUNCTIONAL => Colors.green[700]!,
      WorkoutCategory.MIXED => Colors.blue[700]!,
    };
  }

  String _getCategoryName(WorkoutCategory category) {
    return switch (category) {
      WorkoutCategory.STRENGTH => 'Fuerza',
      WorkoutCategory.CARDIO => 'Cardio',
      WorkoutCategory.FLEXIBILITY => 'Flexibilidad',
      WorkoutCategory.FUNCTIONAL => 'Funcional',
      WorkoutCategory.MIXED => 'Mixto',
    };
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