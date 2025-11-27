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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authNotifierProvider);
      if (authState is AuthAuthenticated) {
        ref.read(workoutNotifierProvider.notifier).loadUserWorkouts(authState.user.id);
      }
    });
  }

  void _showCreateWorkoutDialog(BuildContext context, String userId) {
    // Cargar ejercicios disponibles
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
                  ref.read(workoutNotifierProvider.notifier).createWorkout(
                    userId: userId,
                    name: name,
                    category: category,
                    exercises: exercisesList,
                    isPublic: isPublic,
                  );
                },
              );
            }

            // Mientras carga los ejercicios
            return const Dialog(
              child: Padding(
                padding: EdgeInsets.all(32.0),
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
    );
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
            // TODO: Implementar drawer
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 55,
              height: 55,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Center(child: Image.asset('assets/images/logo.png')),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(workoutNotifierProvider.notifier).loadUserWorkouts(userId);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mis Rutinas',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                if (workoutState is WorkoutLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (workoutState is WorkoutError)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            workoutState.message,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(workoutNotifierProvider.notifier).loadUserWorkouts(userId);
                            },
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (workoutState is WorkoutsLoaded && workoutState.workouts.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          GestureDetector(
                            onTap: () => _showCreateWorkoutDialog(context, userId),
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue[50],
                                border: Border.all(color: Colors.blue[200]!, width: 2),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, size: 80, color: Colors.blue),
                                  SizedBox(height: 8),
                                  Text(
                                    'Nueva Rutina',
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
                          const SizedBox(height: 24),
                          const Text(
                            'Crea tu primera rutina',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  else if (workoutState is WorkoutsLoaded)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: workoutState.workouts.length + 1,
                        itemBuilder: (context, index) {
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
                                      Icon(Icons.add_circle_outline, size: 60, color: Colors.blue),
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

                          final workout = workoutState.workouts[index - 1];
                          return _WorkoutCard(workout: workout, userId: userId);
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
        onTap: () {
          // TODO: Navegar a detalle
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, size: 20),
                            SizedBox(width: 8),
                            Text('Compartir'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context, ref);
                      } else if (value == 'share') {
                        ref.read(workoutNotifierProvider.notifier).generateShareLink(
                          workoutId: workout.id,
                          userId: userId,
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                workout.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.fitness_center, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${workout.exercises.length} ejercicios',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
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

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar rutina'),
        content: Text('¿Estás seguro de que quieres eliminar "${workout.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(workoutNotifierProvider.notifier).deleteWorkout(
                workoutId: workout.id,
                userId: userId,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.STRENGTH:
        return Colors.red[700]!;
      case WorkoutCategory.CARDIO:
        return Colors.orange[700]!;
      case WorkoutCategory.FLEXIBILITY:
        return Colors.purple[700]!;
      case WorkoutCategory.FUNCTIONAL:
        return Colors.green[700]!;
      case WorkoutCategory.MIXED:
        return Colors.blue[700]!;
    }
  }

  String _getCategoryName(WorkoutCategory category) {
    switch (category) {
      case WorkoutCategory.STRENGTH:
        return 'FUERZA';
      case WorkoutCategory.CARDIO:
        return 'CARDIO';
      case WorkoutCategory.FLEXIBILITY:
        return 'FLEXIBILIDAD';
      case WorkoutCategory.FUNCTIONAL:
        return 'FUNCIONAL';
      case WorkoutCategory.MIXED:
        return 'MIXTO';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}