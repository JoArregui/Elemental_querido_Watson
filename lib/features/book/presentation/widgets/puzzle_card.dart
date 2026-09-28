import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../puzzle/domain/entities/puzzle.dart';
import 'visual_puzzle_widget.dart';
import 'map_exclusive_visual_widget.dart';

/// Tarjeta del acertijo al final de cada página del libro.
class PuzzleCard extends StatefulWidget {
  final Puzzle puzzle;
  final bool isSolved;
  final bool? lastAnswerCorrect;
  final int failedAttempts;
  final void Function(String answer, int hintsUsed) onSubmit;
  final double textScale;
  /// Cuando es true, la recompensa es una estrella azul (sin XP):
  /// se oculta el chip "+XP" y los mensajes de ganancia de XP.
  final bool blueStarReward;
  /// Cuando es false (Acertijo Final y Mapa de Nebelheim), Watson nunca
  /// cambia la historia: los fallos solo hacen perder puntos y recompensas.
  final bool allowBranch;

  const PuzzleCard({
    super.key,
    required this.puzzle,
    required this.isSolved,
    required this.lastAnswerCorrect,
    required this.failedAttempts,
    required this.onSubmit,
    this.textScale = 1.0,
    this.blueStarReward = false,
    this.allowBranch = true,
  });

  @override
  State<PuzzleCard> createState() => _PuzzleCardState();
}

class _PuzzleCardState extends State<PuzzleCard> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _selectedOption;
  int _hintLevel = 0; // 0 = sin pista, 1..3 = nivel mostrado
  bool get _showHint => _hintLevel > 0;

  DateTime? _lastSubmitAt;

  void _submitTextAnswer() {
    if (widget.isSolved) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    // Debounce: evita triple disparo (onKey + onSubmitted + onEditingComplete) y spam rápido
    final now = DateTime.now();
    if (_lastSubmitAt != null && now.difference(_lastSubmitAt!).inMilliseconds < 600) {
      return;
    }
    _lastSubmitAt = now;
    _focusNode.unfocus();
    widget.onSubmit(text, _hintLevel);
  }

  @override
  void dispose() {
    _focusNode.dispose();
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
    if (!widget.isSolved && widget.failedAttempts > oldWidget.failedAttempts) {
      final maxLevel = widget.puzzle.allHints.length.clamp(1, 3);
      _hintLevel = widget.failedAttempts.clamp(1, maxLevel);
    }
  }

  bool _isMapExclusiveKind(String kind) {
    const exclusive = {'cat_footprints', 'moon_phases', 'memory_runes', 'river_pipes', 'shadow_match', 'wind_compass', 'village_wheel', 'tower_gears'};
    return exclusive.contains(kind);
  }

  /// Texto de Watson según nº de fallo y si la historia puede ramificarse.
  /// En el Acertijo Final y el Mapa de Nebelheim (allowBranch=false) nunca
  /// cambia la historia: los fallos solo restan puntos y recompensas.
  String _branchHintSubtitle(BuildContext context) {
    final isEn =
        AppLocalizations.of(context).locale.languageCode == 'en';
    if (_hintLevel == 1) {
      return isEn
          ? 'Hint 1/3 (-5 XP if you solve now)'
          : 'Pista 1/3 (-5 XP si aciertas ahora)';
    }
    if (_hintLevel == 2) {
      if (!widget.allowBranch) {
        return isEn
            ? 'Hint 2/3 (-10 XP) — the story never branches here, but each fail lowers your stats.'
            : 'Pista 2/3 (-10 XP) — aquí la historia nunca cambia, pero cada fallo te hace perder puntos.';
      }
      return isEn
          ? 'Hint 2/3 (-10 XP) — next failure changes the story branch.'
          : 'Pista 2/3 (-10 XP) — el siguiente fallo cambia la rama de la historia.';
    }
    if (!widget.allowBranch) {
      return isEn
          ? 'No story change here: fails only cost points. Leave without solving and you lose the XP, collectible, star or reward.'
          : 'Aquí la historia no cambia: los fallos solo hacen perder puntos. Si sales sin acertar, pierdes experiencia, coleccionable, estrella o recompensa.';
    }
    return isEn
        ? 'Hint 3/3 (-15 XP) — from here the story changes: next pages and riddles will be different and these points plus this page\'s reward are lost.'
        : 'Pista 3/3 (-15 XP) — a partir de aquí la historia cambia: las siguientes páginas y acertijos serán distintos y habrás perdido estos puntos y su recompensa.';
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
                  color: widget.blueStarReward
                      ? Colors.blue.shade100
                      : Colors.amber.shade200,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: widget.blueStarReward
                          ? Colors.blue.shade700
                          : Colors.brown),
                ),
                child: widget.blueStarReward
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star,
                              size: 14, color: Colors.blue.shade700),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context).tr('blueStar'),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.blue.shade900),
                          ),
                        ],
                      )
                    : Text(
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
            // Solo uno renderiza: MapExclusive para kinds nuevos, clásico para el resto — evita doble frame
            _isMapExclusiveKind(p.visualKind!)
                ? MapExclusiveVisualWidget(visualKind: p.visualKind, visualPayload: p.visualPayload)
                : VisualPuzzleWidget(visualKind: p.visualKind, visualPayload: p.visualPayload),
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
                  Icon(
                      widget.blueStarReward
                          ? Icons.star
                          : Icons.emoji_events,
                      size: 18,
                      color: widget.blueStarReward
                          ? Colors.blue.shade700
                          : Colors.brown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.blueStarReward
                          ? AppLocalizations.of(context).tr('blueStarHint')
                          : AppLocalizations.of(context).tr(
                              'dareAndGain', {'xp': '${p.experiencia}'}),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.blueStarReward
                              ? Colors.blue.shade900
                              : Colors.brown),
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
              // Intro del teclado (soft + hardware) dispara responder — C3/D1 fix
              Focus(
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent &&
                      (event.logicalKey == LogicalKeyboardKey.enter ||
                          event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
                    _submitTextAnswer();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).tr('writeAnswer'),
                    border: const OutlineInputBorder(),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.brown, width: 2)),
                  ),
                  onSubmitted: (_) => _submitTextAnswer(),
                  onEditingComplete: _submitTextAnswer,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade800,
                  foregroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _submitTextAnswer(),
                child: Text(AppLocalizations.of(context).tr('answer'),
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          if (_showHint) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.brown.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.person, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).locale.languageCode == 'en'
                              ? 'Watson whispers:'
                              : 'Watson susurra:',
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.hintForLevel(_hintLevel - 1),
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _branchHintSubtitle(context),
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Página bloqueada por 3 fallos: castigo visible (puntos + recompensa
          // perdidos). Se muestra siempre, incluso al volver a la página.
          if (!widget.isSolved &&
              widget.failedAttempts >= 3 &&
              widget.allowBranch)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade500),
              ),
              child: Text(
                AppLocalizations.of(context).locale.languageCode == 'en'
                    ? 'Page blocked: these points and this page\'s reward (collectible) are lost. Keep playing to earn the rest!'
                    : 'Página bloqueada: has perdido estos puntos y su recompensa (coleccionable). ¡Sigue jugando para conseguir el resto!',
                style: const TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            )
          else if (widget.lastAnswerCorrect == false && !widget.isSolved)
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
