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
      pageNumber: 1,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La luz apagada',
      storyTitle: 'Marealta sin faro',
      storyText:
          'Tras el caso de Nebelheim, Layton y Luke viajan a Marealta, un pueblo pesquero donde el faro lleva una semana apagado. '
          'Los barcos dan rodeos temerosos y los pescadores murmuran sobre "la marea que se llevó al torrero Tomás". '
          'En el muelle, una gaviota les deja caer una moneda falsa a los pies. Layton la recoge: "Nada es casual, Luke. Empecemos por pesar la verdad".',
      puzzle: byId('007'),
    ),
    BookPage(
      pageNumber: 2,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La luz apagada',
      storyTitle: 'La cuerda del muelle',
      storyText:
          'El cabo del puerto les muestra la cuerda del embarcadero, cortada en varios puntos durante la tormenta. '
          '"Fue la noche en que Tomás desapareció", asegura. Luke cuenta los cortes con el dedo mientras el profesor observa las marcas: '
          'los cortes son limpios, de navaja, no de temporal. "La tormenta no usa cuchillos, muchacho", sentencia Layton.',
      puzzle: byId('008'),
    ),
    BookPage(
      pageNumber: 3,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La luz apagada',
      storyTitle: 'Cuatro gorros de lana',
      storyText:
          'En la taberna "La Sirena", cuatro marineros con gorros de lana discuten sobre quién vio al torrero por última vez. '
          'Dos gorros son blancos y dos negros, pero la taberna está a oscuras por el apagón. El tabernero propone un juego para refrescar memorias: '
          '"El que deduzca su color, invita a la ronda". Layton sonríe: un enigma de sombreros nunca falla.',
      puzzle: byId('003'),
    ),
    BookPage(
      pageNumber: 4,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La luz apagada',
      storyTitle: 'La vela del torrero',
      storyText:
          'Suben al faro con una sola caja de cerillas. La escalera de caracol está helada y la lámpara principal, la vela de señales y el brasero '
          'aguardan apagados. "Solo tenemos una cerilla intacta", advierte Luke temblando. Layton la protege del viento con el sombrero: '
          '"Entonces habrá que elegir bien el primer fuego, como en todo misterio".',
      puzzle: byId('004'),
    ),
    BookPage(
      pageNumber: 5,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La luz apagada',
      storyTitle: 'El mosaico de caracolas (VISUAL)',
      storyText:
          'En la sala de la lámpara encuentran un mosaico de caracolas que Tomás colocaba cada noche: cuatro figuras casi idénticas, pero una rompe el patrón. '
          '"El torrero marcaba así las noches sin incidentes", deduce Layton. "Encuentra la distinta y sabremos qué noche falló". '
          'Las caracolas brillan bajo la linterna como pequeñas lunas.',
      puzzle: const PuzzleModel(
        id: 'F05',
        title: 'Puzle 5: La caracola distinta',
        statement:
            'Observa las 4 figuras del mosaico. Tres son iguales y una es diferente. ¿Cuál es la figura distinta? Escríbela.',
        Picarats: 25,
        correctAnswer: '▲',
        hintText: 'Compara una a una: círculo, círculo… ¿y la tercera?',
        type: PuzzleType.visualChoice,
        options: ['●', '▲', '■', '★'],
        visualKind: 'odd_one_out',
        visualPayload: '●,●,▲,●',
      ),
    ),
    BookPage(
      pageNumber: 6,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La Marea del contrabando',
      storyTitle: 'El padre y el grumete',
      storyText:
          'Un viejo lobo de mar confiesa entre sollozos: su hijo, grumete del último barco, discutió con Tomás por unas cajas "que pesaban demasiado para llevar pescado". '
          'Layton anota las edades que el hombre menciona entre lágrimas y descubre que los números no cuadran. '
          '"Las mentiras también envejecen mal, Luke. Hagamos cuentas".',
      puzzle: byId('009'),
    ),
    BookPage(
      pageNumber: 7,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La Marea del contrabando',
      storyTitle: 'El gato del faro',
      storyText:
          'El gato del faro, "Brújula", aparece maullando junto a un muro de tres metros que separa el faro del acantilado. '
          'Cada día intenta saltarlo para volver con Tomás. Luke lo anima con un trozo de pescado: "¡Tú puedes, Brújula!". '
          'Layton calcula en su libreta cuántos intentos necesitará el valiente felino.',
      puzzle: byId('010'),
    ),
    BookPage(
      pageNumber: 8,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La Marea del contrabando',
      storyTitle: 'Los tres interruptores del sótano',
      storyText:
          'Bajo el faro hay un sótano con tres interruptores y, arriba, la sala de la lámpara con una sola bombilla de repuesto. '
          'Los contrabandistas usaban el sótano de almacén y solo se puede subir una vez sin hacer ruido. '
          '"Dos de estos interruptores son nuestro faro improvisado", murmura Layton girando la llave inglesa.',
      puzzle: byId('005'),
    ),
    BookPage(
      pageNumber: 9,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La Marea del contrabando',
      storyTitle: 'Doce meses de niebla',
      storyText:
          'Atrapados, los contrabandistas confiesan: apagaban el faro las noches de luna nueva para desembarcar sin ser vistos, y Tomás los descubrió. '
          'Lo encerraron en la cueva de las mareas. "¿Cuántas lunas nuevas hubo este año?", pregunta Luke consultando el calendario del torrero, '
          'lleno de marcas circulares.',
      puzzle: byId('069'),
    ),
    BookPage(
      pageNumber: 10,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La Marea del contrabando',
      storyTitle: 'La luz vuelve a casa',
      storyText:
          'Liberan a Tomás de la cueva justo cuando dos barcos —el de los pescadores y el de la guardia costera— navegan hacia el faro a toda máquina. '
          'Layton enciende la lámpara de repuesto y su haz barre la niebla. "Calculad la distancia, deprisa", grita al torrero, '
          'que ríe por primera vez en una semana mientras gira la lente hacia el mar.',
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
