import 'package:flutter/material.dart';

/// Dibuja la parte visual de los 6 acertijos visuales del libro.
/// Todo con widgets básicos (sin assets) para que funcione en cualquier plataforma.
class VisualPuzzleWidget extends StatelessWidget {
  final String? visualKind;
  final String? visualPayload;
  const VisualPuzzleWidget(
      {super.key, required this.visualKind, this.visualPayload});

  @override
  Widget build(BuildContext context) {
    switch (visualKind) {
      case 'shapes_sequence':
        return _shapesSequence(_shapesFromPayload(
            visualPayload, const ['●', '▲', '■', '●', '▲', '?']));
      case 'odd_one_out':
        return _shapesSequence(
            _shapesFromPayload(visualPayload, const ['●', '●', '▲', '●']));
      case 'chests':
        return _chests();
      case 'matchsticks':
        return _matchsticks();
      case 'coin_triangle':
        return _coinTriangle();
      case 'balance':
        return _balance(visualPayload);
      case 'grid_squares':
        return _gridSquares(visualPayload);
      case 'dials':
        return _dials();
      default:
        return const SizedBox.shrink();
    }
  }

  List<String> _shapesFromPayload(String? payload, List<String> fallback) {
    if (payload == null || payload.trim().isEmpty) return fallback;
    final parts =
        payload.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return parts.isEmpty ? fallback : parts;
  }

  Widget _frame(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C1A0E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200, width: 1.5),
      ),
      child: child,
    );
  }

  Widget _shapesSequence(List<String> seq) {
    return _frame(
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: seq.map((s) {
          final isUnknown = s == '?';
          return Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isUnknown ? Colors.amber : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade700, width: 2),
            ),
            child: Text(
              s,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isUnknown ? Colors.black : Colors.brown.shade800,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _chests() {
    final chests = [
      {'color': Colors.red.shade700, 'label': 'ROJO'},
      {'color': Colors.blue.shade700, 'label': 'AZUL'},
      {'color': Colors.green.shade700, 'label': 'VERDE'},
    ];
    return _frame(
      Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 12,
        runSpacing: 12,
        children: chests.map((c) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 54,
                decoration: BoxDecoration(
                  color: c['color'] as Color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  border: Border.all(color: Colors.amber.shade200, width: 2),
                ),
                child: const Icon(Icons.lock, color: Colors.amber, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                c['label'] as String,
                style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _matchsticks() {
    // Dos triángulos que comparten un lado: 5 cerillas.
    return _frame(
      Column(
        children: [
          CustomPaint(
            size: const Size(200, 120),
            painter: _MatchsticksPainter(),
          ),
          const SizedBox(height: 8),
          const Text(
            '2 triángulos · 1 lado compartido',
            style: TextStyle(color: Colors.amber, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _balance(String? payload) {
    // Formato: "etiqueta izquierda|etiqueta derecha"
    var left = '3×4kg + 2×1kg';
    var right = '? × 2kg';
    if (payload != null && payload.contains('|')) {
      final parts = payload.split('|');
      if (parts[0].trim().isNotEmpty) left = parts[0].trim();
      if (parts.length > 1 && parts[1].trim().isNotEmpty) {
        right = parts[1].trim();
      }
    }
    return _frame(
      Column(
        children: [
          const Icon(Icons.balance, size: 64, color: Colors.amber),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.brown.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
              child: Text(
                left,
                style:
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const Text('⚖️',
                style: TextStyle(fontSize: 22, color: Colors.white)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                right,
                style:
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gridSquares(String? payload) {
    // Formato: "3x3", "2x2" o "4x4".
    var n = 3;
    if (payload != null) {
      final m = RegExp(r'(\d)\s*x\s*(\d)').firstMatch(payload);
      if (m != null) {
        n = int.parse(m.group(1)!).clamp(2, 4);
      }
    }
    final side = n == 4 ? 160.0 : 180.0;
    final labels = n == 2 ? 'Cuenta 1×1 y 2×2' : 'Cuenta 1×1, 2×2 y 3×3';
    return _frame(
      Column(
        children: [
          SizedBox(
            width: side,
            height: side,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: n,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: n * n,
              itemBuilder: (_, i) => Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  border: Border.all(color: Colors.brown, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('${i + 1}',
                    style: const TextStyle(
                        color: Colors.brown, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            n == 4 ? 'Cuenta todos los tamaños' : labels,
            style: const TextStyle(color: Colors.amber, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _coinTriangle() {
    // Pirámide de 10 monedas (filas de 1, 2, 3 y 4).
    return _frame(
      Column(
        children: [
          CustomPaint(
            size: const Size(200, 140),
            painter: _CoinTrianglePainter(),
          ),
          const SizedBox(height: 8),
          const Text(
            '10 monedas · muévelas con la mente',
            style: TextStyle(color: Colors.amber, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _dials() {
    return _frame(
      Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 12,
        runSpacing: 12,
        children: [0, 1, 2].map((i) {
          return Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: Colors.amber, width: 3),
            ),
            child: const Text(
              '?',
              style: TextStyle(
                  color: Colors.amber,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CoinTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = const Color(0xFFFFD54F);
    final border = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    const r = 13.0;
    // Filas de 1, 2, 3 y 4 monedas centradas.
    const rows = [1, 2, 3, 4];
    for (var row = 0; row < rows.length; row++) {
      final count = rows[row];
      final y = 22.0 + row * 32.0;
      for (var i = 0; i < count; i++) {
        final x = size.width / 2 + (i - (count - 1) / 2) * (r * 2 + 6);
        canvas.drawCircle(Offset(x, y), r, fill);
        canvas.drawCircle(Offset(x, y), r, border);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MatchsticksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD2691E)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final headPaint = Paint()..color = Colors.red.shade700;

    void stick(Offset a, Offset b) {
      canvas.drawLine(a, b, paint);
      canvas.drawCircle(a, 5, headPaint);
    }

    // Triángulo izquierdo: (20,100)-(60,30)-(100,100)
    // Triángulo derecho comparte lado (60,30)-(100,100): (60,30)-(100,100)-(140,30)... ajustado
    final p1 = Offset(size.width * 0.15, size.height * 0.85);
    final p2 = Offset(size.width * 0.35, size.height * 0.15);
    final p3 = Offset(size.width * 0.55, size.height * 0.85);
    final p4 = Offset(size.width * 0.78, size.height * 0.15);

    stick(p1, p2);
    stick(p2, p3);
    stick(p1, p3); // base izquierda
    stick(p2, p4); // lado superior derecho
    stick(p3, p4); // lado inferior derecho (comparte p2-p3)
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
