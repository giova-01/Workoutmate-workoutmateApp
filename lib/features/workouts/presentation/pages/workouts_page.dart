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
                  'Mis Rutinas',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildWorkoutContent(context, workoutState, userId),
              ],
            ),
          ),
        ),
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

    // Empty state - centered full screen
    if (state is WorkoutsLoaded && state.workouts.isEmpty) {
      final height = MediaQuery.of(context).size.height;
      return SizedBox(
        height: height * 0.7,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _showCreateWorkoutDialog(context, userId),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue[50],
                    border: Border.all(color: Colors.blue[200]!, width: 2),
                  ),
                  child: const Icon(Icons.add, size: 100, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Crea tu primera rutina',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Workouts grid
    if (state is WorkoutsLoaded) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.workouts.length + 1,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          // First card is "New Workout"
          if (index == 0) {
            return GestureDetector(
              onTap: () => _showCreateWorkoutDialog(context, userId),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 60,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Nueva\nRutina',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Workout cards
          final workout = state.workouts[index - 1];
          return _WorkoutCard(workout: workout, userId: userId);
        },
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to detail page
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with category and menu
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(workout.category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCategoryName(workout.category),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (workout.isPublic)
                    const Icon(Icons.public, size: 16, color: Colors.grey),
                  PopupMenuButton(
                    onSelected: (value) =>
                        _handleMenuAction(value, context, ref),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share),
                            SizedBox(width: 8),
                            Text('Compartir'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Workout title
              Text(
                workout.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),

              // Exercise count
              Row(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${workout.exercises.length} ejercicios',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Last updated date
              Text(
                'Actualizada: ${_formatDate(workout.updatedAt)}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String value, BuildContext context, WidgetRef ref) {
    switch (value) {
      case 'delete':
        _showDeleteConfirmation(context, ref);
        break;
      case 'share':
        ref
            .read(workoutNotifierProvider.notifier)
            .generateShareLink(workoutId: workout.id, userId: userId);
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
      WorkoutCategory.STRENGTH => 'FUERZA',
      WorkoutCategory.CARDIO => 'CARDIO',
      WorkoutCategory.FLEXIBILITY => 'FLEXIBILIDAD',
      WorkoutCategory.FUNCTIONAL => 'FUNCIONAL',
      WorkoutCategory.MIXED => 'MIXTO',
    };
  }

  // Helper method for date formatting
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';

    return '${date.day}/${date.month}/${date.year}';
  }
}
