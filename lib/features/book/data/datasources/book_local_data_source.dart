import '../../../puzzle/data/datasources/puzzle_local_data_source.dart';
import '../../../puzzle/data/models/puzzle_model.dart';
import '../../../puzzle/domain/entities/puzzle.dart';
import '../../domain/entities/book_page.dart';
import '../../domain/entities/story_book.dart';
import 'books/abbey_book.dart';
import 'books/carnival_book.dart';
import 'books/lighthouse_book.dart';
import 'books/observatory_book.dart';
import 'books/train_book.dart';

abstract class BookLocalDataSource {
  /// Toda la biblioteca ordenada por etapa.
  Future<List<StoryBook>> getLibrary();

  /// Un libro concreto por su id ('nebelheim', 'lighthouse', ...).
  Future<StoryBook> getBook(String bookId);

  /// Páginas de un libro concreto.
  Future<List<BookPage>> getBookPages(String bookId);
}

/// Biblioteca: 4 libros-etapa, cada uno con su historia y sus acertijos.
class BookLocalDataSourceImpl implements BookLocalDataSource {
  final PuzzleLocalDataSource classicPuzzles;

  BookLocalDataSourceImpl({required this.classicPuzzles});

  List<StoryBook>? _cache;

  @override
  Future<List<StoryBook>> getLibrary() async {
    if (_cache != null) return _cache!;
    await Future.delayed(const Duration(milliseconds: 300));
    final lighthouse = await buildLighthouseBook(classicPuzzles);
    final carnival = await buildCarnivalBook(classicPuzzles);
    final observatory = await buildObservatoryBook(classicPuzzles);
    final train = await buildTrainBook(classicPuzzles);
    final abbey = await buildAbbeyBook(classicPuzzles);
    final List<StoryBook> books = [
      StoryBook(
        id: 'nebelheim',
        stage: 1,
        title: 'El Reloj Detenido de Nebelheim',
        subtitle: 'Etapa 1 · El misterio de la torre detenida',
        description:
            'La torre de Nebelheim se detuvo a las 10:10 y el relojero desapareció. 30 páginas para devolverle el latido a la villa.',
        coverKey: 'clock',
        colorValue: 0xFF4E342E,
        pages: _pages,
      ),
      lighthouse,
      carnival,
      observatory,
      train,
      abbey,
    ];
    books.sort((StoryBook a, StoryBook b) => a.stage.compareTo(b.stage));
    _cache = books;
    return books;
  }

  @override
  Future<StoryBook> getBook(String bookId) async {
    final books = await getLibrary();
    return books.firstWhere(
      (b) => b.id == bookId,
      orElse: () => throw StateError('Libro no encontrado: $bookId'),
    );
  }

  @override
  Future<List<BookPage>> getBookPages(String bookId) async {
    final book = await getBook(bookId);
    return book.pages;
  }

