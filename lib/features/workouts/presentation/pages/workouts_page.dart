import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/providers/app_providers.dart';
import '../../../auth/presentation/auth_state.dart';
import '../widgets/create_workout_dialog.dart';
import 'workouts_state.dart';
import '../../domain/entities/workout.dart';

class WorkoutsPage extends ConsumerStatefulWidget {
  const WorkoutsPage({super.key});

  @override
  ConsumerState<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends ConsumerState<WorkoutsPage> {
  bool _hasLoadedWorkouts = false;
  WorkoutCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoadedWorkouts) {
        final authState = ref.read(authNotifierProvider);
        if (authState is AuthAuthenticated) {
          _hasLoadedWorkouts = true;
          ref
              .read(workoutNotifierProvider.notifier)
              .loadUserWorkouts(authState.user.id);
        }
      }
    });
  }

  void _showCreateWorkoutDialog(BuildContext context, String userId) {
    ref.read(workoutNotifierProvider.notifier).loadPredefinedExercises();

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final workoutState = ref.watch(workoutNotifierProvider);

            if (workoutState is PredefinedExercisesLoaded) {
              return CreateWorkoutDialog(
                userId: userId,
                availableExercises: workoutState.exercises,
                onCreateWorkout: (name, category, exercisesList, isPublic) {
                  ref
                      .read(workoutNotifierProvider.notifier)
                      .createWorkout(
                    userId: userId,
                    name: name,
                    category: category,
                    exercises: exercisesList,
                    isPublic: isPublic,
                  );
                },
              );
            }

            // Loading state
            return const Dialog(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando ejercicios...'),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      ref.read(workoutNotifierProvider.notifier).restorePreviousWorkoutsState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final workoutState = ref.watch(workoutNotifierProvider);

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userId = authState.user.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // TODO: Drawer
          },
        ),
        title: SizedBox(
          width: 55,
          height: 55,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateWorkoutDialog(context, userId),
        backgroundColor: Colors.black87,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(workoutNotifierProvider.notifier)
                .loadUserWorkouts(userId);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis rutinas',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Category filter chips
                _buildCategoryFilters(),
                const SizedBox(height: 24),

                _buildWorkoutContent(context, workoutState, userId),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = [
      (null, 'Todas'),
      (WorkoutCategory.STRENGTH, 'Fuerza'),
      (WorkoutCategory.CARDIO, 'Cardio'),
      (WorkoutCategory.FLEXIBILITY, 'Flexibilidad'),
      (WorkoutCategory.FUNCTIONAL, 'Funcional'),
      (WorkoutCategory.MIXED, 'Mixto'),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (category, label) = categories[index];
          final isSelected = _selectedCategory == category;

          return FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = category;
              });
            },
            backgroundColor: Colors.white,
            selectedColor: Colors.grey[900],
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.grey[900]! : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildWorkoutContent(
      BuildContext context,
      WorkoutState state,
      String userId,
      ) {
    // Loading state
    if (state is WorkoutLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Error state
    if (state is WorkoutError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(workoutNotifierProvider.notifier)
                      .loadUserWorkouts(userId);
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Filter workouts by category
    List<Workout> filteredWorkouts = [];
    if (state is WorkoutsLoaded) {
      filteredWorkouts = _selectedCategory == null
          ? state.workouts
          : state.workouts
          .where((w) => w.category == _selectedCategory)
          .toList();
    }

    // Empty state - centered full screen
    if (state is WorkoutsLoaded && filteredWorkouts.isEmpty) {
      final height = MediaQuery.of(context).size.height;
      return SizedBox(
        height: height * 0.5,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center_outlined,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                _selectedCategory == null
                    ? 'No tienes rutinas aún'
                    : 'No hay rutinas en esta categoría',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Crea tu primera rutina',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    // Workouts list
    if (state is WorkoutsLoaded) {
      return Column(
        children: filteredWorkouts
            .map((workout) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _WorkoutCard(workout: workout, userId: userId),
        ))
            .toList(),
      );
    }

    return const SizedBox.shrink();
  }
}

///========================= Workout Card Widget ========================= ///

class _WorkoutCard extends ConsumerWidget {
  final Workout workout;
  final String userId;

  const _WorkoutCard({required this.workout, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Navigate to detail page
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                workout.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Category and exercise count
              Row(
                children: [
                  Text(
                    _getCategoryName(workout.category),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    ' - ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    '${workout.exercises.length} Ejercicios',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (workout.isPublic)
                    Icon(
                      Icons.public,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Action buttons row
              Row(
                children: [
                  // Start workout button (icon only)
                  _buildIconButton(
                    icon: Icons.play_circle_outline,
                    onTap: () {
                      // TODO: Start workout
                    },
                  ),
                  const Spacer(),

                  // QR code button
                  _buildIconButton(
                    icon: Icons.qr_code_2,
                    onTap: () {
                      ref
                          .read(workoutNotifierProvider.notifier)
                          .generateShareLink(
                          workoutId: workout.id, userId: userId);
                    },
                  ),
                  const SizedBox(width: 8),

                  // Share button
                  _buildIconButton(
                    icon: Icons.share_outlined,
                    onTap: () {
                      ref
                          .read(workoutNotifierProvider.notifier)
                          .generateShareLink(
                          workoutId: workout.id, userId: userId);
                    },
                  ),
                  const SizedBox(width: 8),

                  // More options menu (Edit/Delete)
                  PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert,
                      size: 22,
                      color: Colors.grey[700],
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    offset: const Offset(0, 40),
                    onSelected: (value) =>
                        _handleMenuAction(value, context, ref),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                              size: 20,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Editar',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Eliminar',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 22,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  void _handleMenuAction(String value, BuildContext context, WidgetRef ref) {
    switch (value) {
      case 'delete':
        _showDeleteConfirmation(context, ref);
        break;
      case 'edit':
      // TODO: Implement edit functionality
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer(
          builder: (context, dialogRef, _) {
            return AlertDialog(
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
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.warning_rounded,
                        size: 48,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Eliminar rutina',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '¿Estás seguro de que quieres eliminar "${workout.name}"?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
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
                          backgroundColor: Colors.red[600],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          dialogRef
                              .read(workoutNotifierProvider.notifier)
                              .deleteWorkout(
                            workoutId: workout.id,
                            userId: userId,
                          );
                          Navigator.pop(dialogContext);
                        },
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
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