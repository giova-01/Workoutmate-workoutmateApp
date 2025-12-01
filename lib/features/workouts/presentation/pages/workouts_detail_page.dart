import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../domain/entities/workout.dart';

class WorkoutDetailPage extends ConsumerStatefulWidget {
  final Workout workout;

  const WorkoutDetailPage({super.key, required this.workout});

  @override
  ConsumerState<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends ConsumerState<WorkoutDetailPage> {
  bool _isRunning = false;
  int _currentExerciseIndex = 0;
  int _elapsedSeconds = 0;
  int _currentSet = 1;

  // Timer variables
  Timer? _timer;
  bool _isTimerRunning = false;
  int _timerSeconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isTimerRunning) return;

    final currentExercise = widget.workout.exercises[_currentExerciseIndex];
    setState(() {
      _timerSeconds = currentExercise.restTime ?? 60; // Default 60 segundos si no hay restTime
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
          _elapsedSeconds++;
        } else {
          _pauseTimer();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    final currentExercise = widget.workout.exercises[_currentExerciseIndex];
    setState(() {
      _timerSeconds = currentExercise.restTime ?? 60;
      _isTimerRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = _isRunning && widget.workout.exercises.isNotEmpty
        ? widget.workout.exercises[_currentExerciseIndex]
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.workout.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2, color: Colors.black),
            onPressed: () {
              // TODO: Mostrar QR
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {
              // TODO: Compartir
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () {
              // TODO: Editar
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isRunning ? _buildRunningView(currentExercise!) : _buildPreviewView(),
      ),
    );
  }

  Widget _buildPreviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            children: [
              Text(
                _getCategoryName(widget.workout.category),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                ' • ',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
              Text(
                '${widget.workout.exercises.length} Ejercicios',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Exercise list
          ...widget.workout.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Exercise image placeholder
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),

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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Series: ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${exercise.sets}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Reps: ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${exercise.repetitions}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 32),

          // Start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isRunning = true;
                  _elapsedSeconds = 0;
                  _currentExerciseIndex = 0;
                  _currentSet = 1;
                  _resetTimer();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Iniciar Rutina',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunningView(exercise) {
    final isLastSet = _currentSet >= exercise.sets!;
    final isLastExercise = _currentExerciseIndex >= widget.workout.exercises.length - 1;

    String nextButtonLabel;
    if (isLastSet && !isLastExercise) {
      nextButtonLabel = 'Siguiente Ejercicio';
    } else if (isLastSet && isLastExercise) {
      nextButtonLabel = 'Finalizar';
    } else {
      nextButtonLabel = 'Siguiente Serie';
    }

    return Column(
      children: [
        // Timer and controls
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            children: [
              // Timer display

              const SizedBox(height: 8),
              Text(
                'Tiempo de descanso',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                _formatTime(_timerSeconds),
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: _timerSeconds <= 5 && _isTimerRunning
                      ? Colors.red
                      : Colors.black,
                ),
              ),
              // Play/Pause/Reset buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, size: 28),
                      onPressed: _resetTimer,
                      tooltip: 'Reiniciar',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: _isTimerRunning ? Colors.orange : Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isTimerRunning ? Colors.orange : Colors.green)
                              .withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isTimerRunning ? Icons.pause : Icons.play_arrow,
                        size: 36,
                        color: Colors.white,
                      ),
                      onPressed: _isTimerRunning ? _pauseTimer : _startTimer,
                      tooltip: _isTimerRunning ? 'Pausar' : 'Iniciar',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Current exercise info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  exercise.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Series info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoCard('N° Serie:', '$_currentSet', '${exercise.sets}'),
                  _buildInfoCard('Repeticiones', '${exercise.repetitions}', '${exercise.repetitions}'),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),

        // Bottom navigation
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Botones de navegación (Anterior y Siguiente)
              Row(
                children: [
                  // Botón anterior
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (_currentSet > 1 || _currentExerciseIndex > 0)
                          ? _previousExercise
                          : null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: (_currentSet > 1 || _currentExerciseIndex > 0)
                              ? Colors.black
                              : Colors.grey[300]!,
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_back,
                        color: (_currentSet > 1 || _currentExerciseIndex > 0)
                            ? Colors.black
                            : Colors.grey[400],
                      ),
                      label: Text(
                        'Anterior',
                        style: TextStyle(
                          color: (_currentSet > 1 || _currentExerciseIndex > 0)
                              ? Colors.black
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Botón siguiente
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _nextExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(isLastSet && isLastExercise ? Icons.check : Icons.arrow_forward),
                      label: Text(nextButtonLabel),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Botón terminar (abajo)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isRunning = false;
                      _timer?.cancel();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text('Terminar Rutina'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String current, String total) {
    return Container(
      width: MediaQuery.of(context).size.height * 0.2,
      height: MediaQuery.of(context).size.height * 0.12,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            current,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _previousExercise() {
    if (_currentSet > 1) {
      // Ir a la serie anterior en el mismo ejercicio
      setState(() {
        _currentSet--;
        _resetTimer();
      });
    } else if (_currentExerciseIndex > 0) {
      // Ir al ejercicio anterior (última serie)
      setState(() {
        _currentExerciseIndex--;
        _currentSet = widget.workout.exercises[_currentExerciseIndex].sets!;
        _resetTimer();
      });
    }
  }

  void _nextExercise() {
    if (_currentSet < widget.workout.exercises[_currentExerciseIndex].sets!) {
      setState(() {
        _currentSet++;
        _resetTimer();
      });
    } else if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
        _resetTimer();
      });
    } else {
      // Workout completed
      setState(() {
        _isRunning = false;
        _timer?.cancel();
      });
      _showCompletedDialog();
    }
  }

  void _showCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '¡Rutina Completada!',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Tiempo de descanso total: ${_formatTime(_elapsedSeconds)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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