  /// Historia original: "El Reloj Detenido de Nebelheim".
  /// 30 páginas, 5 capítulos. Cada página termina con 1 acertijo.
  /// 24 acertijos de texto/opciones + 6 visuales.
  static const List<BookPage> _pages = [
    // ── CAPÍTULO 1: La carta del relojero (1-6) ──
    BookPage(
      pageNumber: 1,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La carta del relojero',
      storyTitle: 'Un telegrama en Baker Street',
      storyText:
          'Londres, una tarde de lluvia. En el 221B de Baker Street recibimos un telegrama sin firma: '
          '"Si el reloj de Nebelheim vuelve a latir, la villa despertará. Solo una mente deductiva podrá abrir la biblioteca". '
          'Holmes lo leyó dos veces —cosa rara en él— y observó el sello: un engranaje partido en dos. '
          '"La cacería ha comenzado, Watson. Prepare su revólver… y su cuaderno". El tren hacia Nebelheim sale al amanecer.',
      puzzle: PuzzleModel(
        id: 'B01',
        title: 'Puzle 1: Las campanadas',
        statement:
            'El reloj de la estación tarda 5 segundos en dar las 6 campanadas. ¿Cuántos segundos tardará en dar las 12 campanadas?',
        indicios: 20,
        correctAnswer: '11',
        hintText: 'Cuenta los intervalos entre campanadas, no las campanadas.',
      ),
    ),
    BookPage(
      pageNumber: 2,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La carta del relojero',
      storyTitle: 'El tren de las 7:04',
      storyText:
          'En el andén, el revisor nos advirtió: "En Nebelheim nadie baja del tren después de medianoche". '
          'Durante el viaje, Holmes estudió el plano de la villa: una plaza circular, una torre en el centro y ocho callejones como radios. '
          '"Observe, Watson: la villa misma es un reloj", murmuró sin alzar la vista. Anoté cada detalle en mi libreta. '
          'Al fondo del vagón, un desconocido con gabardina nos observaba en silencio.',
      puzzle: PuzzleModel(
        id: 'B02',
        title: 'Puzle 2: El cruce del río',
        statement:
            'Para llegar a Nebelheim hay que cruzar el río con un lobo, una cabra y una col. En la barca solo caben el barquero y un elemento. El lobo comería a la cabra y la cabra a la col si se quedan solos. ¿Cuál es el número mínimo de viajes?',
        indicios: 30,
        correctAnswer: '7',
        hintText: 'En algún momento tendrás que traer de vuelta a la cabra.',
      ),
    ),
    BookPage(
      pageNumber: 3,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La carta del relojero',
      storyTitle: 'Niebla sobre Nebelheim',
      storyText:
          'Nebelheim apareció entre la niebla: casas de piedra, faroles apagados y una torre inmóvil cuyas manecillas marcan siempre las 10:10. '
          'Los vecinos evitaban mirar la torre. Una niña se acercó a Holmes y le entregó una nota: "Mi abuelo, el relojero Anselm, desapareció cuando el reloj se detuvo. '
          'Dejó enigmas por toda la villa para quien quiera encontrarlo". Mi amigo recogió la nota con dos dedos, como si fuera una prueba: "El juego ha comenzado".',
      puzzle: PuzzleModel(
        id: 'B03',
        title: 'Puzle 3: La familia de la niña',
        statement:
            'La niña dice: "Cada uno de mis 6 hermanos tiene una hermana". ¿Cuántos niños hay en total en su familia?',
        indicios: 20,
        correctAnswer: '7',
        hintText: 'Todos los hermanos comparten la misma hermana.',
        type: PuzzleType.multipleChoice,
        options: ['6', '7', '12', '13'],
      ),
    ),
    BookPage(
      pageNumber: 4,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La carta del relojero',
      storyTitle: 'La posada del Engranaje',
      storyText:
          'En la posada, la dueña nos mostró el libro de visitas: la última firma es "A. Anselm" con un dibujo de una llave. '
          '"Se encerró en su taller y nadie volvió a verlo", susurró. Holmes examinó la chimenea apagada con su lupa y descubrió una marca de tiza: '
          'una flecha hacia la plaza. "Los enigmas no son obstáculos, Watson. Son huellas", dijo mientras encendía su pipa.',
      puzzle: PuzzleModel(
        id: 'B04',
        title: 'Puzle 4: La cerilla primera',
        statement:
            'En la posada hace frío. Solo tienes 1 cerilla y hay una lámpara de aceite, una vela y una estufa de carbón. ¿Qué enciendes primero?',
        indicios: 15,
        correctAnswer: 'la cerilla',
        hintText: 'Sin ella no puedes encender nada más.',
        type: PuzzleType.multipleChoice,
        options: ['la vela', 'la lámpara', 'la cerilla', 'la estufa'],
      ),
    ),
    BookPage(
      pageNumber: 5,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La carta del relojero',
      storyTitle: 'El friso de la puerta (VISUAL)',
      storyText:
          'Bajo la alfombra de nuestra habitación encontré una trampilla con un friso de piedra: círculos, triángulos y cuadrados se repiten '
          'en un orden extraño. "Es una cerradura de secuencia", explicó Holmes. "La villa habla con formas. Descifre el patrón y la trampilla cederá". '
          'El polvo cayó mientras las piezas encajaban con un clic metálico.',
      puzzle: PuzzleModel(
        id: 'B05',
        title: 'Puzle 5: La secuencia del friso',
        statement:
            'Observa la secuencia del friso: ● ▲ ■ ● ▲ … ¿Qué forma debe ir en sexto lugar para completar el patrón?',
        indicios: 25,
        correctAnswer: '■',
        hintText: 'El patrón se repite cada 3 figuras: círculo, triángulo, cuadrado.',
        type: PuzzleType.visualChoice,
        options: ['●', '▲', '■', '★'],
        visualKind: 'shapes_sequence',
        visualPayload: '●,▲,■,●,▲,?',
      ),
    ),
    BookPage(
      pageNumber: 6,
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La carta del relojero',
      storyTitle: 'El sótano del relojero',
      storyText:
          'La trampilla conducía a un sótano lleno de planos. En la pared, una frase grabada: "El tiempo solo avanza para quien razona". '
          'Sobre la mesa había una maqueta de la torre con una puerta diminuta sellada. Holmes tomó la maqueta y la giró: '
          'al reverso había un engranaje real incrustado. "Anselm estuvo aquí. Y nos dejó la primera prueba", concluyó.',
      puzzle: PuzzleModel(
        id: 'B06',
        title: 'Puzle 6: Los dados opuestos',
        statement:
            'En un dado estándar las caras opuestas suman 7. La maqueta tiene un dado decorativo con el 5 arriba. ¿Cuánto suman las caras no visibles si la suma total de las 6 caras es 21 y la inferior es 2?',
        indicios: 20,
        correctAnswer: '14',
        hintText: 'Resta a 21 las dos caras que sí ves: 5 y 2.',
        type: PuzzleType.multipleChoice,
        options: ['12', '14', '16', '19'],
      ),
    ),
    // ── CAPÍTULO 2: La plaza detenida (7-12) ──
    BookPage(
      pageNumber: 7,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La plaza detenida',
      storyTitle: 'Las diez y diez',
      storyText:
          'Al mediodía, la plaza estaba vacía aunque todos los relojes marcaban las 10:10. Un anciano nos explicó: '
          '"Cuando la torre se detuvo, la villa dejó de celebrar cumpleaños". Holmes se detuvo ante la fuente central: en el agua flotaba una llave de madera con un número grabado. '
          '"¿Ve, Watson? Hasta el agua guarda pruebas", dijo pescándola con su bastón.',
      puzzle: PuzzleModel(
        id: 'B07',
        title: 'Puzle 7: El lago de nenúfares',
        statement:
            'En el estanque de la fuente, los nenúfares duplican su tamaño cada día. Tardan 48 días en cubrirlo todo. ¿En cuántos días cubren la mitad?',
        indicios: 25,
        correctAnswer: '47',
        hintText: 'El día anterior al lleno total ocupaban justo la mitad.',
      ),
    ),
    BookPage(
      pageNumber: 8,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La plaza detenida',
      storyTitle: 'El vendedor de globos',
      storyText:
          'Un vendedor de globos nos cortó el paso: "Solo quien resuelva mi acertijo puede cruzar la plaza". '
          'Sus globos formaban números en el aire. Holmes aceptó el reto con una inclinación de cabeza. '
          '"Un detective jamás rechaza un enigma", dijo, y las ventanas a nuestro alrededor se llenaron de miradas contenidas.',
      puzzle: PuzzleModel(
        id: 'B08',
        title: 'Puzle 8: La secuencia que habla',
        statement: '¿Cuál es el siguiente número en la secuencia: 1, 11, 21, 1211, 111221, …?',
        indicios: 45,
        correctAnswer: '312211',
        hintText: 'Lee cada número en voz alta contando las cifras: "una vez uno"...',
      ),
    ),
    BookPage(
      pageNumber: 9,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La plaza detenida',
      storyTitle: 'Ocho callejones',
      storyText:
          'Holmes desplegó el plano: ocho callejones parten de la plaza como radios. "Si la villa es un reloj, cada callejón es una hora", reflexionó. '
          'Elegimos el tercer callejón, donde las farolas parpadeaban al ritmo de un tictac fantasma. '
          'Al final del callejón, una puerta verde con tres aldabas nos esperaba.',
      puzzle: PuzzleModel(
        id: 'B09',
        title: 'Puzle 9: Los brindis',
        statement:
            '8 vecinos se sientan en una mesa redonda en la taberna y cada uno brinda solo con sus dos vecinos contiguos. ¿Cuántos brindis hay en total?',
        indicios: 20,
        correctAnswer: '8',
        hintText: 'Cada persona brinda 2 veces, pero cada brindis se cuenta una sola vez.',
      ),
    ),
    BookPage(
      pageNumber: 10,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La plaza detenida',
      storyTitle: 'Los tres cofres (VISUAL)',
      storyText:
          'Tras la puerta verde había un nicho con tres cofres: uno rojo, uno azul y uno verde. Una placa advertía: '
          '"Solo uno guarda el engranaje. Los tres carteles mienten salvo uno". Holmes se arrodilló y estudió los cofres con la lupa. '
          '"Observe los detalles, Watson: la verdad suele brillar en lo más pequeño", susurró.',
      puzzle: PuzzleModel(
        id: 'B10',
        title: 'Puzle 10: Los cofres mentirosos',
        statement:
            'Cofre rojo: "El engranaje está aquí". Cofre azul: "El engranaje NO está aquí". Cofre verde: "El engranaje NO está en el rojo". Solo UNA afirmación es verdad. ¿Dónde está el engranaje? Elige el color.',
        indicios: 40,
        correctAnswer: 'azul',
        hintText: 'Si solo una dice la verdad, prueba suponer que es la del cofre azul.',
        type: PuzzleType.visualChoice,
        options: ['rojo', 'azul', 'verde'],
        visualKind: 'chests',
        visualPayload: 'rojo,azul,verde',
      ),
    ),
    BookPage(
      pageNumber: 11,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La plaza detenida',
      storyTitle: 'El reloj de bolsillo',
      storyText:
          'Dentro del cofre azul encontramos un reloj de bolsillo detenido y una foto: Anselm junto a una mujer ante la torre. '
          'Al reverso: "Para Elena, que me enseñó que el tiempo es memoria". Pregunté quién era Elena y Holmes guardó silencio. '
          'El reloj de bolsillo comenzó a hacer tictac… hacia atrás.',
      puzzle: PuzzleModel(
        id: 'B11',
        title: 'Puzle 11: El precio del recuerdo',
        statement:
            'El reloj y su cadena cuestan 11 libras en total. El reloj cuesta 10 libras más que la cadena. ¿Cuánto cuesta la cadena?',
        indicios: 25,
        correctAnswer: '0.5',
        hintText: 'Plantea X + (X + 10) = 11.',
        type: PuzzleType.multipleChoice,
        options: ['0.5', '1', '1.5', '5'],
      ),
    ),
    BookPage(
      pageNumber: 12,
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'La plaza detenida',
      storyTitle: 'Medianoche en la torre',
      storyText:
          'Esa noche, la torre emitió un tañido grave aunque sus manecillas no se movían. Los vecinos cerraron las contraventanas. '
          'Subimos los 99 escalones hasta el campanario —confieso que llegué jadeando— y descubrimos que faltaba la campana mayor: en su lugar había un hueco con forma de engranaje. '
          '"Alguien desmontó el corazón de la torre", dedujo Holmes.',
      puzzle: PuzzleModel(
        id: 'B12',
        title: 'Puzle 12: Las campanadas del campanario',
        statement:
            'El campanario da 1 campanada a la 1, 2 a las 2… ¿Cuántas campanadas da en total en 12 horas?',
        indicios: 30,
        correctAnswer: '78',
        hintText: 'Suma del 1 al 12: (12 × 13) / 2.',
      ),
    ),
    // ── CAPÍTULO 3: La biblioteca subterránea (13-18) ──
    BookPage(
      pageNumber: 13,
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'La biblioteca subterránea',
      storyTitle: 'La losa que cede',
      storyText:
          'Siguiendo el tictac invertido, llegamos a la capilla. Bajo el altar, una losa cedió y reveló unas escaleras que descendían a la oscuridad. '
          'El aire olía a papel antiguo. "Una biblioteca oculta", exclamé iluminando estanterías infinitas con mi linterna. '
          'Cada lomo llevaba un número. En el centro, un atril con un libro abierto en blanco.',
      puzzle: PuzzleModel(
        id: 'B13',
        title: 'Puzle 13: Los calcetines a oscuras',
        statement:
            'En el cuarto oscuro de la biblioteca hay 10 calcetines negros y 10 blancos. ¿Cuántos debes sacar como mínimo para asegurar un par del mismo color?',
        indicios: 15,
        correctAnswer: '3',
        hintText: 'Solo hay dos colores posibles.',
        type: PuzzleType.multipleChoice,
        options: ['2', '3', '10', '11'],
      ),
    ),
    BookPage(
      pageNumber: 14,
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'La biblioteca subterránea',
      storyTitle: 'El libro en blanco',
      storyText:
          'Holmes pasó la mano sobre la página en blanco y apareció un texto con el calor: "Quien lea sin luz, verá". '
          'Apagamos las lámparas y las estanterías brillaron con tinta fosforescente formando un plano de túneles. '
          'Uno de los túneles llevaba al taller de Anselm. Pero tres pasadizos partían del atril y solo uno era seguro.',
      puzzle: PuzzleModel(
        id: 'B14',
        title: 'Puzle 14: El tren del túnel',
        statement:
            'Un tren de 1 km entra a 60 km/h en un túnel de 1 km. ¿Cuántos minutos tarda en cruzarlo por completo (de morro a cola)?',
        indicios: 25,
        correctAnswer: '2',
        hintText: 'Debe recorrer 2 km en total.',
      ),
    ),
    BookPage(
      pageNumber: 15,
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'La biblioteca subterránea',
      storyTitle: 'El acertijo de las cerillas (VISUAL)',
      storyText:
          'En el atril había una caja con cerillas formando dos triángulos que comparten un lado. Una nota decía: '
          '"La puerta se abre si demuestras ingenio con poco". Holmes sonrió: "Un clásico de cerillas, Watson. Cuente conmigo… y cuente bien". '
          'Las sombras de las cerillas bailaban en la pared como agujas de reloj.',
      puzzle: PuzzleModel(
        id: 'B15',
        title: 'Puzle 15: Los triángulos de cerillas',
        statement:
            'Observa la figura: 2 triángulos equiláteros que comparten 1 lado. ¿Cuántas cerillas se han usado en total?',
        indicios: 20,
        correctAnswer: '5',
        hintText: 'Dos triángulos sueltos serían 6, pero comparten 1 cerilla.',
        type: PuzzleType.visualChoice,
        options: ['4', '5', '6', '7'],
        visualKind: 'matchsticks',
        visualPayload: '2-triangulos-comparten-lado',
      ),
    ),
    BookPage(
      pageNumber: 16,
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'La biblioteca subterránea',
      storyTitle: 'La guardiana',
      storyText:
          'Una mujer mayor emergió entre las estanterías: es Marta, la bibliotecaria. "Anselm escondió el Engranaje Maestro para que el alcalde no detuviera el tiempo", reveló. '
          '"El alcalde quería congelar la villa en un día feliz". Holmes frunció el ceño: "Detener el tiempo… qué caso tan triste". Marta nos entregó una llave de cristal.',
      puzzle: PuzzleModel(
        id: 'B16',
        title: 'Puzle 16: Las páginas arrancadas',
        statement:
            'En un libro de la biblioteca se arrancó una hoja. La suma de los números visibles por ambas caras es 21. ¿Qué número tiene la primera página arrancada?',
        indicios: 25,
        correctAnswer: '10',
        hintText: 'Dos páginas consecutivas de una hoja suman un impar: N + (N+1) = 21.',
      ),
    ),
    BookPage(
      pageNumber: 17,
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'La biblioteca subterránea',
      storyTitle: 'El pasadizo del agua',
      storyText:
          'La llave de cristal abrió una compuerta con dos jarras antiguas: una de 5 litros y otra de 3. '
          'Un mecanismo hidráulico bloqueaba el pasadizo. "Necesitamos exactamente 4 litros para equilibrar el peso", calculó Holmes. '
          'El agua resonaba en la piedra mientras yo contenía la respiración.',
      puzzle: PuzzleModel(
        id: 'B17',
        title: 'Puzle 17: Las jarras',
        statement:
            'Con una jarra de 5 L y otra de 3 L, ¿cuántos pasos mínimos de trasvase necesitas para conseguir exactamente 4 litros?',
        indicios: 35,
        correctAnswer: '6',
        hintText: 'Llena la de 5, pasa a la de 3, vacía la de 3 y pasa los 2 sobrantes.',
        type: PuzzleType.multipleChoice,
        options: ['4', '5', '6', '8'],
      ),
    ),
    BookPage(
      pageNumber: 18,
      chapterLabel: 'Capítulo 3',
      chapterTitle: 'La biblioteca subterránea',
      storyTitle: 'El archivo Elena',
      storyText:
          'Al fondo, un archivo etiquetado "ELENA" contenía partituras y el plano del Engranaje Maestro. '
          'Elena era la esposa de Anselm y la melodía de la torre fue compuesta por ella. "Por eso la torre calló cuando ella partió", murmuró Marta. '
          'Holmes guardó la partitura: "La música también es un enigma que se resuelve con el corazón".',
      puzzle: PuzzleModel(
        id: 'B18',
        title: 'Puzle 18: Fibonacci',
        statement: '¿Qué número sigue en la secuencia 1, 1, 2, 3, 5, 8, 13, …?',
        indicios: 15,
        correctAnswer: '21',
        hintText: 'Suma los dos últimos números.',
        type: PuzzleType.multipleChoice,
        options: ['18', '20', '21', '22'],
      ),
    ),
    // ── CAPÍTULO 4: El taller del relojero (19-24) ──
    BookPage(
      pageNumber: 19,
      chapterLabel: 'Capítulo 4',
      chapterTitle: 'El taller del relojero',
      storyTitle: 'Engranajes y sombras',
      storyText:
          'El túnel desembocaba en el taller de Anselm: cientos de relojes detenidos, herramientas cubiertas de polvo y una mesa con tres llaves. '
          'En la pared, un mensaje: "Mis llaves, mis cerrojos: ordénalos sin error". El desconocido de la gabardina apareció en la puerta: '
          'es el alcalde Crow. "El Engranaje Maestro me pertenece", gruñó. Holmes ni se inmutó: "Los gruñidos no son pruebas, señor alcalde".',
      puzzle: PuzzleModel(
        id: 'B19',
        title: 'Puzle 19: Las tres llaves',
        statement:
            'Hay 3 llaves para 3 cerrojos distintos. ¿Cuál es el número máximo de intentos fallidos antes de acertar cada llave con su cerrojo?',
        indicios: 25,
        correctAnswer: '3',
        hintText: 'Para el primero máximo 2 fallos; para el segundo, 1.',
        type: PuzzleType.multipleChoice,
        options: ['2', '3', '5', '6'],
      ),
    ),
    BookPage(
      pageNumber: 20,
      chapterLabel: 'Capítulo 4',
      chapterTitle: 'El taller del relojero',
      storyTitle: 'La balanza del maestro (VISUAL)',
      storyText:
          'Crow nos retó: "Si son tan listos, pesen mi verdad". Sobre la mesa había una balanza antigua con pesas de 4 kg, 2 kg y 1 kg. '
          'Holmes aceptó el duelo con calma: "La lógica pesa más que la amenaza". Coloqué las pesas con manos temblorosas mientras el alcalde sonreía.',
      puzzle: PuzzleModel(
        id: 'B20',
        title: 'Puzle 20: La balanza exacta',
        statement:
            'Mira la balanza: en un lado hay 3 pesas de 4 kg y 2 pesas de 1 kg. ¿Cuántas pesas de 2 kg necesitas en el otro lado para equilibrarla?',
        indicios: 20,
        correctAnswer: '7',
        hintText: 'El otro lado pesa 3×4 + 2×1 = 14 kg.',
        type: PuzzleType.visualChoice,
        options: ['5', '6', '7', '8'],
        visualKind: 'balance',
        visualPayload: '3x4+2x1 vs Nx2',
      ),
    ),
    BookPage(
      pageNumber: 21,
      chapterLabel: 'Capítulo 4',
      chapterTitle: 'El taller del relojero',
      storyTitle: 'La confesión de Crow',
      storyText:
          'Derrotado en su propio reto, Crow confesó: detuvo la torre el día que su hija partió, para no cumplir años sin ella. '
          '"Quería que Nebelheim no envejeciera", sollozó. Holmes puso una mano en su hombro: "El tiempo no se detiene, alcalde. Se comparte". '
          'Crow nos entregó la campana robada y nos rogó que hiciéramos latir la torre.',
      puzzle: PuzzleModel(
        id: 'B21',
        title: 'Puzle 21: El puente de noche',
        statement:
            '4 amigos (1, 2, 5 y 10 min) cruzan un puente de noche con 1 antorcha. Máximo 2 a la vez al ritmo del más lento. ¿Minutos mínimos para cruzar todos?',
        indicios: 50,
        correctAnswer: '17',
        hintText: 'Las dos personas más lentas deben cruzar juntas.',
      ),
    ),
    BookPage(
      pageNumber: 22,
      chapterLabel: 'Capítulo 4',
      chapterTitle: 'El taller del relojero',
      storyTitle: 'El diario de Anselm',
      storyText:
          'En el cajón secreto del taller encontramos el diario de Anselm: "Si lees esto, estoy dentro del mecanismo. '
          'Solo la melodía de Elena, tocada a medianoche, abrirá el corazón". Junto al diario había un cilindro de música sin canción. '
          'Lo hice girar y solo sonó un chirrido vacío.',
      puzzle: PuzzleModel(
        id: 'B22',
        title: 'Puzle 22: El candado del diario',
        statement:
            'El diario tiene un código de 3 dígitos. Pistas: 682 (un número correcto y en su sitio), 614 (un número correcto pero mal ubicado), 206 (dos números correctos pero mal ubicados). ¿Cuál es el código?',
        indicios: 55,
        correctAnswer: '052',
        hintText: 'El 6 queda descartado; el 2 y el 0 están mal ubicados en la tercera pista.',
      ),
    ),
    BookPage(
      pageNumber: 23,
      chapterLabel: 'Capítulo 4',
      chapterTitle: 'El taller del relojero',
      storyTitle: 'El cilindro vacío',
      storyText:
          'Holmes examinó el cilindro bajo la lupa: tenía púas desgastadas que dibujaban una cuadrícula. '
          '"No está vacío: es un tablero", descubrió. Marta recordó que Elena tocaba una nana de 8 notas en la torre cada domingo. '
          'Necesitábamos reconstruir la melodía nota a nota antes de medianoche.',
      puzzle: PuzzleModel(
        id: 'B23',
        title: 'Puzle 23: El tablero de la melodía',
        statement: '¿Cuántos cuadrados de todos los tamaños hay en un tablero de 8×8 como el del cilindro?',
        indicios: 45,
        correctAnswer: '204',
        hintText: 'Suma 1² + 2² + … + 8².',
        type: PuzzleType.multipleChoice,
        options: ['64', '128', '204', '256'],
      ),
    ),
    BookPage(
      pageNumber: 24,
      chapterLabel: 'Capítulo 4',
      chapterTitle: 'El taller del relojero',
      storyTitle: 'Las nueve menos cuarto',
      storyText:
          'Faltaban 15 minutos para la medianoche. Subimos la campana recuperada por la escalera de la torre mientras la niebla se abría. '
          'Cada peldaño tenía grabado un número. "Cuente conmigo", jadeé. Holmes miró su reloj: las manecillas del taller avanzaban por primera vez en años. '
          'El tiempo, al fin, se desperezaba.',
      puzzle: PuzzleModel(
        id: 'B24',
        title: 'Puzle 24: Los patos de la escalera',
        statement:
            'En la escalera hay patos tallados: 2 delante de 1, 2 detrás de 1 y 1 en medio. ¿Cuál es el número mínimo de patos?',
        indicios: 15,
        correctAnswer: '3',
        hintText: 'Van en una sola fila en hilera.',
        type: PuzzleType.multipleChoice,
        options: ['3', '4', '5', '6'],
      ),
    ),
    // ── CAPÍTULO 5: La medianoche (25-30) ──
    BookPage(
      pageNumber: 25,
      chapterLabel: 'Capítulo 5',
      chapterTitle: 'La medianoche',
      storyTitle: 'El mosaico del campanario (VISUAL)',
      storyText:
          'En el campanario, el suelo era un mosaico de 3×3 losas. Una inscripción rezaba: "Cuenta todo lo que ves y la puerta del corazón se abrirá". '
          'Conté los cuadrados grandes, pero Holmes me detuvo: "Cuente también los pequeños y los medianos. Un detective no deja ningún detalle". '
          'La medianoche se acercaba con un viento helado.',
      puzzle: PuzzleModel(
        id: 'B25',
        title: 'Puzle 25: El mosaico',
        statement:
            'Observa la cuadrícula de 3×3 del suelo. ¿Cuántos cuadrados de todos los tamaños hay en total (1×1, 2×2 y 3×3)?',
        indicios: 35,
        correctAnswer: '14',
        hintText: 'Suma 9 + 4 + 1.',
        type: PuzzleType.visualChoice,
        options: ['9', '12', '13', '14'],
        visualKind: 'grid_squares',
        visualPayload: '3x3',
      ),
    ),
    BookPage(
      pageNumber: 26,
      chapterLabel: 'Capítulo 5',
      chapterTitle: 'La medianoche',
      storyTitle: 'La nana de Elena',
      storyText:
          'Con el mosaico resuelto, el cilindro encajó en el carillón. Marta tarareó la nana de Elena y anoté las notas. '
          'Holmes colocó las púas una a una siguiendo la partitura del archivo. "La música es matemáticas con alma", dijo. '
          'El primer acorde resonó y la torre tembló levemente.',
      puzzle: PuzzleModel(
        id: 'B26',
        title: 'Puzle 26: La contraseña del carillón',
        statement:
            'El guardián del carillón dice 8 y debes responder 4. Dice 14 y respondes 7. Dice 6. ¿Qué debes responder?',
        indicios: 30,
        correctAnswer: '4',
        hintText: 'Cuenta las letras de la palabra: "ocho" tiene 4, "catorce" 7, "seis" 4.',
        type: PuzzleType.multipleChoice,
        options: ['2', '3', '4', '6'],
      ),
    ),
    BookPage(
      pageNumber: 27,
      chapterLabel: 'Capítulo 5',
      chapterTitle: 'La medianoche',
      storyTitle: 'El corazón detenido',
      storyText:
          'Tras el carillón apareció el corazón: un hueco con forma de engranaje donde faltaba el Engranaje Maestro. '
          'Dentro, una nota de Anselm: "Me quedé a custodiarlo para que nadie lo usara con egoísmo. Quien lo coloque debe responder por qué el tiempo importa". '
          'Crow bajó la mirada. Yo apreté la llave de cristal.',
      puzzle: PuzzleModel(
        id: 'B27',
        title: 'Puzle 27: El tonel del corazón',
        statement:
            'El contrapeso es un tonel que lleno pesa 20 kg y medio lleno pesa 12 kg. ¿Cuánto pesa el tonel vacío?',
        indicios: 25,
        correctAnswer: '4',
        hintText: 'La mitad del agua pesa 20 − 12 = 8 kg.',
        type: PuzzleType.multipleChoice,
        options: ['2', '4', '6', '8'],
      ),
    ),
    BookPage(
      pageNumber: 28,
      chapterLabel: 'Capítulo 5',
      chapterTitle: 'La medianoche',
      storyTitle: 'La respuesta de Watson',
      storyText:
          'Me adelanté y dije con voz clara: "El tiempo importa porque nos deja volver a vernos y recordar". '
          'El hueco brilló y aceptó la llave de cristal, que se transformó en el Engranaje Maestro. Anselm emergió de entre los engranajes, '
          'envejecido pero sonriente: "Esa es la respuesta que Elena siempre supo". Todos contuvimos la respiración.',
      puzzle: PuzzleModel(
        id: 'B28',
        title: 'Puzle 28: El lagarto del tiempo',
        statement:
            'Una rana sube por el eje de la torre de 20 m: sube 5 m de día y baja 4 m de noche. ¿En cuántos días sale?',
        indicios: 30,
        correctAnswer: '16',
        hintText: 'El día 16 sube los últimos 5 m sin resbalar.',
      ),
    ),
    BookPage(
      pageNumber: 29,
      chapterLabel: 'Capítulo 5',
      chapterTitle: 'La medianoche',
      storyTitle: 'Las doce campanadas',
      storyText:
          'Colocamos el Engranaje Maestro y la campana en su sitio. A medianoche en punto, la melodía de Elena sonó completa por primera vez en una década. '
          'Las manecillas, clavadas en las 10:10, temblaron… y avanzaron. Una a una, las ventanas de Nebelheim se iluminaron. '
          'Los vecinos salieron a la plaza llorando y riendo a la vez.',
      puzzle: PuzzleModel(
        id: 'B29',
        title: 'Puzle 29: Los faros gemelos',
        statement:
            'Dos faros de la villa destellan cada 8 y cada 12 segundos. Si coinciden ahora, ¿en cuántos segundos volverán a coincidir?',
        indicios: 25,
        correctAnswer: '24',
        hintText: 'Calcula el mínimo común múltiplo de 8 y 12.',
        type: PuzzleType.multipleChoice,
        options: ['16', '20', '24', '48'],
      ),
    ),
    BookPage(
      pageNumber: 30,
      chapterLabel: 'Capítulo 5',
      chapterTitle: 'La medianoche',
      storyTitle: 'El último secreto (VISUAL FINAL)',
      storyText:
          'Con la torre latiendo, Anselm abrió el cofre final: dentro había tres diales numéricos. "La suma de los tres dígitos es 27", explicó. '
          '"Solo una combinación la abre: la joya de Nebelheim". Holmes me miró y ambos asentimos. '
          '"Todo caso merece un final a la altura, ¿no cree, Watson?". El amanecer tiñó de dorado la plaza mientras girábamos los diales…',
      puzzle: PuzzleModel(
        id: 'B30',
        title: 'Puzle 30: La joya de Nebelheim',
        statement:
            'Observa los 3 diales (0-9). La suma de los 3 dígitos es 27. Solo hay una combinación posible con dígitos simples. ¿Cuál es la clave?',
        indicios: 50,
        correctAnswer: '999',
        hintText: 'El único dígito que sumado 3 veces da 27 es el 9.',
        type: PuzzleType.visualChoice,
        options: ['999', '899', '992', '789'],
        visualKind: 'dials',
        visualPayload: '3-diales-suma-27',
      ),
    ),
  ];
}
