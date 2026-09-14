import 'dart:async';
import 'package:flutter/material.dart';

/// Celebración a pantalla completa al resolver el acertijo de una página.
/// Dura ~3,2 segundos (o hasta que se toca para continuar) y avisa con
/// [onDone] para que el lector muestre el botón de pasar página.
class SolvedCelebration extends StatefulWidget {
  final int pageNumber;
  final int pageCount;
  final int indicios;
  final VoidCallback onDone;
  final Duration duration;

  const SolvedCelebration({
    super.key,
    required this.pageNumber,
    required this.pageCount,
    required this.indicios,
    required this.onDone,
    this.duration = const Duration(milliseconds: 3200),
  });

  @override
  State<SolvedCelebration> createState() => _SolvedCelebrationState();
}

class _SolvedCelebrationState extends State<SolvedCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _checkScale;
  late final Animation<double> _star1;
  late final Animation<double> _star2;
  late final Animation<double> _star3;
  late final Animation<double> _textFade;
  Timer? _timer;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: widget.duration)
      ..forward();
    _checkScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.22, curve: Curves.elasticOut)),
    );
    _star1 = _pop(0.15, 0.35);
    _star2 = _pop(0.30, 0.50);
    _star3 = _pop(0.45, 0.65);
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.50, 0.68, curve: Curves.easeIn)),
    );
    _timer = Timer(widget.duration, _finish);
  }

  Animation<double> _pop(double begin, double end) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(begin, end, curve: Curves.easeOutBack)),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    if (_done) return;
    _done = true;
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _finish,
      child: Container(
        color: Colors.black.withValues(alpha: 0.72),
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (ctx, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: _checkScale.value.clamp(0.0, 1.2),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.shade600,
                    border:
                        Border.all(color: Colors.amber.shade200, width: 4),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black54,
                          blurRadius: 16,
                          offset: Offset(0, 6)),
                    ],
                  ),
                  child: const Icon(Icons.check,
                      size: 64, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Opacity(
                opacity: _textFade.value,
                child: Text(
                  '¡Página ${widget.pageNumber} resuelta!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Opacity(
                opacity: _textFade.value,
                child: Text(
                  '${widget.pageNumber} de ${widget.pageCount} páginas',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _star(_star1.value, 40),
                  _star(_star2.value, 56),
                  _star(_star3.value, 40),
                ],
              ),
              const SizedBox(height: 12),
              Opacity(
                opacity: _textFade.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+${widget.indicios} indicios',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Toca para continuar',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _star(double scale, double size) {
    return Transform.scale(
      scale: scale.clamp(0.0, 1.2),
      child: Icon(Icons.star, size: size, color: Colors.amber.shade300),
    );
  }
}
