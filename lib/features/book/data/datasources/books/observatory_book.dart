import '../../../../puzzle/data/datasources/puzzle_local_data_source.dart';
import '../../../../puzzle/data/models/puzzle_model.dart';
import '../../../../puzzle/domain/entities/puzzle.dart';
import '../../../domain/entities/book_page.dart';
import '../../../domain/entities/story_book.dart';

/// Libro 4 · Etapa 4 (final): "La Estrella del Observatorio".
/// 10 páginas. Acertijos clásicos distintos + 3 visuales (2 nuevos y la cuadrícula 4×4).
Future<StoryBook> buildObservatoryBook(
    PuzzleLocalDataSource classic) async {
  final all = await classic.getAllPuzzles();
  Puzzle byId(String id) => all.firstWhere((p) => p.id == id);

  final pages = [
    BookPage(
      pageNumber: 1, collectibleId: 'observatory-1',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La noche del cometa',
      storyTitle: 'Cumbre Estrellada',
      storyText:
          'Holmes y yo subimos al observatorio de Cumbre Estrellada la noche en que el cometa Azul vuelve tras cien años. '
          'Pero la astrónoma Vega nos recibió con malas noticias: han robado la lente principal y la carta estelar del cometa. '
          '"Sin la lente, un siglo de espera se pierde", sollozó. Holmes miró al cielo: "Entonces no perdamos ni un minuto".',
      puzzle: byId('049'),
    ),
    BookPage(
      pageNumber: 2, collectibleId: 'observatory-2',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La noche del cometa',
      storyTitle: 'El saco de harina del refugio',
      storyText:
          'En el refugio de montaña solo quedaba un saco de harina para cenar, y el cocinero discutía con su ayudante sobre cuánto pesaba en realidad. '
          'Con el estómago rugiendo, propuse resolverlo antes de cocinar. "Un detective piensa mejor con la cena en camino", rio Holmes.',
      puzzle: byId('050'),
    ),
    BookPage(
      pageNumber: 3, collectibleId: 'observatory-3',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La noche del cometa',
      storyTitle: 'Dados bajo las estrellas',
      storyText:
          'El joven aprendiz del observatorio mataba el tiempo lanzando dados mientras vigilaba el telescopio la noche del robo. '
          'Juraba que vio una sombra junto a la cúpula justo al lanzar su tirada más probable. Holmes le pidió que repitiera la tirada: '
          '"El azar también deja huellas, muchacho".',
      puzzle: byId('052'),
    ),
    BookPage(
      pageNumber: 4, collectibleId: 'observatory-4',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La noche del cometa',
      storyTitle: 'Las monedas del planetario',
      storyText:
          'En el planetario mecánico, dos monedas atascadas bloqueaban el engranaje de Saturno. El mecanismo, valorado en una fortuna, se detuvo con las monedas dentro. '
          'El bedel aseguró que una de ellas "no es" de un valor concreto. Fruncí el ceño hasta que Holmes tradujo el truco de palabras.',
      puzzle: byId('055'),
    ),
    BookPage(
      pageNumber: 5, collectibleId: 'observatory-5',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La noche del cometa',
      storyTitle: 'La balanza del astrónomo (VISUAL)',
      storyText:
          'Vega pesaba meteoritos en su balanza de precisión: en un platillo colocó sus muestras y en el otro solo pesas de 3 kilos. '
          'La aguja tembló y se quedó clavada en el centro. "Si la balanza no miente, la lente sigue en la montaña", dedujo Holmes. '
          'Coloqué las pesas conteniendo la respiración.',
      puzzle: const PuzzleModel(
        id: 'O05',
        title: 'Puzle 5: Meteoritos en equilibrio',
        statement:
            'Mira la balanza: en un lado hay 2 pesas de 5 kg y 2 pesas de 1 kg. ¿Cuántas pesas de 3 kg necesitas en el otro lado para equilibrarla?',
        experiencia: 25,
        correctAnswer: '4',
        hintText: 'El otro lado pesa 2×5 + 2×1 = 12 kg.',
        type: PuzzleType.visualChoice,
        options: ['3', '4', '5', '6'],
        visualKind: 'balance',
        visualPayload: '2×5kg + 2×1kg|? × 3kg',
      ),
    ),
    BookPage(
      pageNumber: 6, collectibleId: 'observatory-6',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El cometa Azul',
      storyTitle: 'La rueda del funicular',
      storyText:
          'Para registrar la cima antes del amanecer usamos el funicular con su rueda de repuesto, rotando los neumáticos del vagón en cada viaje. '
          'El maquinista, famoso por sus enigmas, no arrancaba hasta que alguien calculara el desgaste. Hice la cuenta con los dedos entumecidos.',
      puzzle: byId('056'),
    ),
    BookPage(
      pageNumber: 7, collectibleId: 'observatory-7',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El cometa Azul',
      storyTitle: 'La serie de la cúpula',
      storyText:
          'La cúpula giraba siguiendo una serie numérica grabada por el fundador: cuadrados perfectos que marcan cada constelación. '
          'Pero la serie se interrumpía justo en la constelación del Cometa. Vega palideció: "Alguien manipuló la cúpula". '
          'Holmes completó la serie de un trazo.',
      puzzle: byId('063'),
    ),
    BookPage(
      pageNumber: 8, collectibleId: 'observatory-8',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El cometa Azul',
      storyTitle: 'La cantina del telescopio',
      storyText:
          'En la cantina, el aprendiz discutía con el cocinero por el precio de una botella con su tapón de corcho centenario. '
          'La discusión escondía una pista: el ticket de compra del ladrón, con la misma cuenta imposible. '
          '"Los números pequeños esconden a los grandes culpables", murmuró Holmes guardando el ticket.',
      puzzle: byId('065'),
    ),
    BookPage(
      pageNumber: 9, collectibleId: 'observatory-9',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El cometa Azul',
      storyTitle: 'El friso de las constelaciones (VISUAL)',
      storyText:
          'Tras el telescopio apareció un friso con estrellas y lunas que parpadeaban en secuencia. Era la cerradura de la cámara donde escondieron la lente. '
          '"El mismo truco que en Nebelheim, pero con cielo nocturno", recordé emocionado. Las lentes de la cámara reflejaban mi rostro expectante.',
      puzzle: const PuzzleModel(
        id: 'O09',
        title: 'Puzle 9: El friso nocturno',
        statement:
            'Observa la secuencia: ★ ● ★ ● ★ … ¿Qué figura debe ir en sexto lugar para completar el patrón?',
        experiencia: 25,
        correctAnswer: '●',
        hintText: 'El patrón alterna estrella y círculo: ★ ● ★ ●…',
        type: PuzzleType.visualChoice,
        options: ['★', '●', '■', '▲'],
        visualKind: 'shapes_sequence',
        visualPayload: '★,●,★,●,★,?',
      ),
    ),
    BookPage(
      pageNumber: 10, collectibleId: 'observatory-10',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El cometa Azul',
      storyTitle: 'El mosaico del firmamento (VISUAL FINAL)',
      storyText:
          'La cámara se abrió: ¡la lente estaba allí, escondida por el propio fundador para protegerla de un coleccionista sin escrúpulos, desenmascarado al fin! '
          'Solo faltaba calibrar el mosaico del suelo del observatorio, una cuadrícula de 4×4, antes de que el cometa Azul cruzara el cielo. '
          'Vega contenía el aliento. Holmes colocó la lente. Conté en voz alta. Y entonces… la luz del cometa inundó la cúpula.',
      puzzle: const PuzzleModel(
        id: 'O10',
        title: 'Puzle 10: El firmamento completo',
        statement:
            'Observa la cuadrícula de 4×4 del suelo. ¿Cuántos cuadrados de todos los tamaños hay en total (1×1, 2×2, 3×3 y 4×4)?',
        experiencia: 50,
        correctAnswer: '30',
        hintText: 'Suma 16 + 9 + 4 + 1.',
        type: PuzzleType.visualChoice,
        options: ['16', '24', '29', '30'],
        visualKind: 'grid_squares',
        visualPayload: '4x4',
      ),
    ),
  ];

  return StoryBook(
    id: 'observatory',
    stage: 4,
    title: 'La Estrella del Observatorio',
    subtitle: 'Etapa 4 · Final: la noche del cometa',
    description:
        'El cometa Azul vuelve tras cien años, pero alguien ha robado la lente. La etapa final: estrellas, cúpulas y un cielo que no puede esperar.',
    coverKey: 'observatory',
    colorValue: 0xFF1A237E,
    pages: pages,
  );
}
