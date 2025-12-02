import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';
import 'exercise_config_dialog.dart';
import 'edit_workout_name_dialog.dart';

// Default exercise configuration values
class _Constants {
  static const int defaultSets = 3;
  static const int defaultRepetitions = 10;
  static const int defaultRestTime = 60;
}

class EditWorkoutDialog extends ConsumerStatefulWidget {
  final String userId;
  final Workout workout;
  final Function(
      String workoutId,
      String? name,
      WorkoutCategory? category,
      List<Map<String, dynamic>>? exercises,
      bool? isPublic,
      ) onUpdateWorkout;
  final List<Exercise> availableExercises;

  const EditWorkoutDialog({
    super.key,
    required this.userId,
    required this.workout,
    required this.onUpdateWorkout,
    required this.availableExercises,
  });

  @override
  ConsumerState<EditWorkoutDialog> createState() => _EditWorkoutDialogState();
}

class _EditWorkoutDialogState extends ConsumerState<EditWorkoutDialog> {
  final _searchController = TextEditingController();

  late WorkoutCategory _selectedCategory;
  late bool _isPublic;
  late List<_ExerciseWithConfig> _selectedExercises;
  String _searchQuery = '';
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _initializeWorkoutData();
  }

  void _initializeWorkoutData() {
    _selectedCategory = widget.workout.category;
    _isPublic = widget.workout.isPublic;
    _selectedExercises = _loadExistingExercises();
  }

  List<_ExerciseWithConfig> _loadExistingExercises() {
    return widget.workout.exercises.map((workoutExercise) {
      // Find complete exercise in availableExercises by name
      final availableExercise = widget.availableExercises.firstWhere(
            (e) => e.name.toLowerCase() == workoutExercise.name.toLowerCase(),
        orElse: () => workoutExercise,
      );

      return _ExerciseWithConfig(
        exercise: availableExercise,
        sets: workoutExercise.sets ?? _Constants.defaultSets,
        repetitions: workoutExercise.repetitions ?? _Constants.defaultRepetitions,
        restTime: workoutExercise.restTime ?? _Constants.defaultRestTime,
      );
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Computed properties
  List<Exercise> get _filteredExercises {
    var exercises = widget.availableExercises;

    if (_searchQuery.isNotEmpty) {
      exercises = _filterBySearchQuery(exercises);
    }

    if (_selectedFilter != null) {
      exercises = _filterByCategory(exercises);
    }

    return exercises;
  }

  bool get _hasSelectedExercises => _selectedExercises.isNotEmpty;

  // Filtering logic
  List<Exercise> _filterBySearchQuery(List<Exercise> exercises) {
    return exercises.where((exercise) {
      final query = _searchQuery.toLowerCase();
      return exercise.name.toLowerCase().contains(query) ||
          (exercise.muscleGroup?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<Exercise> _filterByCategory(List<Exercise> exercises) {
    return exercises.where((exercise) {
      final filter = _selectedFilter?.toLowerCase();
      return exercise.category?.toLowerCase() == filter ||
          exercise.muscleGroup?.toLowerCase() == filter;
    }).toList();
  }

  // Exercise selection logic
  void _addExercise(Exercise exercise) {
    setState(() {
      _selectedExercises.add(
        _ExerciseWithConfig(
          exercise: exercise,
          sets: _Constants.defaultSets,
          repetitions: _Constants.defaultRepetitions,
          restTime: _Constants.defaultRestTime,
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
    return _selectedExercises.indexWhere((e) => e.exercise.id == exercise.id) + 1;
  }

  void _toggleExerciseSelection(Exercise exercise) {
    if (_isExerciseSelected(exercise)) {
      final config = _selectedExercises.firstWhere(
            (e) => e.exercise.id == exercise.id,
      );
      _removeExercise(config);
    } else {
      _addExercise(exercise);
    }
  }

  // Dialog navigation
  void _showEditWorkoutNameDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => EditWorkoutNameDialog(
        initialName: widget.workout.name,
        initialCategory: _selectedCategory,
        initialIsPublic: _isPublic,
        onConfirm: (name, category, isPublic) {
          _selectedCategory = category;
          _isPublic = isPublic;
          _updateWorkout(name);
        },
      ),
    );
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

  // Workout update logic
  void _updateWorkout(String name) {
    if (!_validateWorkout()) return;

    final exercises = _buildExercisesList();

    widget.onUpdateWorkout(
      widget.workout.id,
      name.isNotEmpty ? name : null,
      _selectedCategory,
      exercises,
      _isPublic,
    );
  }

  bool _validateWorkout() {
    if (_selectedExercises.isEmpty) {
      _showErrorSnackBar('Debes agregar al menos un ejercicio');
      return false;
    }
    return true;
  }

  List<Map<String, dynamic>> _buildExercisesList() {
    return _selectedExercises.map((exerciseConfig) {
      return {
        'name': exerciseConfig.exercise.name,
        'category': exerciseConfig.exercise.category,
        'muscle_group': exerciseConfig.exercise.muscleGroup,
        'description': exerciseConfig.exercise.description,
        'difficulty': exerciseConfig.exercise.difficulty,
        'equipment': exerciseConfig.exercise.equipment,
        'sets': exerciseConfig.sets,
        'repetitions': exerciseConfig.repetitions,
        'rest_time': exerciseConfig.restTime,
      };
    }).toList();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // UI Build methods
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Editar Ejercicios',
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
            color: _hasSelectedExercises ? Colors.green : Colors.grey,
          ),
          onPressed: _hasSelectedExercises ? _showEditWorkoutNameDialog : null,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchBar(),
        _buildCategoryFilters(),
        const SizedBox(height: 16),
        _buildExerciseList(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
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
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
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

  Widget _buildExerciseList() {
    return Expanded(
      child: _filteredExercises.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredExercises.length,
        itemBuilder: (context, index) {
          return _buildExerciseListItem(_filteredExercises[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No se encontraron ejercicios',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildExerciseListItem(Exercise exercise) {
    final isSelected = _isExerciseSelected(exercise);
    final orderIndex = isSelected ? _getExerciseOrderIndex(exercise) : null;

    return GestureDetector(
      onTap: () => _toggleExerciseSelection(exercise),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: _buildExerciseItemDecoration(isSelected),
        child: Row(
          children: [
            _buildExerciseIcon(),
            const SizedBox(width: 12),
            _buildExerciseInfo(exercise),
            if (isSelected && orderIndex != null)
              _buildOrderBadge(orderIndex),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildExerciseItemDecoration(bool isSelected) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isSelected ? Colors.green : Colors.transparent,
        width: 2,
      ),
      boxShadow: [
        if (!isSelected)
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 1,
          ),
      ],
    );
  }

  Widget _buildExerciseIcon() {
    return Container(
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
    );
  }

  Widget _buildExerciseInfo(Exercise exercise) {
    return Expanded(
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
    );
  }

  Widget _buildOrderBadge(int orderIndex) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
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
    );
  }

  Widget? _buildBottomBar() {
    if (!_hasSelectedExercises) return null;

    return Container(
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
            _buildSelectedExercisesList(),
            const SizedBox(height: 12),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedExercisesList() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedExercises.length,
        itemBuilder: (context, index) {
          return _buildSelectedExerciseCard(_selectedExercises[index]);
        },
      ),
    );
  }

  Widget _buildSelectedExerciseCard(_ExerciseWithConfig config) {
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
            _buildSelectedExerciseHeader(config),
            const SizedBox(height: 4),
            _buildSelectedExerciseDetails(config),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedExerciseHeader(_ExerciseWithConfig config) {
    return Row(
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
    );
  }

  Widget _buildSelectedExerciseDetails(_ExerciseWithConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }

  Widget _buildBottomActions() {
    return Row(
      children: [
        _buildSelectionCounter(),
        const Spacer(),
        _buildContinueButton(),
      ],
    );
  }

  Widget _buildSelectionCounter() {
    return Container(
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
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: _showEditWorkoutNameDialog,
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
    );
  }
}

/// Internal model class to hold exercise configuration
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