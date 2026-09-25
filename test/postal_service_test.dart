import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elemental_querido_watson/core/services/postal_service.dart';

void main() {
  test('postal front renders non-empty PNG', () async {
    final bytes = await PostalService().renderFront(
      bookTitle: 'El Reloj Parado de Nebelheim',
      bookSubtitle: 'Etapa 1 · El misterio de la torre parada',
      bookStage: 1,
      bookColor: const Color(0xFF4E342E),
      totalXp: 320,
      rank: 'Investigador',
      isEn: false,
    );
    expect(bytes.isNotEmpty, isTrue);
  });

  test('postal back renders non-empty PNG', () async {
    final bytes = await PostalService().renderBack(
      rank: 'Investigador',
      totalXp: 320,
      bookTitle: 'El Reloj Parado de Nebelheim',
      bookStage: 1,
      solved: 12,
      pageCount: 30,
      bookXp: 300,
      collectibles: 10,
      secrets: 3,
      blueStars: 1,
      rewards: 0,
      streak: 4,
      date: '2026-09-26',
      isEn: false,
    );
    expect(bytes.isNotEmpty, isTrue);
  });
}
