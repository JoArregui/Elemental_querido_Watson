import '../../../puzzle/data/models/puzzle_model.dart';
import '../../../puzzle/domain/entities/puzzle.dart';

/// 8 PUZZLES 100% EXCLUSIVOS — TIPO PUZZLE visual — SOLO MAPA.
/// Ninguno existe en puzzle_local_data_source (001-090) ni en libros B01-B30.
/// Cada uno usa un visualKind NUEVO (cat_footprints, moon_phases, etc.)
/// que solo existe en MapExclusiveVisualWidget, garantizando que son
/// completamente diferentes a cualquier acertijo/rompecabeza previo.
class AlleyPuzzles {
  static const String bookId = 'nebelheim_map';

  static PuzzleModel getForAlley(int alley, bool isEn) {
    switch (alley) {
      case 1:
        return PuzzleModel(
          id: 'alley_1',
          title: isEn ? 'Puzzle 1: Cat Footprints' : 'Puzzle 1: Huellas del Gato',
          statement: isEn
              ? 'EXCLUSIVE PUZZLE — Cat Alley: The black cat leaves exactly 2 paw prints every 4 tiles. Four trails, only one is really his. Which trail belongs to the cat? (visual puzzle, not riddle)'
              : 'PUZZLE EXCLUSIVO — Callejón del Gato: El gato negro deja exactamente 2 huellas cada 4 losas. Hay cuatro rastros y solo uno es realmente suyo. ¿Qué rastro es del gato? (puzzle visual, no acertijo)',
          experiencia: 20,
          correctAnswer: isEn ? 'Trail 2' : 'Rastro 2',
          hintText: isEn ? 'Count paws per trail.' : 'Cuenta huellas por rastro.',
          hints: isEn
              ? ['Count the prints of each trail.', 'Only one trail has exactly 2 prints.', 'Trail 2 — exclusive map puzzle.']
              : ['Cuenta las huellas de cada rastro.', 'Solo un rastro tiene exactamente 2 huellas.', 'Rastro 2 — puzzle exclusivo mapa.'],
          type: PuzzleType.visualChoice,
          options: isEn
              ? ['Trail 1', 'Trail 2', 'Trail 3', 'Trail 4']
              : ['Rastro 1', 'Rastro 2', 'Rastro 3', 'Rastro 4'],
          visualKind: 'cat_footprints',
          visualPayload: 'cat_footprints',
        );
      case 2:
        return PuzzleModel(
          id: 'alley_2',
          title: isEn ? 'Puzzle 2: Moon Phases' : 'Puzzle 2: Fases Lunares',
          statement: isEn
              ? 'EXCLUSIVE PUZZLE — Moon Alley: Five nights in a row over Nebelheim, but one phase has been erased from the sky. Look at the order and tell: which phase is missing from the gap? (visual puzzle)'
              : 'PUZZLE EXCLUSIVO — Callejón de la Luna: Cinco noches seguidas sobre Nebelheim, pero una fase se ha borrado del cielo. Mira el orden y dime: ¿qué fase falta en el hueco? (puzzle visual)',
          experiencia: 25,
          correctAnswer: '🌓',
          hintText: isEn ? 'New, crescent, …?' : 'Nueva, creciente, …?',
          hints: isEn
              ? ['Order is new→crescent→quarter→gibbous→full.', 'The gap is the third night.', '🌓 — exclusive.']
              : ['Orden: nueva→creciente→cuarto→gibosa→llena.', 'El hueco es la tercera noche.', '🌓 — exclusivo.'],
          type: PuzzleType.visualChoice,
          options: ['🌕', '🌑', '🌓', '🌗'],
          visualKind: 'moon_phases',
          visualPayload: 'moon_phases',
        );
      case 3:
        return PuzzleModel(
          id: 'alley_3',
          title: isEn ? 'Puzzle 3: Rune Memory' : 'Puzzle 3: Runas de Memoria',
          statement: isEn
              ? 'PUZZLE EXCLUSIVO — Oblivion Alley: Anselm carved 4 runes ᛉᛊᛏᛒ. One is mirrored. Which rune is inverted? (visual memory puzzle)'
              : 'PUZZLE EXCLUSIVO — Callejón del Olvido: Anselm talló 4 runas ᛉᛊᛏᛒ. Una está espejada. ¿Qué runa está invertida? (puzzle visual memoria)',
          experiencia: 15,
          correctAnswer: 'ᛊ',
          hintText: isEn ? 'Look at the mirrored curve.' : 'Mira la curva espejada.',
          hints: isEn
              ? ['Three face right.', 'One faces left: ᛊ.', 'ᛊ — exclusive.']
              : ['Tres miran a la derecha.', 'Una mira a la izquierda: ᛊ.', 'ᛊ — exclusivo.'],
          type: PuzzleType.visualChoice,
          options: ['ᛉ', 'ᛊ', 'ᛏ', 'ᛒ'],
          visualKind: 'memory_runes',
          visualPayload: 'memory_runes',
        );
      case 4:
        return PuzzleModel(
          id: 'alley_4',
          title: isEn ? 'Puzzle 4: River Pipes' : 'Puzzle 4: Tuberías del Río',
          statement: isEn
              ? 'EXCLUSIVE PUZZLE — River Alley: Water enters from the left. Four pipes A–D cross the river, but only one carries water from side to side with no gaps and no crossings. Which pipe has flow? (spatial puzzle)'
              : 'PUZZLE EXCLUSIVO — Callejón del Río: El agua entra por la izquierda. Cuatro tuberías A–D cruzan el río, pero solo una lleva el agua de lado a lado sin cortes ni cruces. ¿Qué tubería tiene flujo? (puzzle espacial)',
          experiencia: 20,
          correctAnswer: isEn ? 'Pipe B' : 'Tubería B',
          hintText: isEn ? 'Follow each pipe from left to right.' : 'Sigue cada tubería de izquierda a derecha.',
          hints: isEn
              ? ['Blue means water is flowing.', 'Only one pipe arrives whole.', 'Pipe B — exclusive.']
              : ['Azul significa que el agua fluye.', 'Solo una tubería llega entera.', 'Tubería B — exclusivo.'],
          type: PuzzleType.visualChoice,
          options: isEn
              ? ['Pipe A', 'Pipe B', 'Pipe C', 'Pipe D']
              : ['Tubería A', 'Tubería B', 'Tubería C', 'Tubería D'],
          visualKind: 'river_pipes',
          visualPayload: 'river_pipes',
        );
      case 5:
        return PuzzleModel(
          id: 'alley_5',
          title: isEn ? 'Puzzle 5: Shadow Match' : 'Puzzle 5: Sombra Exacta',
          statement: isEn
              ? 'EXCLUSIVE PUZZLE — Shadow Alley: The cat up top casts four numbered shadows, but only one is pixel-perfect identical: same ears, same tail, same size. Which numbered shadow matches? (visual matching puzzle)'
              : 'PUZZLE EXCLUSIVO — Callejón de la Sombra: El gato de arriba proyecta cuatro sombras numeradas, pero solo una es idéntica píxel a píxel: mismas orejas, misma cola, mismo tamaño. ¿Qué sombra numerada coincide? (puzzle visual)',
          experiencia: 25,
          correctAnswer: isEn ? 'Shadow 2' : 'Sombra 2',
          hintText: isEn ? 'Compare ears, tail and size one by one.' : 'Compara orejas, cola y tamaño una por una.',
          hints: isEn
              ? ['One is mirrored, one is bigger, one is tilted.', 'Only shadow 2 is identical.', 'Shadow 2 — exclusive.']
              : ['Una está espejada, otra es más grande, otra está ladeada.', 'Solo la sombra 2 es idéntica.', 'Sombra 2 — exclusivo.'],
          type: PuzzleType.visualChoice,
          options: isEn
              ? ['Shadow 1', 'Shadow 2', 'Shadow 3', 'Shadow 4']
              : ['Sombra 1', 'Sombra 2', 'Sombra 3', 'Sombra 4'],
          visualKind: 'shadow_match',
          visualPayload: 'shadow_match',
        );
      case 6:
        return PuzzleModel(
          id: 'alley_6',
          title: isEn ? 'Puzzle 6: Wind Compass' : 'Puzzle 6: Brújula del Viento',
          statement: isEn
              ? 'EXCLUSIVE PUZZLE — Wind Alley: The tower vane points WEST, but the wind always blows FROM the opposite side to where the vane points. Thinking carefully: from which direction is the wind blowing? (orientation puzzle)'
              : 'PUZZLE EXCLUSIVO — Callejón del Viento: La veleta de la torre apunta al OESTE, pero el viento siempre sopla DESDE el lado contrario al que apunta la veleta. Piensa bien: ¿desde qué dirección sopla el viento? (puzzle orientación)',
          experiencia: 20,
          correctAnswer: 'E',
          hintText: isEn ? 'The vane points one way; wind comes from the other.' : 'La veleta apunta a un lado; el viento viene del otro.',
          hints: isEn
              ? ['The vane points W.', 'Wind comes FROM the opposite side.', 'Opposite of W is E — exclusive.']
              : ['La veleta apunta al O.', 'El viento viene del lado contrario.', 'Lo contrario de O es E — exclusivo.'],
          type: PuzzleType.visualChoice,
          options: isEn ? ['N', 'S', 'E', 'W'] : ['N', 'S', 'E', 'O'],
          visualKind: 'wind_compass',
          visualPayload: 'wind_compass',
        );
      case 7:
        return PuzzleModel(
          id: 'alley_7',
          title: isEn ? 'Puzzle 7: Village Wheel' : 'Puzzle 7: Rueda de la Villa',
          statement: isEn
              ? 'EXCLUSIVE PUZZLE — Villa Plan: Opposite alleys on the wheel always add up to 10. One number on the wheel is missing. Look at the opposites and tell: which number is missing? (spatial puzzle)'
              : 'PUZZLE EXCLUSIVO — Plano Villa: Los callejones opuestos de la rueda siempre suman 10 entre sí. Falta un número en la rueda. Mira los opuestos y dime: ¿qué número falta? (puzzle espacial)',
          experiencia: 15,
          correctAnswer: '7',
          hintText: isEn ? 'Opposites add to 10.' : 'Los opuestos suman 10.',
          hints: isEn
              ? ['1+9=10, 2+8=10, 4+6=10…', 'The gap faces 3.', '3+7=10 — exclusive.']
              : ['1+9=10, 2+8=10, 4+6=10…', 'El hueco está frente al 3.', '3+7=10 — exclusivo.'],
          type: PuzzleType.visualChoice,
          options: ['7', '5', '9', '4'],
          visualKind: 'village_wheel',
          visualPayload: 'village_wheel',
        );
      case 8:
        return PuzzleModel(
          id: 'alley_8',
          title: isEn ? 'Puzzle 8: Tower Gears' : 'Puzzle 8: Engranajes de la Torre',
          statement: isEn
              ? 'PUZZLE EXCLUSIVO — Tower: 3 gears linked. Big gear 12 teeth drives middle 10. How many teeth must the small gear have to close the loop at 10:10? (mechanical puzzle, not clock math)'
              : 'PUZZLE EXCLUSIVO — Torre: 3 engranajes enlazados. El grande 12 dientes mueve el mediano 10. ¿Cuántos dientes debe tener el pequeño para cerrar el ciclo a las 10:10? (puzzle mecánico, no cálculo horario)',
          experiencia: 30,
          correctAnswer: '8',
          hintText: isEn ? 'Teeth ratio must match.' : 'Relación de dientes debe cuadrar.',
          hints: isEn
              ? ['12-10-? must mesh.', 'Small needs 8 to close.', '8 — exclusive tower puzzle.']
              : ['12-10-? deben engranar.', 'Pequeño necesita 8.', '8 — puzzle torre exclusivo.'],
          type: PuzzleType.visualChoice,
          options: ['8', '12', '10', '6'],
          visualKind: 'tower_gears',
          visualPayload: 'tower_gears',
        );
      default:
        final clamped = alley.clamp(1, 8);
        return getForAlley(clamped, isEn);
    }
  }

  static List<PuzzleModel> allForLocale(bool isEn) =>
      List.generate(8, (i) => getForAlley(i + 1, isEn));

  /// Camino alternativo del callejón: tras 3 fallos Watson reduce las
  /// opciones a 2 (un distractor + la correcta) para poder seguir intentando.
  /// Mismo id para no duplicar progreso; misma respuesta correcta.
  static PuzzleModel branchForAlley(int alley, bool isEn) {
    final base = getForAlley(alley, isEn);
    final correct = base.correctAnswer.trim().toLowerCase();
    final wrong = base.options.firstWhere(
      (o) => o.trim().toLowerCase() != correct,
      orElse: () => base.options.first,
    );
    return PuzzleModel(
      id: base.id,
      title: base.title,
      statement: base.statement,
      experiencia: base.experiencia,
      correctAnswer: base.correctAnswer,
      hintText: base.hintText,
      hints: base.hints,
      type: base.type,
      options: [wrong, base.correctAnswer],
      visualKind: base.visualKind,
      visualPayload: base.visualPayload,
    );
  }
}
