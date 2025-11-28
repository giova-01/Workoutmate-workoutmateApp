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
  final _searchController = TextEditingController();

  final WorkoutCategory _selectedCategory = WorkoutCategory.STRENGTH;
  final bool _isPublic = false;
  final List<Exercise> _selectedExercises = [];
  String _searchQuery = '';
  String? _selectedFilter;

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _addExercise(Exercise exercise) {
    setState(() {
      _selectedExercises.add(exercise);
    });
  }

  void _removeExercise(Exercise exercise) {
    setState(() {
      _selectedExercises.remove(exercise);
    });
  }

  bool _isExerciseSelected(Exercise exercise) {
    return _selectedExercises.any((e) => e.id == exercise.id);
  }

  List<Exercise> get _filteredExercises {
    var exercises = widget.availableExercises;

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      exercises = exercises.where((exercise) {
        return exercise.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (exercise.muscleGroup?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Filtrar por categoría seleccionada
    if (_selectedFilter != null) {
      exercises = exercises.where((exercise) {
        return exercise.category?.toLowerCase() == _selectedFilter?.toLowerCase() ||
            exercise.muscleGroup?.toLowerCase() == _selectedFilter?.toLowerCase();
      }).toList();
    }

    return exercises;
  }

  void _createWorkout() {
    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes agregar al menos un ejercicio')),
      );
      return;
    }

    final exercises = _selectedExercises.asMap().entries.map((entry) {
      return {
        'name': entry.value.name,
        'sets': entry.value.sets ?? 3,
        'repetitions': entry.value.repetitions ?? 10,
        'rest_time': entry.value.restTime ?? 60,
        'notes': entry.value.description ?? '',
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
          'Agregar Ejercicio',
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
            onPressed: _selectedExercises.isEmpty ? null : _createWorkout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
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

          // Filtros por categoría
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Cardio', Icons.favorite_border),
                const SizedBox(width: 8),
                _buildFilterChip('Fuerza', Icons.fitness_center),
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

          // Lista de ejercicios
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
                      _removeExercise(exercise);
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
                        color: isSelected ? Colors.green : Colors.grey[200]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Imagen/Icono del ejercicio
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

                        // Información del ejercicio
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
                                exercise.muscleGroup ?? exercise.category ?? 'General',
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

      // Contador de ejercicios seleccionados
      bottomNavigationBar: _selectedExercises.isNotEmpty
          ? Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
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
                onPressed: _createWorkout,
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
                  'Crear Rutina',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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