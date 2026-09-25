import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Visuales 100% exclusivos del Mapa — ningún otro puzzle del libro los usa.
/// Cada visualKind es nuevo y no existe en VisualPuzzleWidget clásico.
class MapExclusiveVisualWidget extends StatelessWidget {
  final String? visualKind;
  final String? visualPayload;
  const MapExclusiveVisualWidget({super.key, required this.visualKind, this.visualPayload});

  @override
  Widget build(BuildContext context) {
    switch (visualKind) {
      case 'cat_footprints':
        return _frame(_catFootprints());
      case 'moon_phases':
        return _frame(_moonPhases());
      case 'memory_runes':
        return _frame(_memoryRunes());
      case 'river_pipes':
        return _frame(_riverPipes());
      case 'shadow_match':
        return _frame(_shadowMatch());
      case 'wind_compass':
        return _frame(_windCompass(context));
      case 'village_wheel':
        return _frame(_villageWheel());
      case 'tower_gears':
        return _frame(_towerGears());
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _frame(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1009),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300, width: 1.5),
      ),
      child: child,
    );
  }

  // 1 — Huellas de gato: 4 rastros numerados (3/2/1/4 huellas).
  // Solo el rastro 2 tiene exactamente 2 huellas cada 4 losas. Filas compactas: sin overflow.
  Widget _catFootprints() {
    const trails = [
      ['paw', '', 'paw', 'paw'], // 3 huellas
      ['paw', 'paw', '', ''], // 2 huellas (correcto)
      ['', 'paw', '', ''], // 1 huella
      ['paw', 'paw', 'paw', 'paw'], // 4 huellas
    ];
    return Column(
      children: [
        const Text('Rastros del callejón', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(trails.length, (t) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    child: Text('${t + 1}',
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 6),
                  ...trails[t].map((s) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.brown, width: 1),
                        ),
                        child: Center(
                          child: Text(s == 'paw' ? '\u{1F43E}' : '',
                              style: const TextStyle(fontSize: 15)),
                        ),
                      )),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        const Text('¿Qué rastro tiene 2 huellas cada 4 losas?', style: TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  // 2 — Fases lunares: 5 noches con la fase central borrada (Wrap: sin overflow, sin respuesta).
  Widget _moonPhases() {
    const phases = ['new', 'crescent', 'missing', 'gibbous', 'full'];
    const glyphs = {
      'new': '\u{1F311}',
      'crescent': '\u{1F312}',
      'gibbous': '\u{1F314}',
      'full': '\u{1F315}',
    };
    return Column(
      children: [
        const Text('Cinco noches sobre Nebelheim', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: phases.map((p) {
            final isMissing = p == 'missing';
            return Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: isMissing ? Colors.amber : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isMissing ? Colors.black : Colors.amber.shade700)),
              child: Text(isMissing ? '?' : glyphs[p]!,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          isMissing ? FontWeight.bold : FontWeight.normal)),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        const Text('Una fase se ha borrado — ¿cuál falta?',
            style: TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  // 3 — Runas de memoria
  Widget _memoryRunes() {
    const runes = ['\u{16C9}', '\u{16CA}', '\u{16CF}', '\u{16D2}'];
    return Column(
      children: [
        const Text('Runas de Anselm', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: runes.map((r) => Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.brown.shade800, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber)),
            child: Text(r, style: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold)),
          )).toList(),
        ),
        const SizedBox(height: 8),
        const Text('Memoriza — una runa está invertida', style: TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  // 4 — Tuberías del río: 4 tuberías rotuladas A–D. Solo la B lleva agua
  // de lado a lado sin cortes ni cruces.
  Widget _riverPipes() {
    return Column(
      children: [
        const Text('Tuberías del Río', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 10),
        CustomPaint(size: const Size(240, 150), painter: _PipesPainter()),
        const SizedBox(height: 8),
        const Text('Solo una lleva agua de lado a lado', style: TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  // 5 — Sombras: gato de referencia + 4 sombras de gato numeradas.
  // Solo la 2 es idéntica (1 espejada, 3 más grande y clara, 4 ladeada).
  Widget _shadowMatch() {
    Widget candidate(int n, Widget cat) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber)),
            child: Center(child: cat),
          ),
          const SizedBox(height: 4),
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
                color: Colors.amber, shape: BoxShape.circle),
            child: Center(
                child: Text('$n',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12))),
          ),
        ],
      );
    }

    Widget shadowCat(Color color, double size) => CustomPaint(
        size: Size(size, size),
        painter: _CatSilhouettePainter(color));
    final refCat = shadowCat(Colors.black, 52);
    final darkCat = shadowCat(const Color(0xFF212121), 52);
    return Column(
      children: [
        const Text('Sombra del Gato', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 10),
        Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8)),
            child: Center(child: refCat)),
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text('↓',
                style: TextStyle(color: Colors.amber, fontSize: 18))),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            candidate(
                1,
                Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.diagonal3Values(-1, 1, 1),
                    child: darkCat)),
            candidate(2, darkCat),
            candidate(3, shadowCat(const Color(0xFF9E9E9E), 60)),
            candidate(
                4,
                RotationTransition(
                    turns: const AlwaysStoppedAnimation(0.05),
                    child: darkCat)),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Solo una es idéntica — ¿qué número?', style: TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  // 6 — Brújula de viento: la veleta apunta al oeste (sin resaltar la respuesta).
  // La letra oeste depende del idioma (O/W).
  Widget _windCompass(BuildContext context) {
    final locale =
        Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'es';
    final west = locale == 'en' ? 'W' : 'O';
    Widget badge(String letter) {
      return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
              color: Colors.brown.shade200, shape: BoxShape.circle),
          child: Center(child: Text(letter)));
    }

    return Column(
      children: [
        const Text('Rosa de los Vientos', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: Colors.brown, width: 2))),
            // Veleta apuntando al oeste (izquierda).
            const Positioned(
                left: 14,
                child: Icon(Icons.arrow_back,
                    color: Colors.red, size: 30)),
            Positioned(top: 6, child: badge('N')),
            Positioned(bottom: 6, child: badge('S')),
            Positioned(left: 6, child: badge(west)),
            Positioned(right: 6, child: badge('E')),
          ],
        ),
        const SizedBox(height: 8),
        const Text('La veleta apunta al oeste — ¿desde dónde sopla?', style: TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  // 7 — Rueda de la villa: los opuestos suman 10. Falta el 7 (frente al 3).
  Widget _villageWheel() {
    const values = [1, 2, 3, 4, 9, 8, 0, 6]; // 0 = hueco (respuesta 7)
    return Column(
      children: [
        const Text('Rueda de la Villa', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 10),
        SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 118, height: 118, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.brown.shade800, border: Border.all(color: Colors.amber, width: 2))),
              ...List.generate(8, (i) {
                // 0 arriba (-90°), luego horario cada 45°
                final angle = -math.pi / 2 + i * 2 * math.pi / 8;
                const r = 44.0;
                final rx = r * math.cos(angle);
                final ry = r * math.sin(angle);
                final missing = values[i] == 0;
                return Transform.translate(
                  offset: Offset(rx, ry),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(color: missing ? Colors.amber : Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.black)),
                    child: Center(child: Text(missing ? '?' : '${values[i]}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                  ),
                );
              }),
              Container(width: 40, height: 40, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle), child: const Icon(Icons.location_city, size: 20, color: Colors.black)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('Opuestos suman 10 — falta un número', style: TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  // 8 — Engranajes de la torre
  Widget _towerGears() {
    return Column(
      children: [
        const Text('Engranajes 10:10', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _gear(Colors.brown.shade700, '12'),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Icon(Icons.link, color: Colors.amber, size: 16)),
            _gear(Colors.amber, '10', isAmber: true),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Icon(Icons.link, color: Colors.amber, size: 16)),
            _gear(Colors.brown.shade700, '?'),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Si el grande gira 12 dientes, ¿cuánto el pequeño?', style: TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _gear(Color color, String label, {bool isAmber = false}) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color, border: Border.all(color: Colors.amber, width: 2)),
      child: Text(label, style: TextStyle(color: isAmber ? Colors.black : Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

class _PipesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const lanes = ['A', 'B', 'C', 'D'];
    final laneH = size.height / 4;
    final amber = Paint()
      ..color = Colors.amber
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final grey = Paint()
      ..color = Colors.blueGrey.shade300
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final water = Paint()
      ..color = Colors.blue.shade400
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final red = Paint()
      ..color = Colors.red.shade400
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 4; i++) {
      final yc = laneH * i + laneH / 2;
      // Rótulo A–D.
      final tp = TextPainter(
        text: TextSpan(
            text: lanes[i],
            style: const TextStyle(
                color: Colors.amber,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(2, yc - tp.height / 2));

      const x0 = 26.0;
      final x1 = size.width - 26;
      // Válvula izquierda: abierta (ámbar) salvo C (cerrada, gris).
      canvas.drawCircle(Offset(x0, yc), 5,
          Paint()..color = i == 2 ? Colors.blueGrey.shade300 : Colors.amber);
      // Boca derecha.
      canvas.drawCircle(Offset(x1, yc), 5, Paint()..color = Colors.brown);

      if (i == 1) {
        // B: tubería continua con agua de lado a lado.
        canvas.drawLine(Offset(x0, yc), Offset(x1, yc), water);
      } else if (i == 0) {
        // A: corte en el medio (sin agua a la derecha).
        final gap = (x1 - x0) / 2;
        canvas.drawLine(Offset(x0, yc), Offset(x0 + gap - 8, yc), water);
        canvas.drawLine(Offset(x0 + gap + 8, yc), Offset(x1, yc), grey);
      } else if (i == 2) {
        // C: válvula cerrada, tubería gris sin agua.
        canvas.drawLine(Offset(x0, yc), Offset(x1, yc), grey);
      } else {
        // D: tubería continua pero con cruce (X roja): inválida.
        canvas.drawLine(Offset(x0, yc), Offset(x1, yc), amber);
        final cx = (x0 + x1) / 2;
        canvas.drawLine(Offset(cx - 6, yc - 6), Offset(cx + 6, yc + 6), red);
        canvas.drawLine(Offset(cx - 6, yc + 6), Offset(cx + 6, yc - 6), red);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Silueta de gato sentado de perfil: cola curva, lomo, patas,
/// cabeza con dos orejas triangulares. Espacio de dibujo 60x60.
class _CatSilhouettePainter extends CustomPainter {
  final Color color;
  const _CatSilhouettePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 60;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    // Cola: curva gruesa a la derecha.
    final tail = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
        Path()
          ..moveTo(44 * s, 42 * s)
          ..quadraticBezierTo(58 * s, 32 * s, 53 * s, 12 * s),
        tail);
    // Lomo.
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(28 * s, 42 * s),
            width: 28 * s,
            height: 18 * s),
        fill);
    // Patas delanteras.
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(20 * s, 47 * s, 5 * s, 10 * s),
            Radius.circular(2 * s)),
        fill);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(31 * s, 47 * s, 5 * s, 10 * s),
            Radius.circular(2 * s)),
        fill);
    // Cabeza.
    canvas.drawCircle(Offset(42 * s, 26 * s), 8.5 * s, fill);
    // Orejas triangulares.
    canvas.drawPath(
        Path()
          ..moveTo(35 * s, 21 * s)
          ..lineTo(37 * s, 10 * s)
          ..lineTo(43 * s, 18 * s)
          ..close(),
        fill);
    canvas.drawPath(
        Path()
          ..moveTo(43 * s, 18 * s)
          ..lineTo(49 * s, 10 * s)
          ..lineTo(49.5 * s, 21 * s)
          ..close(),
        fill);
  }

  @override
  bool shouldRepaint(covariant _CatSilhouettePainter oldDelegate) =>
      oldDelegate.color != color;
}
