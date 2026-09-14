import '../../../../puzzle/data/datasources/puzzle_local_data_source.dart';
import '../../../../puzzle/data/models/puzzle_model.dart';
import '../../../../puzzle/domain/entities/puzzle.dart';
import '../../../domain/entities/book_page.dart';
import '../../../domain/entities/story_book.dart';

/// Libro 5 · Etapa 5: "El Misterio del Expreso de Medianoche".
/// 15 páginas. Acertijos clásicos distintos + 2 visuales.
Future<StoryBook> buildTrainBook(PuzzleLocalDataSource classic) async {
  final all = await classic.getAllPuzzles();
  Puzzle byId(String id) => all.firstWhere((p) => p.id == id);

  final pages = [
    BookPage(
      pageNumber: 1,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'El pasajero del compartimento 7',
      storyTitle: 'Billetes para el norte',
      storyText:
          'Una noche de niebla subimos al Expreso de Medianoche: un banquero había desaparecido de un compartimento cerrado por dentro. '
          'El revisor, pálido, nos condujo al vagón 7. Holmes examinó la cerradura con su lupa mientras yo anotaba la lista de pasajeros. '
          '"Un cuarto cerrado en movimiento, Watson. Mi tipo favorito de caso".',
      puzzle: byId('011'),
    ),
    BookPage(
      pageNumber: 2,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'El pasajero del compartimento 7',
      storyTitle: 'El pastel del vagón restaurante',
      storyText:
          'En el vagón restaurante, el cocinero celebraba su cumpleaños con un pastel redondo y solo tres cortes permitidos por el reglamento de la compañía. '
          'Los camareros discutían cuántos trozos saldrían. Holmes partió el pastel ante todos mientras el sospechoso de la mesa vecina observaba en silencio.',
      puzzle: byId('012'),
    ),
    BookPage(
      pageNumber: 3,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'El pasajero del compartimento 7',
      storyTitle: 'Cien almas a bordo',
      storyText:
          'El maquinista nos contó que el expreso llevaba cien pasajeros y botes… no, asientos de sobra para todos aunque el tren descarrilara en el viaducto. '
          'Su acertijo nervioso escondía un dato: nadie había visto al banquero tras el puente. Anoté su testimonio palabra por palabra.',
      puzzle: byId('013'),
    ),
    BookPage(
      pageNumber: 4,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'El pasajero del compartimento 7',
      storyTitle: 'Caramelos para el testigo',
      storyText:
          'Un niño, único testigo, solo hablaría a cambio de caramelos. La vendedora tenía tres cajas y un método extraño para repartirlos sin partir ninguno. '
          'Holmes resolvió el reparto en segundos y el niño, con la boca llena, señaló el maletero del pasillo: "El señor del sombrero alto metió algo allí".',
      puzzle: byId('016'),
    ),
    BookPage(
      pageNumber: 5,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'El pasajero del compartimento 7',
      storyTitle: 'Los cubos del equipaje',
      storyText:
          'En el maletero encontramos tres cubos de pintura del atrezo teatral que viajaba en el tren: uno rojo, uno verde y uno azul, uno de ellos mezclado. '
          'El actor, nervioso, juraba no haber tocado nada. Holmes mezcló y dedujo con dos preguntas quién había abierto el maletero a medianoche.',
      puzzle: byId('022'),
    ),
    BookPage(
      pageNumber: 6,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El túnel sin luz',
      storyTitle: 'Manzanas en la penumbra',
      storyText:
          'El tren se detuvo en un túnel sin luz por una avería. En la oscuridad, alguien repartió manzanas entre los pasajeros del vagón 7. '
          'Al volver la luz, cada uno tenía una y aún quedaba una en la cesta. "¿Magia, Watson? No: lógica", dijo Holmes encendiendo su linterna.',
      puzzle: byId('024'),
    ),
    BookPage(
      pageNumber: 7,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El túnel sin luz',
      storyTitle: 'Las cajas del correo',
      storyText:
          'El vagón correo llevaba tres cajas mal etiquetadas: manzanas, naranjas y mezcla. El empleado, sobornado para transportar el botín, temblaba ante nosotros. '
          'Holmes sacó una sola pieza de una caja y sonrió: "Con esto basta para etiquetarlo todo… y para delatarle".',
      puzzle: byId('026'),
    ),
    BookPage(
      pageNumber: 8,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El túnel sin luz',
      storyTitle: 'Los tres cofres del banquero (VISUAL)',
      storyText:
          'En el compartimento 7 hallamos el maletín del banquero con tres cofres y una nota: "Solo una tarjeta dice la verdad". '
          'El tren traqueteaba en la oscuridad del túnel mientras Holmes estudiaba los cofres a la luz de mi linterna. '
          '"El dinero deja huellas, Watson. Las mentiras, más".',
      puzzle: const PuzzleModel(
        id: 'T08',
        title: 'Puzle 8: El rubí del banquero',
        statement:
            'Cofre rojo: "El rubí está en el azul". Cofre azul: "El rubí está aquí". Cofre verde: "El rubí no está aquí". Solo UNA afirmación es verdad. ¿Dónde está el rubí? Elige el color.',
        indicios: 40,
        correctAnswer: 'rojo',
        hintText: 'Supón que la única verdad la dice el cofre rojo y comprueba el resto.',
        type: PuzzleType.visualChoice,
        options: ['rojo', 'azul', 'verde'],
        visualKind: 'chests',
        visualPayload: 'rojo,azul,verde',
      ),
    ),
    BookPage(
      pageNumber: 9,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El túnel sin luz',
      storyTitle: 'Huellas en la nieve',
      storyText:
          'Al salir del túnel, la nieve cubría el terraplén y unas huellas se alejaban del tren hacia el norte, giraban al este y volvían al convoy. '
          'El inspector, llegado en el apeadero, preguntó qué fiera las había dejado. Holmes observó la geometría imposible de las pisadas y sonrió.',
      puzzle: byId('029'),
    ),
    BookPage(
      pageNumber: 10,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El túnel sin luz',
      storyTitle: 'La partida del revisor',
      storyText:
          'Para calmar a los pasajeros, el revisor repartió cartas: diez naipes, cinco boca arriba y cinco boca abajo, con los ojos vendados por apuesta. '
          'Holmes aceptó el reto ante todo el vagón y dividió la baraja en dos grupos con un movimiento teatral. El banquero, escondido entre el público, tragó saliva.',
      puzzle: byId('030'),
    ),
    BookPage(
      pageNumber: 11,
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'La estación final',
      storyTitle: 'El cumpleaños del maquinista',
      storyText:
          'El maquinista, interrogado, se enredó con su edad: decía haber cumplido años anteayer y cumplir más el año próximo de lo que parecía posible. '
          'Holmes detectó la mentira cronológica al instante. "Su coartada descarrila, amigo mío", sentenció mientras el tren aminoraba hacia la estación final.',
      puzzle: byId('031'),
    ),
    BookPage(
      pageNumber: 12,
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'La estación final',
      storyTitle: 'Las lámparas del andén',
      storyText:
          'En el andén final, tres lámparas de aceite ardían junto a la consigna donde el botín esperaba. El jefe de estación explicó su consumo con un acertijo cansado. '
          'Calculé en mi libreta mientras Holmes forzaba la consigna con una ganzúa: dentro, el rubí… y el billete de vuelta del banquero.',
      puzzle: byId('041'),
    ),
    BookPage(
      pageNumber: 13,
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'La estación final',
      storyTitle: 'El mosaico del vestíbulo (VISUAL)',
      storyText:
          'El vestíbulo de la estación lucía un mosaico de 2×2 losas con una inscripción: "Cuenta todo y hallarás la salida". '
          'El banquero, acorralado, exigió resolverlo para entregarse "con elegancia". Holmes me cedió el honor con una reverencia burlona.',
      puzzle: const PuzzleModel(
        id: 'T13',
        title: 'Puzle 13: El mosaico pequeño',
        statement:
            'Observa la cuadrícula de 2×2 del suelo. ¿Cuántos cuadrados de todos los tamaños hay en total (1×1 y 2×2)?',
        indicios: 25,
        correctAnswer: '5',
        hintText: 'Suma 4 + 1.',
        type: PuzzleType.visualChoice,
        options: ['4', '5', '6', '9'],
        visualKind: 'grid_squares',
        visualPayload: '2x2',
      ),
    ),
    BookPage(
      pageNumber: 14,
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'La estación final',
      storyTitle: 'Los relojes de arena',
      storyText:
          'El banquero pidió cinco minutos para confesar y nos retó con sus dos relojes de arena de plata: uno de siete minutos y otro de cuatro. '
          '"Midan nueve minutos exactos y les contaré dónde está el resto", propuso. Holmes giró los relojes sin pestañear.',
      puzzle: byId('042'),
    ),
    BookPage(
      pageNumber: 15,
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'La estación final',
      storyTitle: 'La cesta del andén',
      storyText:
          'Confesó todo antes de que cayese el último grano: había fingido su desaparición para cobrar un seguro, repartiendo manzanas entre los niños del andén para ganarse coartadas. '
          'Repartió seis manzanas entre seis niños dejando una en la cesta, ante nuestros ojos. "Elemental", dijo Holmes aplaudiendo despacio.',
      puzzle: byId('043'),
    ),
  ];

  return StoryBook(
    id: 'train',
    stage: 5,
    title: 'El Misterio del Expreso de Medianoche',
    subtitle: 'Etapa 5 · Un pasajero desaparecido',
    description:
        'Un banquero se esfuma de un compartimento cerrado en marcha. Quince páginas entre túneles, nieve y un rubí escondido.',
    coverKey: 'train',
    colorValue: 0xFFB71C1C,
    pages: pages,
  );
}
