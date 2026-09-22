import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../puzzle/domain/entities/puzzle.dart';
import 'visual_puzzle_widget.dart';

/// Tarjeta del acertijo al final de cada página del libro.
class PuzzleCard extends StatefulWidget {
  final Puzzle puzzle;
  final bool isSolved;
  final bool? lastAnswerCorrect;
  final int failedAttempts;
  final void Function(String answer, int hintsUsed) onSubmit;
  final double textScale;

  const PuzzleCard({
    super.key,
    required this.puzzle,
    required this.isSolved,
    required this.lastAnswerCorrect,
    required this.failedAttempts,
    required this.onSubmit,
    this.textScale = 1.0,
  });

  @override
  State<PuzzleCard> createState() => _PuzzleCardState();
}

class _PuzzleCardState extends State<PuzzleCard> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedOption;
  int _hintLevel = 0; // 0 = sin pista, 1..3 = nivel mostrado
  bool get _showHint => _hintLevel > 0;

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
      _hintLevel = 0;
    }
    if (widget.isSolved) _hintLevel = 0;
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
                  '${p.experiencia} ${AppLocalizations.of(context).tr('xp')}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(p.statement,
              style: TextStyle(
                  fontSize: 15 * widget.textScale,
                  color: Colors.black87)),
          if (p.visualKind != null)
            VisualPuzzleWidget(
                visualKind: p.visualKind, visualPayload: p.visualPayload),
          const SizedBox(height: 12),
          if (!widget.isSolved)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, size: 18, color: Colors.brown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).tr('dareAndGain', {'xp': '${p.experiencia}'}),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                  ),
                ],
              ),
            ),
          if (widget.isSolved)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade700),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).tr('solvedCanPass'),
                      style: const TextStyle(
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
                    : () => widget.onSubmit(_selectedOption!, _hintLevel),
                child: Text(AppLocalizations.of(context).tr('answer'),
                    style:
                        const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ]
          else
            ...[
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).tr('writeAnswer'),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.brown, width: 2)),
                ),
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) widget.onSubmit(v, _hintLevel);
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
                    widget.onSubmit(_controller.text, _hintLevel);
                  }
                },
                child: Text(AppLocalizations.of(context).tr('answer'),
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          if (!widget.isSolved) ...[
            const SizedBox(height: 8),
            // A1: Pistas progresivas 3 niveles (coste XP informado)
            Builder(builder: (context) {
              final totalHints = p.allHints.length;
              final canShowMore = _hintLevel < totalHints;
              final hintCost = _hintLevel * 5; // 0, 5, 10 XP ya usados si se acierta
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          icon: Icon(
                              _showHint ? Icons.lightbulb : Icons.lightbulb_outline,
                              size: 18),
                          label: Text(
                            _hintLevel == 0
                                ? '${AppLocalizations.of(context).tr('hint')} 1/ $totalHints${widget.failedAttempts > 0 ? ' (${AppLocalizations.of(context).tr('hintRecommended')})' : ''}'
                                : canShowMore
                                    ? '${AppLocalizations.of(context).tr('hint')} ${_hintLevel + 1}/$totalHints (-5 XP)'
                                    : AppLocalizations.of(context).tr('hideHints'),
                          ),
                          onPressed: () => setState(() {
                            if (!canShowMore && _hintLevel > 0) {
                              _hintLevel = 0;
                            } else if (canShowMore) {
                              _hintLevel++;
                            }
                          }),
                        ),
                      ),
                      if (_hintLevel > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: hintCost > 0 ? Colors.orange.shade100 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: hintCost > 0 ? Colors.orange.shade700 : Colors.green.shade300),
                          ),
                          child: Text(
                            hintCost == 0 ? AppLocalizations.of(context).tr('free') : '-$hintCost XP',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: hintCost > 0 ? Colors.orange.shade900 : Colors.green.shade800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_showHint)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade700),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb, size: 18, color: Colors.brown),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context).tr('hintLevel', {'level': '$_hintLevel', 'total': '$totalHints'}),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, color: Colors.brown, fontSize: 12)),
                              const Spacer(),
                              if (hintCost > 0)
                                Text(AppLocalizations.of(context).tr('ifSolveNow', {'xp': '${(p.experiencia - hintCost).clamp(0, 999)}'}),
                                    style: const TextStyle(fontSize: 11, color: Colors.brown)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Muestra historial de pistas desbloqueadas
                          ...List.generate(_hintLevel, (i) {
                            final isLast = i == _hintLevel - 1;
                            return Padding(
                              padding: EdgeInsets.only(top: i == 0 ? 0 : 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${i + 1}. ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isLast ? Colors.brown.shade800 : Colors.brown.shade400,
                                          fontSize: 12)),
                                  Expanded(
                                    child: Text(
                                      p.hintForLevel(i),
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: isLast ? Colors.black87 : Colors.black54,
                                        fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                ],
              );
            }),
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
              child: Text(
                AppLocalizations.of(context).tr('incorrectStay', {'xp': '${p.experiencia}'}),
                style: const TextStyle(
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
                AppLocalizations.of(context).tr('correctXp', {'xp': '${p.experiencia}'}),
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
