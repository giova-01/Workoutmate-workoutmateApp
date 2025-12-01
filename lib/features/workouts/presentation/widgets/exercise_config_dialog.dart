import 'package:flutter/material.dart';
import '../../domain/entities/exercise.dart';

class ExerciseConfigDialog extends StatefulWidget {
  final Exercise exercise;
  final int sets;
  final int repetitions;
  final int restTime;
  final Function(int sets, int repetitions, int restTime) onSave;

  const ExerciseConfigDialog({
    super.key,
    required this.exercise,
    required this.sets,
    required this.repetitions,
    required this.restTime,
    required this.onSave,
  });

  @override
  State<ExerciseConfigDialog> createState() => _ExerciseConfigDialogState();
}

class _ExerciseConfigDialogState extends State<ExerciseConfigDialog> {
  late int _sets;
  late int _repetitions;
  late int _restTime;
  late TextEditingController _restController;

  @override
  void initState() {
    super.initState();
    _sets = widget.sets;
    _repetitions = widget.repetitions;
    _restTime = widget.restTime;
    _restController = TextEditingController(text: _restTime.toString());
  }

  @override
  void dispose() {
    _restController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              widget.exercise.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Configura las series y repeticiones',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Sets counter
            _buildMinimalCounterRow(
              label: 'Series',
              value: _sets,
              onIncrement: () {
                setState(() {
                  if (_sets < 20) _sets++;
                });
              },
              onDecrement: () {
                setState(() {
                  if (_sets > 1) _sets--;
                });
              },
            ),
            const SizedBox(height: 16),

            // Repetitions counter
            _buildMinimalCounterRow(
              label: 'Repeticiones',
              value: _repetitions,
              onIncrement: () {
                setState(() {
                  if (_repetitions < 50) _repetitions++;
                });
              },
              onDecrement: () {
                setState(() {
                  if (_repetitions > 1) _repetitions--;
                });
              },
            ),
            const SizedBox(height: 16),

            // Rest time input
            TextField(
              controller: _restController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Descanso (segundos)',
                labelStyle: TextStyle(color: Colors.grey[700]),
                hintText: '60',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final restTime = int.tryParse(_restController.text) ?? 60;
                      widget.onSave(_sets, _repetitions, restTime);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Guardar',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalCounterRow({
    required String label,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Decrement button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  onTap: onDecrement,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: const Icon(
                      Icons.remove,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              // Value display
              Container(
                width: 50,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey[300]!),
                    right: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.0,
                  ),
                ),
              ),
              // Increment button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  onTap: onIncrement,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}