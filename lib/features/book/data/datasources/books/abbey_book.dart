import '../../../../puzzle/data/datasources/puzzle_local_data_source.dart';
import '../../../../puzzle/data/models/puzzle_model.dart';
import '../../../../puzzle/domain/entities/puzzle.dart';
import '../../../domain/entities/book_page.dart';
import '../../../domain/entities/story_book.dart';

/// Libro 6 · Etapa 6: "La Abadía de los Susurros".
/// 15 páginas. Acertijos clásicos distintos + 2 visuales.
Future<StoryBook> buildAbbeyBook(PuzzleLocalDataSource classic) async {
  final all = await classic.getAllPuzzles();
  Puzzle byId(String id) => all.firstWhere((p) => p.id == id);

  final pages = [
    BookPage(
      pageNumber: 1, collectibleId: 'abbey-1',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La galería que susurra',
      storyTitle: 'Niebla en el claustro',
      storyText:
          'Un abad nos llamó a su abadía en ruinas: cada noche, la galería susurra un nombre y ha desaparecido el relicario del coro. '
          'Llegamos entre la niebla mientras las campanas tocaban a vísperas. Holmes pegó el oído a la piedra milenaria y sonrió: "La arquitectura también confiesa, Watson".',
      puzzle: byId('046'),
    ),
    BookPage(
      pageNumber: 2, collectibleId: 'abbey-2',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La galería que susurra',
      storyTitle: 'El pescador del estanque',
      storyText:
          'El hermano portero pescaba en el estanque de la abadía y juraba haber pescado peces imposibles la noche del robo: peces sin cabeza, sin lomo y sin cola. '
          'Le pedí que me los mostrara y vació su cesta entre risas. Holmes contó las piezas con la lupa.',
      puzzle: byId('059'),
    ),
    BookPage(
      pageNumber: 3, collectibleId: 'abbey-3',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La galería que susurra',
      storyTitle: 'Los hermanos del coro',
      storyText:
          'Seis hermanos del coro declararon ante el abad, y cada uno afirmó tener la misma hermana entre las novicias del convento vecino. '
          'El prior sospechaba una conspiración de familia. Holmes sumó parentescos en su libreta y deshizo el nudo en voz alta.',
      puzzle: byId('060'),
    ),
    BookPage(
      pageNumber: 4, collectibleId: 'abbey-4',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La galería que susurra',
      storyTitle: 'El cubo del albañil',
      storyText:
          'El albañil restauraba un cubo de piedra de 3×3×3 pintado de rojo que coronaba el pozo, y discutía con su aprendiz cuántos sillares tenían dos caras pintadas. '
          'Holmes resolvió la disputa de un vistazo y el aprendiz, agradecido, nos habló de pasos nocturnos hacia la cripta.',
      puzzle: byId('062'),
    ),
    BookPage(
      pageNumber: 5, collectibleId: 'abbey-5',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La galería que susurra',
      storyTitle: 'La mosca del vitral',
      storyText:
          'Una mosca recorría el borde del vitral cuadrado de la capilla, de diez centímetros de lado, dando una vuelta completa ante nuestros ojos. '
          'El hermano vidriero, que la observaba cada tarde, preguntó qué distancia caminaba el insecto. Medí el vitral con mi bastón.',
      puzzle: byId('066'),
    ),
    BookPage(
      pageNumber: 6, collectibleId: 'abbey-6',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El manuscrito robado',
      storyTitle: 'El rosetón distinto (VISUAL)',
      storyText:
          'El rosetón del coro mostraba cuatro vidrieras casi idénticas que el ladrón había tocado: tres iguales y una distinta marcaba el salmo robado. '
          'La luz del atardecer teñía la piedra de colores. "Encuentre la distinta, Watson, y sabremos qué salmo falta", dijo Holmes.',
      puzzle: const PuzzleModel(
        id: 'A06',
        title: 'Puzle 6: La vidriera distinta',
        statement:
            'Observa las 4 figuras del rosetón. Tres son iguales y una es diferente. ¿Cuál es la figura distinta? Escríbela.',
        experiencia: 25,
        correctAnswer: '★',
        hintText: 'Compara una a una: cuadrado, cuadrado… ¿y la tercera?',
        type: PuzzleType.visualChoice,
        options: ['●', '▲', '■', '★'],
        visualKind: 'odd_one_out',
        visualPayload: '■,■,★,■',
      ),
    ),
    BookPage(
      pageNumber: 7, collectibleId: 'abbey-7',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El manuscrito robado',
      storyTitle: 'Las arcas del prior',
      storyText:
          'El prior guardaba las limosnas en cinco arcas grandes con cofrecillos medianos dentro, y aseguraba que las cuentas no cuadraban tras el robo. '
          'Conté arcas y cofrecillos con él mientras Holmes examinaba la cerradura de la sacristía: forzada desde dentro.',
      puzzle: byId('068'),
    ),
    BookPage(
      pageNumber: 8, collectibleId: 'abbey-8',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El manuscrito robado',
      storyTitle: 'El carro del hortelano',
      storyText:
          'El hortelano recorría sesenta kilómetros con su carro a paso constante para vender las coles del convento, y discutía con el abad sobre el ritmo del viaje. '
          'Cronometré una legua con mi reloj mientras Holmes interrogaba al novicio que vio una sombra en el huerto a medianoche.',
      puzzle: byId('071'),
    ),
    BookPage(
      pageNumber: 9, collectibleId: 'abbey-9',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El manuscrito robado',
      storyTitle: 'Las monedas del cepillo',
      storyText:
          'El cepillo de las limosnas contenía cuatro monedas en fila que alguien había reordenado para ocultar el robo del relicario. '
          'El hermano ecónomo juraba que el orden anterior era el inverso exacto. Holmes invirtió la fila con dos movimientos de dedos.',
      puzzle: byId('073'),
    ),
    BookPage(
      pageNumber: 10, collectibleId: 'abbey-10',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El manuscrito robado',
      storyTitle: 'El paseo del fantasma',
      storyText:
          'El "fantasma" paseaba cada noche tres kilómetros al norte, cuatro al este y tres al sur, según los novicios aterrados. '
          'Medí el recorrido con pasos contados y descubrí dónde terminaba realmente el paseo: ante la puerta tapiada de la cripta.',
      puzzle: byId('076'),
    ),
    BookPage(
      pageNumber: 11, collectibleId: 'abbey-11',
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'El amanecer en el claustro',
      storyTitle: 'Las monedas del exvoto (VISUAL)',
      storyText:
          'Tras la puerta tapiada hallamos el exvoto: diez monedas de oro en pirámide que el ladrón no pudo llevarse. '
          'Una nota exigía invertir la pirámide moviendo las menos monedas posibles para abrir el relicario. '
          'Holmes las contempló como un general ante un mapa de batalla.',
      puzzle: const PuzzleModel(
        id: 'A11',
        title: 'Puzle 11: La pirámide invertida',
        statement:
            'Observa la pirámide de 10 monedas (filas de 1, 2, 3 y 4). ¿Cuántas monedas debes mover como mínimo para que la pirámide apunte hacia abajo?',
        experiencia: 35,
        correctAnswer: '3',
        hintText: 'Las tres monedas de las esquinas cambian de sitio.',
        type: PuzzleType.visualChoice,
        options: ['1', '2', '3', '4'],
        visualKind: 'coin_triangle',
        visualPayload: '10-monedas-invertir',
      ),
    ),
    BookPage(
      pageNumber: 12, collectibleId: 'abbey-12',
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'El amanecer en el claustro',
      storyTitle: 'Las tijeras del sastre',
      storyText:
          'El sastre del pueblo, cómplice involuntario, había cortado la sotana del ladrón con un solo corte recto para disimularla. '
          'Nos mostró cómo dividiría una tela cuadrada en cuatro cuadrados con los mínimos cortes. Holmes comparó los hilos con los de la cripta: coincidían.',
      puzzle: byId('078'),
    ),
    BookPage(
      pageNumber: 13, collectibleId: 'abbey-13',
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'El amanecer en el claustro',
      storyTitle: 'La baraja del sacristán',
      storyText:
          'El sacristán, aficionado a las cartas, barajaba su mazo de cincuenta y dos naipes mientras montaba guardia. '
          'Apostó con nosotros cuántas cartas habría que robar a ciegas para garantizar un as. Holmes aceptó la apuesta con una sonrisa peligrosa.',
      puzzle: byId('079'),
    ),
    BookPage(
      pageNumber: 14, collectibleId: 'abbey-14',
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'El amanecer en el claustro',
      storyTitle: 'El tonel de la bodega',
      storyText:
          'En la bodega, un tonel se llenaba a cinco litros por minuto pero perdía dos por una grieta: el escondite perfecto para el manuscrito enrollado. '
          'El bodeguero calculaba en voz alta cuándo estaría lleno. Cronometré el goteo mientras Holmes descorría la tapa.',
      puzzle: byId('082'),
    ),
    BookPage(
      pageNumber: 15, collectibleId: 'abbey-15',
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'El amanecer en el claustro',
      storyTitle: 'Las velas del amanecer',
      storyText:
          'Al amanecer, en el coro ardían tres velas y el viento del rosetón apagó dos. El abad, entre lágrimas, preguntó cuántas quedaban: el ladrón —el hermano ecónomo, acorralado— confesó entre cirios. '
          'El relicario volvió al altar y la galería, al fin, guardó silencio. "Es elemental", dijo Holmes.',
      puzzle: byId('083'),
    ),
  ];

  return StoryBook(
    id: 'abbey',
    stage: 6,
    title: 'La Abadía de los Susurros',
    subtitle: 'Etapa 6 · El relicario desaparecido',
    description:
        'Una galería que susurra nombres y un relicario robado entre muros milenarios. Quince páginas de niebla, monjes y un final al amanecer.',
    coverKey: 'abbey',
    colorValue: 0xFF00695C,
    pages: pages,
  );
}
