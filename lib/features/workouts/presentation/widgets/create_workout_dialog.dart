import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';

class CreateWorkoutDialog extends ConsumerStatefulWidget {
  final String userId;
  final Function(String name, WorkoutCategory category, List<Map<String, dynamic>> exercises, bool isPublic) onCreateWorkout;
  final List<Exercise> availableExercises;

  const CreateWorkoutDialog({
    super.key,
    required this.userId,
    required this.onCreateWorkout,
    required this.availableExercises,
  });

  @override
  ConsumerState<CreateWorkoutDialog> createState() => _CreateWorkoutDialogState();
}

class _CreateWorkoutDialogState extends ConsumerState<CreateWorkoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  WorkoutCategory _selectedCategory = WorkoutCategory.STRENGTH;
  bool _isPublic = false;
  final List<Map<String, dynamic>> _selectedExercises = [];
  String _searchQuery = '';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addExercise(Exercise exercise) {
    setState(() {
      _selectedExercises.add({
        'name': exercise.name,
        'sets': exercise.sets ?? 3,
        'repetitions': exercise.repetitions ?? 10,
        'rest_time': exercise.restTime ?? 60,
        'notes': exercise.description ?? '',
      });
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
    });
  }

  void _updateExercise(int index, String field, dynamic value) {
    setState(() {
      _selectedExercises[index][field] = value;
    });
  }

  List<Exercise> get _filteredExercises {
    if (_searchQuery.isEmpty) {
      return widget.availableExercises;
    }
    return widget.availableExercises.where((exercise) {
      return exercise.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (exercise.muscleGroup?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.fitness_center, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Nueva Rutina',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la rutina',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.edit),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Categoría
                      DropdownButtonFormField<WorkoutCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: WorkoutCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_getCategoryName(category)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Público/Privado
                      SwitchListTile(
                        title: const Text('Rutina pública'),
                        subtitle: const Text('Otros usuarios podrán ver esta rutina'),
                        value: _isPublic,
                        onChanged: (value) => setState(() => _isPublic = value),
                      ),
                      const Divider(height: 32),

                      // Ejercicios seleccionados
                      Row(
                        children: [
                          const Icon(Icons.list_alt, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Ejercicios (${_selectedExercises.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_selectedExercises.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Agrega ejercicios desde la lista de abajo',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ..._selectedExercises.asMap().entries.map((entry) {
                          final index = entry.key;
                          final exercise = entry.value;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          exercise['name'],
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _removeExercise(index),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: exercise['sets'].toString(),
                                          decoration: const InputDecoration(
                                            labelText: 'Series',
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) => _updateExercise(
                                            index,
                                            'sets',
                                            int.tryParse(value) ?? 1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: exercise['repetitions'].toString(),
                                          decoration: const InputDecoration(
                                            labelText: 'Reps',
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) => _updateExercise(
                                            index,
                                            'repetitions',
                                            int.tryParse(value) ?? 1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: exercise['rest_time'].toString(),
                                          decoration: const InputDecoration(
                                            labelText: 'Descanso (s)',
                                            isDense: true,
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) => _updateExercise(
                                            index,
                                            'rest_time',
                                            int.tryParse(value) ?? 60,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                      const Divider(height: 32),

                      // Ejercicios disponibles
                      Row(
                        children: [
                          const Icon(Icons.search, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Ejercicios disponibles',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Buscar ejercicios...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _filteredExercises.isEmpty
                            ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No se encontraron ejercicios',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = _filteredExercises[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: const Icon(Icons.fitness_center, size: 20),
                              ),
                              title: Text(exercise.name),
                              subtitle: Text(
                                '${exercise.muscleGroup ?? "General"} • ${exercise.difficulty ?? "Media"}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.green),
                                onPressed: () => _addExercise(exercise),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _selectedExercises.isEmpty
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        widget.onCreateWorkout(
                          _nameController.text,
                          _selectedCategory,
                          _selectedExercises,
                          _isPublic,
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Crear Rutina'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.STRENGTH:
        return 'Fuerza';
      case WorkoutCategory.CARDIO:
        return 'Cardio';
      case WorkoutCategory.FLEXIBILITY:
        return 'Flexibilidad';
      case WorkoutCategory.FUNCTIONAL:
        return 'Funcional';
      case WorkoutCategory.MIXED:
        return 'Mixto';
    }
  }
}