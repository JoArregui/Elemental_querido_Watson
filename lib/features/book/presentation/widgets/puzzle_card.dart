import 'package:flutter/material.dart';
import '../../../puzzle/domain/entities/puzzle.dart';
import 'visual_puzzle_widget.dart';

/// Tarjeta del acertijo al final de cada página del libro.
class PuzzleCard extends StatefulWidget {
  final Puzzle puzzle;
  final bool isSolved;
  final bool? lastAnswerCorrect;
  final int failedAttempts;
  final void Function(String answer) onSubmit;

  const PuzzleCard({
    super.key,
    required this.puzzle,
    required this.isSolved,
    required this.lastAnswerCorrect,
    required this.failedAttempts,
    required this.onSubmit,
  });

  @override
  State<PuzzleCard> createState() => _PuzzleCardState();
}

class _PuzzleCardState extends State<PuzzleCard> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedOption;
  bool _showHint = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PuzzleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.puzzle.id != widget.puzzle.id) {
      _controller.clear();
      _selectedOption = null;
      _showHint = false;
    }
    if (widget.isSolved) _showHint = false;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.puzzle;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isSolved ? Colors.green.shade700 : Colors.amber,
          width: 2.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade800,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    p.title,
                    style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade200,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.brown),
                ),
                child: Text(
                  '${p.Picarats} Picarats',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(p.statement,
              style: const TextStyle(fontSize: 15, color: Colors.black87)),
          if (p.visualKind != null)
            VisualPuzzleWidget(
                visualKind: p.visualKind, visualPayload: p.visualPayload),
          const SizedBox(height: 12),
          if (widget.isSolved)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade700),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '¡Resuelto! Puedes pasar la página.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            )
          else if (p.hasOptions)
            ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: p.options.map((opt) {
                  final selected = _selectedOption == opt;
                  return ChoiceChip(
                    label: Text(opt,
                        style: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold)),
                    selected: selected,
                    selectedColor: Colors.brown.shade700,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.brown),
                    onSelected: (_) =>
                        setState(() => _selectedOption = opt),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade800,
                  foregroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _selectedOption == null
                    ? null
                    : () => widget.onSubmit(_selectedOption!),
                child: const Text('Responder',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ]
          else
            ...[
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Escribe tu respuesta',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.brown, width: 2)),
                ),
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) widget.onSubmit(v);
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade800,
                  foregroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  if (_controller.text.trim().isNotEmpty) {
                    widget.onSubmit(_controller.text);
                  }
                },
                child: const Text('Responder',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          if (!widget.isSolved) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.lightbulb_outline, size: 18),
              label: Text(_showHint
                  ? 'Ocultar pista'
                  : 'Pista${widget.failedAttempts > 0 ? ' (recomendada)' : ''}'),
              onPressed: () => setState(() => _showHint = !_showHint),
            ),
            if (_showHint)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb,
                        size: 18, color: Colors.brown),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(p.hintText,
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.black87))),
                  ],
                ),
              ),
          ],
          if (widget.lastAnswerCorrect == false && !widget.isSolved)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: const Text(
                'Respuesta incorrecta. ¡Todo caballero persevera!',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          if (widget.lastAnswerCorrect == true && widget.isSolved)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade400),
              ),
              child: Text(
                '¡Correcto! +${p.Picarats} Picarats',
                style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
