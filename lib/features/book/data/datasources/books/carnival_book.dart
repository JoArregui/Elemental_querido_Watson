import '../../../../puzzle/data/datasources/puzzle_local_data_source.dart';
import '../../../../puzzle/data/models/puzzle_model.dart';
import '../../../../puzzle/domain/entities/puzzle.dart';
import '../../../domain/entities/book_page.dart';
import '../../../domain/entities/story_book.dart';

/// Libro 3 · Etapa 3: "El Carnaval de las Máscaras".
/// 10 páginas. Acertijos clásicos distintos + 1 visual con nueva pregunta.
Future<StoryBook> buildCarnivalBook(PuzzleLocalDataSource classic) async {
  final all = await classic.getAllPuzzles();
  Puzzle byId(String id) => all.firstWhere((p) => p.id == id);

  final pages = [
    BookPage(
      pageNumber: 1, collectibleId: 'carnival-1',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La máscara de oro',
      storyTitle: 'Confeti y sospechosos',
      storyText:
          'Holmes y yo llegamos a Belmaro en pleno carnaval: la Máscara de Oro del desfile ha desaparecido y el alcalde acusa al arlequín. '
          'Entre serpentinas, una niña disfrazada de liebre nos entregó una nota del ladrón: "Atrápenme si resuelven mi carrera". '
          'Holmes se ajustó la gorra: "Un ladrón que reta con enigmas merece una reverencia… y unas esposas".',
      puzzle: byId('020'),
    ),
    BookPage(
      pageNumber: 2, collectibleId: 'carnival-2',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La máscara de oro',
      storyTitle: 'El pozo de la plaza',
      storyText:
          'La primera pista llevaba al pozo de la plaza, donde el ladrón dejó caer una careta. Un caracol de agua subía por el brocal resbaladizo '
          'mientras yo intentaba pescar la careta con una caña. "La paciencia también se calcula", dijo Holmes cronometrando cada avance del caracol.',
      puzzle: byId('021'),
    ),
    BookPage(
      pageNumber: 3, collectibleId: 'carnival-3',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La máscara de oro',
      storyTitle: 'Gatos y ratones de atrezo',
      storyText:
          'En el teatro, el tramoyista juraba que tres gatos del decorado cazaron a los ratones de utilería en tiempo récord, justo cuando se apagaron las luces '
          'y la máscara cambió de manos. "Si los gatos son tan veloces, necesitaremos más ojos", bromeé. Holmes interrogó a los felinos con la mirada.',
      puzzle: byId('033'),
    ),
    BookPage(
      pageNumber: 4, collectibleId: 'carnival-4',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La máscara de oro',
      storyTitle: 'La mosca del tranvía',
      storyText:
          'Dos carrozas del desfile avanzaban una hacia la otra por la avenida mientras una paloma mensajera volaba sin parar de una a otra con notas del ladrón. '
          'El cochero, mareado, preguntó cuánta distancia habría volado la pobre ave cuando las carrozas se encuentren. '
          'Holmes sonrió: "Las palomas no entienden de idas y vueltas, solo de tiempo".',
      puzzle: byId('034'),
    ),
    BookPage(
      pageNumber: 5, collectibleId: 'carnival-5',
      chapterLabel: 'Capítulo 1',
      chapterTitle: 'La máscara de oro',
      storyTitle: 'El escaparate del cerillero (VISUAL)',
      storyText:
          'El cerillero del callejón vende figuras de cerillas y jura que el ladrón compró las suyas para dejar un mensaje en el escaparate: '
          'dos triángulos unidos. "¿Cuántos triángulos ve, Watson? No cuente las cerillas, cuente las formas", advirtió Holmes empañando el cristal con el aliento.',
      puzzle: const PuzzleModel(
        id: 'C05',
        title: 'Puzle 5: Triángulos en el cristal',
        statement:
            'Observa la figura del escaparate: dos triángulos que comparten un lado. ¿Cuántos triángulos hay en total en la figura?',
        experiencia: 20,
        correctAnswer: '2',
        hintText: 'Comparten un lado, pero siguen siendo dos triángulos.',
        type: PuzzleType.visualChoice,
        options: ['1', '2', '3', '5'],
        visualKind: 'matchsticks',
        visualPayload: '2-triangulos-comparten-lado',
      ),
    ),
    BookPage(
      pageNumber: 6, collectibleId: 'carnival-6',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El baile de medianoche',
      storyTitle: 'El pastor de la carroza',
      storyText:
          'El conductor de la carroza real, un pastor jubilado, aseguró que de sus diecisiete ovejas de cartón piedra del desfile "desaparecieron todas menos nueve" '
          'la noche del robo. Abrí los ojos como platos hasta que Holmes me guiñó un ojo: "Escuche bien las palabras, Watson, no las ovejas".',
      puzzle: byId('036'),
    ),
    BookPage(
      pageNumber: 7, collectibleId: 'carnival-7',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El baile de medianoche',
      storyTitle: 'La pirámide de farolillos',
      storyText:
          'En el baile de medianoche, una pirámide de farolillos iluminaba el salón donde la Máscara de Oro debía reaparecer, según la nota del ladrón. '
          'El mayordomo contaba los farolillos de la base mientras los invitados enmascarados danzaban. Holmes contaba niveles en silencio: '
          '"Toda pirámide esconde su número, como toda máscara esconde un rostro".',
      puzzle: byId('037'),
    ),
    BookPage(
      pageNumber: 8, collectibleId: 'carnival-8',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El baile de medianoche',
      storyTitle: 'Cuatro nueves de terciopelo',
      storyText:
          'El ladrón dejó un último reto bordado en terciopelo: componer el número cien con cuatro nueves. Los invitados se rieron, los músicos se detuvieron '
          'y hasta el alcalde contuvo la respiración. Murmuré fracciones mientras Holmes trazaba números en el aire con su bastón.',
      puzzle: byId('039'),
    ),
    BookPage(
      pageNumber: 9, collectibleId: 'carnival-9',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El baile de medianoche',
      storyTitle: 'El retrato del dogo',
      storyText:
          'En la galería, un niño señaló un retrato antiguo y recitó la adivinanza que el ladrón susurró al oído del guardia: '
          'un hombre sin hermanos que habla del padre del retratado. El guardia, confuso, dejó pasar al enmascarado. '
          '"La familia también es un enigma", reflexionó Holmes ante el lienzo.',
      puzzle: byId('040'),
    ),
    BookPage(
      pageNumber: 10, collectibleId: 'carnival-10',
      chapterLabel: 'Capítulo 2',
      chapterTitle: 'El baile de medianoche',
      storyTitle: 'Se cae la máscara',
      storyText:
          'A medianoche, Holmes pidió que invirtieran los focos del salón y el haz reveló polvo de oro en los guantes blancos del… ¡maestro de ceremonias! '
          'El número invertido de su camerino confirmó la trampa. El ladrón se quitó la máscara entre aplausos: quería demostrar que nadie vigilaba el patrimonio. '
          'La Máscara de Oro volvió al desfile y el carnaval estalló de alegría.',
      puzzle: byId('044'),
    ),
  ];

  return StoryBook(
    id: 'carnival',
    stage: 3,
    title: 'El Carnaval de las Máscaras',
    subtitle: 'Etapa 3 · Robo en Belmaro',
    description:
        'La Máscara de Oro ha desaparecido en pleno carnaval y el ladrón solo deja acertijos. Confeti, disfraces y un final de medianoche.',
    coverKey: 'masks',
    colorValue: 0xFF6A1B9A,
    pages: pages,
  );
}
