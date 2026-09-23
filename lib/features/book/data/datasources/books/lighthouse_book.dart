import '../../../../puzzle/data/datasources/puzzle_local_data_source.dart';
import '../../../../puzzle/data/models/puzzle_model.dart';
import '../../../../puzzle/domain/entities/puzzle.dart';
import '../../../domain/entities/book_page.dart';
import '../../../domain/entities/story_book.dart';

/// Libro 2 · Etapa 2: "El Faro de las Mareas Perdidas".
/// 10 páginas. Acertijos clásicos distintos a los del libro 1 + 1 visual nuevo.
Future<StoryBook> buildLighthouseBook(
    PuzzleLocalDataSource classic) async {
  final all = await classic.getAllPuzzles();
  Puzzle byId(String id) => all.firstWhere((p) => p.id == id);

  final pages = [
    BookPage(
      pageNumber: 1, collectibleId: 'lighthouse-1',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La luz apagada',
      storyTitle: 'Marealta sin faro',
      storyText:
          'Tras el caso de Nebelheim, Holmes y yo viajamos a Marealta, un pueblo pesquero donde el faro lleva una semana apagado. '
          'Los barcos dan rodeos temerosos y los pescadores murmuran sobre "la marea que se llevó al torrero Tomás". '
          'En el muelle, una gaviota nos dejó caer una moneda falsa a los pies. Holmes la recogió con dos dedos: "Nada es casual, Watson. Empecemos por pesar la verdad".',
      puzzle: byId('007'),
    ),
    BookPage(
      pageNumber: 2, collectibleId: 'lighthouse-2',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La luz apagada',
      storyTitle: 'La cuerda del muelle',
      storyText:
          'El cabo del puerto nos mostró la cuerda del embarcadero, cortada en varios puntos durante la tormenta. '
          '"Fue la noche en que Tomás desapareció", aseguró. Conté los cortes con el dedo mientras Holmes observaba las marcas: '
          'los cortes eran limpios, de navaja, no de temporal. "La tormenta no usa cuchillos, Watson", sentenció.',
      puzzle: byId('008'),
    ),
    BookPage(
      pageNumber: 3, collectibleId: 'lighthouse-3',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La luz apagada',
      storyTitle: 'Cuatro gorros de lana',
      storyText:
          'En la taberna "La Sirena", cuatro marineros con gorros de lana discutían sobre quién vio al torrero por última vez. '
          'Dos gorros son blancos y dos negros, pero la taberna está a oscuras por el apagón. El tabernero propuso un juego para refrescar memorias: '
          '"El que deduzca su color, invita a la ronda". Holmes sonrió: un enigma de sombreros nunca falla.',
      puzzle: byId('003'),
    ),
    BookPage(
      pageNumber: 4, collectibleId: 'lighthouse-4',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La luz apagada',
      storyTitle: 'La vela del torrero',
      storyText:
          'Subimos al faro con una sola caja de cerillas. La escalera de caracol estaba helada y la lámpara principal, la vela de señales y el brasero '
          'aguardaban apagados. "Solo tenemos una cerilla intacta", advertí tiritando. Holmes la protegió del viento con su gorra de cazador: '
          '"Entonces habrá que elegir bien el primer fuego, como en todo caso".',
      puzzle: byId('004'),
    ),
    BookPage(
      pageNumber: 5, collectibleId: 'lighthouse-5',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La luz apagada',
      storyTitle: 'El mosaico de caracolas (VISUAL)',
      storyText:
          'En la sala de la lámpara encontramos un mosaico de caracolas que Tomás colocaba cada noche: cuatro figuras casi idénticas, pero una rompe el patrón. '
          '"El torrero marcaba así las noches sin incidentes", dedujo Holmes. "Encuentre la distinta y sabremos qué noche falló". '
          'Las caracolas brillaban bajo la linterna como pequeñas lunas.',
      puzzle: const PuzzleModel(
        id: 'F05',
        title: 'Puzle 5: La caracola distinta',
        statement:
            'Observa las 4 figuras del mosaico. Tres son iguales y una es diferente. ¿Cuál es la figura distinta? Escríbela.',
        experiencia: 25,
        correctAnswer: '▲',
        hintText: 'Compara una a una: círculo, círculo… ¿y la tercera?',
        type: PuzzleType.visualChoice,
        options: ['●', '▲', '■', '★'],
        visualKind: 'odd_one_out',
        visualPayload: '●,●,▲,●',
      ),
    ),
    BookPage(
      pageNumber: 6, collectibleId: 'lighthouse-6',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La Marea del contrabando',
      storyTitle: 'El padre y el grumete',
      storyText:
          'Un viejo lobo de mar confesó entre sollozos: su hijo, grumete del último barco, discutió con Tomás por unas cajas "que pesaban demasiado para llevar pescado". '
          'Holmes anotó las edades que el hombre mencionó entre lágrimas y descubrió que los números no cuadraban. '
          '"Las mentiras también envejecen mal, Watson. Hagamos cuentas".',
      puzzle: byId('009'),
    ),
    BookPage(
      pageNumber: 7, collectibleId: 'lighthouse-7',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La Marea del contrabando',
      storyTitle: 'El gato del faro',
      storyText:
          'El gato del faro, "Brújula", apareció maullando junto a un muro de tres metros que separa el faro del acantilado. '
          'Cada día intenta saltarlo para volver con Tomás. Lo animé con un trozo de pescado: "¡Tú puedes, Brújula!". '
          'Holmes calculó en su libreta cuántos intentos necesitará el valiente felino.',
      puzzle: byId('010'),
    ),
    BookPage(
      pageNumber: 8, collectibleId: 'lighthouse-8',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La Marea del contrabando',
      storyTitle: 'Los tres interruptores del sótano',
      storyText:
          'Bajo el faro hay un sótano con tres interruptores y, arriba, la sala de la lámpara con una sola bombilla de repuesto. '
          'Los contrabandistas usaban el sótano de almacén y solo se puede subir una vez sin hacer ruido. '
          '"Dos de estos interruptores son nuestro faro improvisado", murmuró Holmes girando la llave inglesa.',
      puzzle: byId('005'),
    ),
    BookPage(
      pageNumber: 9, collectibleId: 'lighthouse-9',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La Marea del contrabando',
      storyTitle: 'Doce meses de niebla',
      storyText:
          'Atrapados, los contrabandistas confesaron: apagaban el faro las noches de luna nueva para desembarcar sin ser vistos, y Tomás los descubrió. '
          'Lo encerraron en la cueva de las mareas. "¿Cuántas lunas nuevas hubo este año?", pregunté consultando el calendario del torrero, '
          'lleno de marcas circulares.',
      puzzle: byId('069'),
    ),
    BookPage(
      pageNumber: 10, collectibleId: 'lighthouse-10',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La Marea del contrabando',
      storyTitle: 'La luz vuelve a casa',
      storyText:
          'Liberamos a Tomás de la cueva justo cuando dos barcos —el de los pescadores y el de la guardia costera— navegaban hacia el faro a toda máquina. '
          'Holmes encendió la lámpara de repuesto y su haz barrió la niebla. "Calcule la distancia, deprisa", gritó al torrero, '
          'que rio por primera vez en una semana mientras giraba la lente hacia el mar.',
      puzzle: byId('096'),
    ),
  ];

  return StoryBook(
    id: 'lighthouse',
    stage: 2,
    title: 'El Faro de las Mareas Perdidas',
    subtitle: 'Etapa 2 · Misterio en la costa',
    description:
        'El faro de Marealta se ha apagado y el torrero ha desaparecido. Contrabando, mareas y una luz que debe volver a casa.',
    coverKey: 'lighthouse',
    colorValue: 0xFF01579B,
    pages: pages,
  );
}
