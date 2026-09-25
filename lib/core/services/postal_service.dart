import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Postal de verdad: anverso con alusiones a Sherlock + libro actual,
/// reverso con toda la información de la partida. Se renderiza a PNG
/// con Canvas para compartirla como imágenes.
class PostalService {
  static const double w = 900;
  static const double h = 600;

  static const _ink = Color(0xFF1A1009);
  static const _gold = Color(0xFFFFC107);
  static const _goldDark = Color(0xFF8D6E00);
  static const _cream = Color(0xFFFFF3CD);
  static const _brown = Color(0xFF4E342E);

  void _text(
    Canvas canvas,
    String text,
    double x,
    double y, {
    required TextStyle style,
    double maxWidth = 800,
    TextAlign align = TextAlign.left,
    int maxLines = 3,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: maxLines,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    var dx = x;
    if (align == TextAlign.center) dx = x - tp.width / 2;
    if (align == TextAlign.right) dx = x - tp.width;
    tp.paint(canvas, Offset(dx, y));
  }

  double _textHeight(String text, TextStyle style, double maxWidth,
      {int maxLines = 3}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
    )..layout(maxWidth: maxWidth);
    return tp.height;
  }

  double _textWidth(String text, TextStyle style, double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);
    return tp.width;
  }

  Future<Uint8List> _toPng(void Function(Canvas, Size) draw) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    draw(canvas, const Size(w, h));
    final picture = recorder.endRecording();
    final image = await picture.toImage(w.toInt(), h.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return bytes!.buffer.asUint8List();
  }

  // ── ANVERSO ──────────────────────────────────────────────
  // Sherlock: gorra deerstalker + lupa sobre fondo nocturno,
  // título del libro que se está jugando, etapa, rango y XP.
  Future<Uint8List> renderFront({
    required String bookTitle,
    required String bookSubtitle,
    required int bookStage,
    required Color bookColor,
    required int totalXp,
    required String rank,
    required bool isEn,
  }) {
    return _toPng((canvas, size) {
      // Fondo nocturno.
      canvas.drawRect(Offset.zero & size,
          Paint()..color = const Color(0xFF140C06));
      // Estrellas.
      final star = Paint()..color = Colors.white.withValues(alpha: 0.5);
      const starPts = [
        Offset(60, 70), Offset(150, 40), Offset(260, 90), Offset(700, 50),
        Offset(800, 110), Offset(840, 60), Offset(420, 45), Offset(40, 200),
        Offset(870, 250), Offset(760, 200),
      ];
      for (final p in starPts) {
        canvas.drawCircle(p, 2, star);
      }
      // Luna.
      canvas.drawCircle(const Offset(795, 90), 34,
          Paint()..color = const Color(0xFFF5E9C8));
      canvas.drawCircle(const Offset(783, 82), 30,
          Paint()..color = const Color(0xFF140C06));

      // Silueta Sherlock a la izquierda: gorra + cabeza + lupa.
      const cx = 210.0;
      const cy = 330.0;
      final cloth = Paint()..color = const Color(0xFF3E2723);
      final clothLight = Paint()..color = const Color(0xFF6D4C41);
      // Hombros.
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: const Offset(cx, 560), width: 300, height: 150),
              const Radius.circular(40)),
          cloth);
      // Cabeza perfil.
      canvas.drawCircle(const Offset(cx, cy), 62, clothLight);
      // Gorra deerstalker: copa + viseras delantera y trasera.
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(cx, cy - 66), width: 150, height: 56),
          Paint()..color = _goldDark);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(cx - 105, cy - 52, 70, 20),
              const Radius.circular(10)),
          Paint()..color = _goldDark);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(cx + 35, cy - 52, 70, 20),
              const Radius.circular(10)),
          Paint()..color = _goldDark);
      // Lupa: aro + mango.
      canvas.drawCircle(
          const Offset(cx + 130, cy + 40),
          58,
          Paint()
            ..color = _gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10);
      canvas.drawLine(
          const Offset(cx + 171, cy + 81),
          const Offset(cx + 215, cy + 125),
          Paint()
            ..color = _gold
            ..strokeWidth = 14
            ..strokeCap = StrokeCap.round);
      // Brillo de la lupa.
      canvas.drawCircle(
          const Offset(cx + 113, cy + 23), 10,
          Paint()..color = Colors.white.withValues(alpha: 0.35));

      // Torre de Nebelheim al fondo derecho.
      final tower = Paint()..color = const Color(0xFF2C1A0E);
      canvas.drawRect(const Rect.fromLTWH(560, 180, 60, 300), tower);
      canvas.drawPath(
          Path()
            ..moveTo(555, 180)
            ..lineTo(590, 130)
            ..lineTo(625, 180)
            ..close(),
          tower);
      canvas.drawCircle(const Offset(590, 220), 14,
          Paint()..color = _gold.withValues(alpha: 0.9));

      // Textos derecha.
      _text(canvas, isEn ? '· ELEMENTAL ·' : '· ELEMENTAL ·', 660, 84,
          style: const TextStyle(
              color: _gold, fontSize: 22, letterSpacing: 6,
              fontWeight: FontWeight.bold),
          align: TextAlign.center, maxWidth: 500);
      _text(canvas, isEn ? 'MY DEAR WATSON' : 'QUERIDO WATSON', 660, 116,
          style: const TextStyle(
              color: Colors.white, fontSize: 40, letterSpacing: 3,
              fontWeight: FontWeight.bold, fontFamily: 'serif'),
          align: TextAlign.center, maxWidth: 520);
      // Franja del libro.
      final titleStyle = const TextStyle(
          color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold,
          fontFamily: 'serif');
      final titleH = _textHeight(bookTitle, titleStyle, 480, maxLines: 2);
      _text(canvas, bookTitle, 660, 190,
          style: titleStyle, align: TextAlign.center, maxWidth: 480,
          maxLines: 2);
      _text(
          canvas,
          '${isEn ? 'STAGE' : 'ETAPA'} $bookStage · $bookSubtitle',
          660, 190 + titleH + 10,
          style: const TextStyle(color: Colors.white70, fontSize: 19),
          align: TextAlign.center, maxWidth: 480, maxLines: 2);
      // Pastilla rango + XP.
      final chipY = 470.0;
      final chipText = '\u2B50 $totalXp XP · $rank';
      final chipStyle =
          const TextStyle(color: Colors.black, fontSize: 24,
              fontWeight: FontWeight.bold);
      final chipW = _textWidth(chipText, chipStyle, 600) + 56;
      final chipRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(660, chipY), width: chipW, height: 52),
          const Radius.circular(26));
      canvas.drawRRect(chipRect, Paint()..color = _gold);
      _text(canvas, chipText, 660, chipY - 17,
          style: chipStyle, align: TextAlign.center, maxWidth: 600,
          maxLines: 1);
      _text(
          canvas,
          isEn
              ? 'CASE LIBRARY — NEBELHEIM'
              : 'BIBLIOTECA DE CASOS — NEBELHEIM',
          660, 530,
          style: const TextStyle(
              color: Colors.white54, fontSize: 15, letterSpacing: 2),
          align: TextAlign.center, maxWidth: 520, maxLines: 1);

      // Marcos dorados.
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(12, 12, w - 24, h - 24),
              const Radius.circular(14)),
          Paint()
            ..color = _gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(22, 22, w - 44, h - 44),
              const Radius.circular(10)),
          Paint()
            ..color = _gold.withValues(alpha: 0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
      // Sello del libro: círculo con la etapa.
      canvas.drawCircle(const Offset(66, 534), 30, Paint()..color = bookColor);
      canvas.drawCircle(
          const Offset(66, 534), 30,
          Paint()
            ..color = _gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
      _text(canvas, '$bookStage', 66, 512,
          style: const TextStyle(
              color: Colors.white, fontSize: 30,
              fontWeight: FontWeight.bold),
          align: TextAlign.center, maxWidth: 60, maxLines: 1);
    });
  }

  // ── REVERSO ──────────────────────────────────────────────
  // Toda la información: rango, XP, libro, colección, secretos,
  // estrellas azules, racha, fecha + sello y matasellos.
  Future<Uint8List> renderBack({
    required String rank,
    required int totalXp,
    required String bookTitle,
    required int bookStage,
    required int solved,
    required int pageCount,
    required int bookXp,
    required int collectibles,
    required int secrets,
    required int blueStars,
    required int rewards,
    required int streak,
    required String date,
    required bool isEn,
  }) {
    return _toPng((canvas, size) {
      canvas.drawRect(Offset.zero & size, Paint()..color = _cream);
      final label = const TextStyle(
          color: _brown, fontSize: 20, fontWeight: FontWeight.bold);
      final value = const TextStyle(color: Colors.black87, fontSize: 20);
      final small = TextStyle(
          color: _brown.withValues(alpha: 0.7), fontSize: 15,
          fontStyle: FontStyle.italic);

      _text(canvas, isEn ? 'CASE POSTCARD' : 'POSTAL DEL CASO', 48, 30,
          style: const TextStyle(
              color: _brown, fontSize: 30, fontWeight: FontWeight.bold,
              letterSpacing: 2),
          maxWidth: 500);
      _text(canvas, '#ElementalWatson', 48, 70,
          style: small, maxWidth: 400);

      // Columna izquierda: datos.
      double y = 130;
      const rowGap = 46.0;
      void row(String l, String v) {
        _text(canvas, l, 48, y, style: label, maxWidth: 300);
        _text(canvas, v, 330, y, style: value, maxWidth: 220);
        y += rowGap;
      }

      row(isEn ? 'Rank' : 'Rango', '$rank · $totalXp XP');
      row(isEn ? 'Book' : 'Libro',
          '${isEn ? 'Stage' : 'Etapa'} $bookStage');
      _text(canvas, bookTitle, 48, y, style: value, maxWidth: 480,
          maxLines: 1);
      y += rowGap;
      row(isEn ? 'Solved' : 'Acertijos', '$solved/$pageCount · $bookXp XP');
      row(isEn ? 'Collection' : 'Colección', '$collectibles/90');
      row(isEn ? 'Secrets' : 'Secretos', '$secrets/18');
      row(isEn ? 'Blue stars' : 'Estrellas azules', '$blueStars/6 \u2605');
      row(isEn ? 'Rewards' : 'Recompensas', '$rewards/6');
      row(isEn ? 'Streak' : 'Racha',
          isEn ? '$streak days \u{1F525}' : '$streak días \u{1F525}');
      _text(canvas, date, 48, y + 4, style: small, maxWidth: 300);

      // División central.
      canvas.drawLine(const Offset(580, 110), const Offset(580, 540),
          Paint()..color = _brown..strokeWidth = 2);

      // Sello.
      const stamp = Rect.fromLTWH(660, 120, 150, 180);
      canvas.drawRect(stamp, Paint()..color = Colors.white);
      canvas.drawRect(
          stamp,
          Paint()
            ..color = _brown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
      // Viñeta del sello: lupa + locally.
      canvas.drawCircle(
          const Offset(735, 190), 34,
          Paint()
            ..color = _ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6);
      canvas.drawLine(
          const Offset(759, 214), const Offset(782, 237),
          Paint()
            ..color = _ink
            ..strokeWidth = 9
            ..strokeCap = StrokeCap.round);
      _text(canvas, 'HOLMES', 735, 248,
          style: const TextStyle(
              color: _brown, fontSize: 18, fontWeight: FontWeight.bold,
              letterSpacing: 2),
          align: TextAlign.center, maxWidth: 140, maxLines: 1);
      _text(canvas, isEn ? 'NEBELHEIM POST' : 'CORREOS NEBELHEIM', 735, 272,
          style: const TextStyle(color: _brown, fontSize: 11),
          align: TextAlign.center, maxWidth: 140, maxLines: 1);
      // Matasellos circular.
      canvas.drawCircle(
          const Offset(660, 150), 52,
          Paint()
            ..color = Colors.black54
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5);
      canvas.drawCircle(
          const Offset(660, 150), 40,
          Paint()
            ..color = Colors.black54
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
      _text(canvas, date, 660, 140,
          style: const TextStyle(
              color: Colors.black54, fontSize: 13,
              fontWeight: FontWeight.bold),
          align: TextAlign.center, maxWidth: 90, maxLines: 2);
      // Líneas de dirección.
      final linePaint = Paint()
        ..color = _brown.withValues(alpha: 0.4)
        ..strokeWidth = 1.5;
      for (var i = 0; i < 4; i++) {
        final ly = 380.0 + i * 44;
        canvas.drawLine(Offset(620, ly), Offset(860, ly), linePaint);
      }

      // Marco.
      canvas.drawRect(
          Rect.fromLTWH(12, 12, w - 24, h - 24),
          Paint()
            ..color = _brown
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3);
    });
  }
}
