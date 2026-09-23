import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/l10n/book_en.dart';
import '../../../../core/services/locale_service.dart';
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

  LocaleService get _localeService {
    try { return GetIt.I.get<LocaleService>(); } catch (_) { return LocaleService()..value = const Locale('es'); }
  }
  bool get _isEnglish => _localeService.value.languageCode == 'en';
  final Map<String, List<StoryBook>> _cache = {};

  StoryBook _translateBook(StoryBook b) {
    if (!_isEnglish) return b;
    // Inline puzzles B01-B30 and F05 etc. -> replace with EN versions where id matches
    List<BookPage> enPages = b.pages.map((p) {
      Puzzle enPuzzle = p.puzzle;
      // Replace inline puzzles with EN equivalents
      if (p.puzzle.id == 'F05') enPuzzle = f05En;
      if (p.puzzle.id == 'C05') enPuzzle = c05En;
      if (p.puzzle.id == 'O05') enPuzzle = o05En;
      if (p.puzzle.id == 'O09') enPuzzle = o09En;
      if (p.puzzle.id == 'O10') enPuzzle = o10En;
      if (p.puzzle.id == 'T08') enPuzzle = t08En;
      if (p.puzzle.id == 'T13') enPuzzle = t13En;
      if (p.puzzle.id == 'A06') enPuzzle = a06En;
      if (p.puzzle.id == 'A11') enPuzzle = a11En;
      // B01-B30 are handled via nebelheimEnPages, but other inline also
      String chapterLabel = p.chapterLabel;
      String chapterTitle = p.chapterTitle;
      String storyTitle = p.storyTitle;
      String storyText = p.storyText;
      // Simple EN mapping for chapter labels
      if (_isEnglish) {
        chapterLabel = chapterLabel.replaceAll('Capítulo', 'Chapter');
        // Story titles/texts for nebelheim are already EN via nebelheimEnPages, for others translate via maps
        final enMap = _enPageMap['${b.id}:${p.pageNumber}'];
        if (enMap != null) {
          chapterTitle = enMap['chapterTitle'] ?? chapterTitle;
          storyTitle = enMap['storyTitle'] ?? storyTitle;
          storyText = enMap['storyText'] ?? storyText;
        }
      }
      return BookPage(
        pageNumber: p.pageNumber,
        chapterLabel: chapterLabel,
        chapterTitle: chapterTitle,
        storyTitle: storyTitle,
        storyText: storyText,
        puzzle: enPuzzle,
      );
    }).toList();

    // Book meta EN
    String title = b.title;
    String subtitle = b.subtitle;
    String description = b.description;
    if (_isEnglish) {
      if (b.id == 'lighthouse') { title = enLighthouseMeta['title']!; subtitle = enLighthouseMeta['subtitle']!; description = enLighthouseMeta['description']!; }
      if (b.id == 'carnival') { title = enCarnivalMeta['title']!; subtitle = enCarnivalMeta['subtitle']!; description = enCarnivalMeta['description']!; }
      if (b.id == 'observatory') { title = enObservatoryMeta['title']!; subtitle = enObservatoryMeta['subtitle']!; description = enObservatoryMeta['description']!; }
      if (b.id == 'train') { title = enTrainMeta['title']!; subtitle = enTrainMeta['subtitle']!; description = enTrainMeta['description']!; }
      if (b.id == 'abbey') { title = enAbbeyMeta['title']!; subtitle = enAbbeyMeta['subtitle']!; description = enAbbeyMeta['description']!; }
    }
    return StoryBook(id: b.id, stage: b.stage, title: title, subtitle: subtitle, description: description, coverKey: b.coverKey, colorValue: b.colorValue, pages: enPages);
  }

  // EN story texts for books 2-6 (chapterTitle/storyTitle/storyText)
  static const Map<String, Map<String,String>> _enPageMap = {
    // Lighthouse 10
    'lighthouse:1': {'chapterTitle':'The Dark Light','storyTitle':'Marealta Without a Beacon','storyText':'After Nebelheim, Holmes and I traveled to Marealta, a fishing village where the lighthouse has been dark for a week. Boats take long detours and fishermen whisper about "the tide that took keeper Tomas". On the pier a gull dropped a counterfeit coin at our feet. Holmes picked it up: "Nothing is accidental, Watson. Let us weigh the truth".'},
    'lighthouse:2': {'chapterTitle':'The Dark Light','storyTitle':'The Pier Rope','storyText':'The harbor master showed the pier rope, cut in several places during the storm. "It was the night Tomas vanished", he said. I counted cuts while Holmes examined them: clean knife cuts, not storm. "Storms do not use knives, Watson".'},
    'lighthouse:3': {'chapterTitle':'The Dark Light','storyTitle':'Four Wool Caps','storyText':'In the "Mermaid" tavern four sailors with wool caps argued who last saw the keeper. Two caps white, two black, but the tavern was dark. The owner proposed a game: "Who deduces his color buys a round". Holmes smiled: a hat riddle never fails.'},
    'lighthouse:4': {'chapterTitle':'The Dark Light','storyTitle':'The Keeper Candle','storyText':'We climbed the lighthouse with a single box of matches. The spiral stairs were freezing and the main lamp, signal candle and brazier waited dark. "Only one intact match", I shivered. Holmes shielded it: "Then we must choose the first fire well".'},
    'lighthouse:5': {'chapterTitle':'The Dark Light','storyTitle':'The Shell Mosaic (VISUAL)','storyText':'In the lamp room we found a shell mosaic Tomas laid each night: four figures almost identical, but one breaks the pattern. "He marked uneventful nights", Holmes said. "Find the odd one".'},
    'lighthouse:6': {'chapterTitle':'The Smuggling Tide','storyTitle':'The Father and the Cabin Boy','storyText':'An old sea wolf confessed weeping: his son, cabin boy of the last boat, argued with Tomas over boxes "too heavy for fish". Holmes noted ages and found numbers did not add up. "Lies also age badly".'},
    'lighthouse:7': {'chapterTitle':'The Smuggling Tide','storyTitle':'The Lighthouse Cat','storyText':'The lighthouse cat "Compass" meowed by a three-meter wall to the cliff. Each day it tries to jump to return to Tomas. Holmes calculated how many attempts the brave feline needs.'},
    'lighthouse:8': {'chapterTitle':'The Smuggling Tide','storyTitle':'The Three Basement Switches','storyText':'Under the lighthouse are three switches and upstairs a single spare bulb. Smugglers used the basement as store and you may go up only once silently. "Two of these are our improvised beacon", Holmes murmured.'},
    'lighthouse:9': {'chapterTitle':'The Smuggling Tide','storyTitle':'Twelve Months of Fog','storyText':'Trapped, smugglers confessed: they turned off the lighthouse on new moons to land unseen, and Tomas discovered them. He was locked in the tidal cave. "How many new moons this year?" I asked looking at the keeper calendar.'},
    'lighthouse:10': {'chapterTitle':'The Smuggling Tide','storyTitle':'Light Returns Home','storyText':'We freed Tomas from the cave as two boats — fishermen and coast guard — sailed toward the lighthouse. Holmes lit the spare lamp and its beam swept the fog. "Calculate distance, quickly", he shouted.'},
    // Carnival 10
    'carnival:1': {'chapterTitle':'The Gold Mask','storyTitle':'Confetti and Suspects','storyText':'Holmes and I arrived in Belmaro mid-carnival: the Gold Mask of the parade vanished and the mayor blames the harlequin. A girl dressed as a hare gave us a thief note: "Catch me if you solve my race".'},
    'carnival:2': {'chapterTitle':'The Gold Mask','storyTitle':'The Square Well','storyText':'First clue led to the square well where the thief dropped a mask. A water snail climbed the slippery curb while I tried to fish the mask. "Patience is also calculated".'},
    'carnival:3': {'chapterTitle':'The Gold Mask','storyTitle':'Cats and Prop Mice','storyText':'In the theater the stagehand swore three prop cats caught prop mice in record time when lights went out and the mask changed hands.'},
    'carnival:4': {'chapterTitle':'The Gold Mask','storyTitle':'The Tram Fly','storyText':'Two parade floats moved toward each other while a messenger pigeon flew nonstop from one to the other with thief notes. The driver asked how far the bird had flown.'},
    'carnival:5': {'chapterTitle':'The Gold Mask','storyTitle':'The Matchstick Shop (VISUAL)','storyText':'The matchstick seller swore the thief bought his matches to leave a message: two joined triangles. "How many triangles do you see, Watson? Count shapes, not matches".'},
    'carnival:6': {'chapterTitle':'The Midnight Ball','storyTitle':'The Carriage Shepherd','storyText':'The royal carriage driver, a retired shepherd, said of his seventeen cardboard sheep "all but nine vanished" the night of the theft. Holmes winked: "Listen to words, not sheep".'},
    'carnival:7': {'chapterTitle':'The Midnight Ball','storyTitle':'The Lantern Pyramid','storyText':'At the midnight ball a pyramid of lanterns lit the hall where the Gold Mask should reappear. Holmes counted levels in silence.'},
    'carnival:8': {'chapterTitle':'The Midnight Ball','storyTitle':'Four Nines of Velvet','storyText':'The thief left a final velvet challenge: make one hundred with four nines. Guests laughed, musicians stopped.'},
    'carnival:9': {'chapterTitle':'The Midnight Ball','storyTitle':'The Mastiff Portrait','storyText':'In the gallery a child recited the thief riddle about a man with no brothers speaking of the portrait father.'},
    'carnival:10': {'chapterTitle':'The Midnight Ball','storyTitle':'Mask Falls','storyText':'At midnight Holmes asked to invert the hall spotlights and gold dust on the master of ceremonies white gloves was revealed. The thief unmasked to prove heritage was unwatched.'},
    // Observatory 10
    'observatory:1': {'chapterTitle':'The Comet Night','storyTitle':'Starry Summit','storyText':'Holmes and I climbed Starry Summit observatory the night Blue Comet returns after a hundred years. But astronomer Vega had bad news: the main lens and star chart were stolen.'},
    'observatory:2': {'chapterTitle':'The Comet Night','storyTitle':'The Refuge Flour Sack','storyText':'At the mountain refuge only a flour sack remained for dinner, and the cook argued how much it really weighed.'},
    'observatory:3': {'chapterTitle':'The Comet Night','storyTitle':'Dice Under Stars','storyText':'The young apprentice killed time rolling dice while guarding the telescope the night of the theft. Holmes asked him to repeat the most probable roll.'},
    'observatory:4': {'chapterTitle':'The Comet Night','storyTitle':'Planetarium Coins','storyText':'In the mechanical planetarium two stuck coins blocked Saturn gear. The janitor said one "is not" a certain value. Holmes translated the word trick.'},
    'observatory:5': {'chapterTitle':'The Comet Night','storyTitle':'The Astronomer Scale (VISUAL)','storyText':'Vega weighed meteorites on a precision scale: on one pan his samples and on the other only 3-kilo weights.'},
    'observatory:6': {'chapterTitle':'The Blue Comet','storyTitle':'The Funicular Wheel','storyText':'To register the summit before dawn we used the funicular with its spare wheel, rotating the car tires each trip.'},
    'observatory:7': {'chapterTitle':'The Blue Comet','storyTitle':'The Dome Series','storyText':'The dome rotated following a numeric series engraved by the founder: perfect squares marking each constellation.'},
    'observatory:8': {'chapterTitle':'The Blue Comet','storyTitle':'The Telescope Canteen','storyText':'In the canteen the apprentice argued with the cook over a bottle with its century-old cork. The thief ticket hid the same impossible bill.'},
    'observatory:9': {'chapterTitle':'The Blue Comet','storyTitle':'The Constellation Frieze (VISUAL)','storyText':'Behind the telescope a frieze of stars and moons blinked in sequence. It was the lock of the chamber where the lens was hidden.'},
    'observatory:10': {'chapterTitle':'The Blue Comet','storyTitle':'The Firmament Mosaic (VISUAL FINAL)','storyText':'Chamber opened: the lens was there, hidden by the founder to protect it from an unscrupulous collector! Only the 4x4 floor mosaic remained before Blue Comet crossed the sky.'},
    // Train 15
    'train:1': {'chapterTitle':'The Compartment 7 Passenger','storyTitle':'Tickets North','storyText':'On a foggy night we boarded the Midnight Express: a banker vanished from a compartment locked from inside. Holmes examined the lock.'},
    'train:2': {'chapterTitle':'The Compartment 7 Passenger','storyTitle':'The Dining Car Cake','storyText':'In the dining car the cook celebrated birthday with a round cake and only three cuts allowed by company rules.'},
    'train:3': {'chapterTitle':'The Compartment 7 Passenger','storyTitle':'A Hundred Souls Aboard','storyText':'The driver said the express carried a hundred passengers and boats — seats — enough for all even if the train derailed.'},
    'train:4': {'chapterTitle':'The Compartment 7 Passenger','storyTitle':'Candies for the Witness','storyText':'A child, sole witness, would only speak for candies. The seller had three boxes and a strange way to share without cutting any.'},
    'train:5': {'chapterTitle':'The Compartment 7 Passenger','storyTitle':'The Luggage Cubes','storyText':'In the trunk we found three paint buckets from a theater prop: red, green, blue, one mixed. Holmes deduced who opened the trunk at midnight with two questions.'},
    'train:6': {'chapterTitle':'The Lightless Tunnel','storyTitle':'Apples in the Dark','storyText':'The train stopped in a dark tunnel. Someone shared apples among car 7 passengers. When light returned, each had one and one remained in the basket.'},
    'train:7': {'chapterTitle':'The Lightless Tunnel','storyTitle':'The Mail Boxes','storyText':'The mail car had three mislabeled boxes: apples, oranges, mixed. Holmes took one piece from a box and smiled: "This is enough".'},
    'train:8': {'chapterTitle':'The Lightless Tunnel','storyTitle':'The Banker Three Chests (VISUAL)','storyText':'In compartment 7 we found the banker briefcase with three chests and a note: "Only one card tells truth".'},
    'train:9': {'chapterTitle':'The Lightless Tunnel','storyTitle':'Footprints in the Snow','storyText':'Leaving the tunnel, snow covered the embankment and tracks went north, east and back to the train. Holmes noted the impossible geometry.'},
    'train:10': {'chapterTitle':'The Lightless Tunnel','storyTitle':'The Conductor Card Game','storyText':'To calm passengers the conductor dealt ten cards, five face up and five down, blindfolded. Holmes split the deck theatrically.'},
    'train:11': {'chapterTitle':'The Final Station','storyTitle':'The Driver Birthday','storyText':'The driver, questioned, tangled his age: saying he was a certain age the day before yesterday and will be more next year than seems possible.'},
    'train:12': {'chapterTitle':'The Final Station','storyTitle':'The Platform Lamps','storyText':'At the final platform three oil lamps burned by the locker where the loot waited. Holmes forced the locker: inside, the ruby…'},
    'train:13': {'chapterTitle':'The Final Station','storyTitle':'The Vestibule Mosaic (VISUAL)','storyText':'The station hall had a 2x2 tile mosaic with inscription: "Count all and find the exit". The cornered banker demanded to solve it.'},
    'train:14': {'chapterTitle':'The Final Station','storyTitle':'The Hourglasses','storyText':'The banker asked for five minutes and challenged with two silver hourglasses: seven minutes and four. "Measure nine exact and I will tell where the rest is".'},
    'train:15': {'chapterTitle':'The Final Station','storyTitle':'The Platform Basket','storyText':'He confessed before the last grain fell: he faked his disappearance to collect insurance, sharing six apples among six children leaving one in the basket.'},
    // Abbey 15
    'abbey:1': {'chapterTitle':'The Whispering Gallery','storyTitle':'Fog in the Cloister','storyText':'An abbot called us to his ruined abbey: each night the gallery whispers a name and the choir reliquary vanished. Holmes pressed ear to ancient stone.'},
    'abbey:2': {'chapterTitle':'The Whispering Gallery','storyTitle':'The Pond Fisherman','storyText':'The gate brother fished in the abbey pond and swore he caught impossible fish the night of the theft: fish without head, without back and without tail.'},
    'abbey:3': {'chapterTitle':'The Whispering Gallery','storyTitle':'The Choir Brothers','storyText':'Six choir brothers declared before the abbot, each claiming the same sister among the neighboring convent novices.'},
    'abbey:4': {'chapterTitle':'The Whispering Gallery','storyTitle':'The Mason Cube','storyText':'The mason restored a 3x3x3 red-painted stone cube crowning the well, arguing how many blocks had two painted faces.'},
    'abbey:5': {'chapterTitle':'The Whispering Gallery','storyTitle':'The Stained Glass Fly','storyText':'A fly circled the square chapel stained glass, ten cm per side, doing a full lap. The glazier asked what distance it walked.'},
    'abbey:6': {'chapterTitle':'The Whispering Gallery','storyTitle':'The Rose Window Odd (VISUAL)','storyText':'The choir rose window showed four almost identical stained glasses the thief touched: three equal and one different marked the stolen psalm.'},
    'abbey:7': {'chapterTitle':'The Stolen Manuscript','storyTitle':'The Prior Chests','storyText':'The prior kept alms in five large chests with medium chests inside, claiming accounts did not add after the theft.'},
    'abbey:8': {'chapterTitle':'The Stolen Manuscript','storyTitle':'The Gardener Cart','storyText':'The gardener drove sixty kilometers with his cart at steady pace to sell convent cabbages, arguing rhythm with the abbot.'},
    'abbey:9': {'chapterTitle':'The Stolen Manuscript','storyTitle':'The Collection Coins','storyText':'The alms box had four coins in a row someone reordered to hide the reliquary theft. Holmes inverted the row with two moves.'},
    'abbey:10': {'chapterTitle':'The Stolen Manuscript','storyTitle':'The Ghost Walk','storyText':'The "ghost" walked each night three km north, four east and three south, according to terrified novices. I measured and found it ended at the walled crypt door.'},
    'abbey:11': {'chapterTitle':'Dawn in the Cloister','storyTitle':'The Votive Coins (VISUAL)','storyText':'Behind the walled door we found the votive: ten gold coins in a pyramid the thief could not carry. A note demanded to invert the pyramid moving minimal coins.'},
    'abbey:12': {'chapterTitle':'Dawn in the Cloister','storyTitle':'The Tailor Scissors','storyText':'The village tailor, unwitting accomplice, had cut the thief cassock with one straight cut. He showed how to divide a square cloth into four squares with minimal cuts.'},
    'abbey:13': {'chapterTitle':'Dawn in the Cloister','storyTitle':'The Sacristan Deck','storyText':'The sacristan, card lover, shuffled his fifty-two deck while on guard. He bet how many cards to draw blind to guarantee an ace.'},
    'abbey:14': {'chapterTitle':'Dawn in the Cloister','storyTitle':'The Cellar Barrel','storyText':'In the cellar a barrel filled at five liters per minute but leaked two through a crack: perfect hideout for the rolled manuscript.'},
    'abbey:15': {'chapterTitle':'Dawn in the Cloister','storyTitle':'The Dawn Candles','storyText':'At dawn three candles burned in the choir and the rose window wind blew out two. The abbot asked how many remained: the thief — the bursar — confessed.'},
  };

  bool get _isTest => WidgetsBinding.instance.runtimeType.toString().contains('Test');
  @override
  Future<List<StoryBook>> getLibrary() async {
    final locale = _localeService.value.languageCode;
    if (_cache.containsKey(locale)) return _cache[locale]!;
    if (!_isTest) await Future.delayed(const Duration(milliseconds: 300));
    if (locale == 'en') {
      // Nebelheim EN
      final enNebelheim = StoryBook(id:'nebelheim', stage:1, title:'The Stopped Clock of Nebelheim', subtitle:'Stage 1 · The mystery of the stopped tower', description:'Nebelheim tower stopped at 10:10 and the clockmaker vanished. 30 pages to bring the village heartbeat back.', coverKey:'clock', colorValue:0xFF4E342E, pages: nebelheimEnPages);
      // Other books via builders then translated
      final lhEs = await buildLighthouseBook(classicPuzzles);
      final caEs = await buildCarnivalBook(classicPuzzles);
      final obEs = await buildObservatoryBook(classicPuzzles);
      final trEs = await buildTrainBook(classicPuzzles);
      final abEs = await buildAbbeyBook(classicPuzzles);
      final books = [enNebelheim, _translateBook(lhEs), _translateBook(caEs), _translateBook(obEs), _translateBook(trEs), _translateBook(abEs)];
      books.sort((a,b)=>a.stage.compareTo(b.stage));
      _cache[locale]=books;
      return books;
    }
    if (_cache.containsKey('es')) return _cache['es']!;
    if (!_isTest) await Future.delayed(const Duration(milliseconds: 300));
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
    _cache['es'] = books;
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
      pageNumber: 1, collectibleId: 'nebelheim-1',
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
        experiencia: 20,
        correctAnswer: '11',
        hintText: 'Cuenta los intervalos entre campanadas, no las campanadas.',
      ),
    ),
    BookPage(
      pageNumber: 2, collectibleId: 'nebelheim-2',
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
        experiencia: 30,
        correctAnswer: '7',
        hintText: 'En algún momento tendrás que traer de vuelta a la cabra.',
      ),
    ),
    BookPage(
      pageNumber: 3, collectibleId: 'nebelheim-3',
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
        experiencia: 20,
        correctAnswer: '7',
        hintText: 'Todos los hermanos comparten la misma hermana.',
        type: PuzzleType.multipleChoice,
        options: ['6', '7', '12', '13'],
      ),
    ),
    BookPage(
      pageNumber: 4, collectibleId: 'nebelheim-4',
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
        experiencia: 15,
        correctAnswer: 'la cerilla',
        hintText: 'Sin ella no puedes encender nada más.',
        type: PuzzleType.multipleChoice,
        options: ['la vela', 'la lámpara', 'la cerilla', 'la estufa'],
      ),
    ),
    BookPage(
      pageNumber: 5, collectibleId: 'nebelheim-5',
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
        experiencia: 25,
        correctAnswer: '■',
        hintText: 'El patrón se repite cada 3 figuras: círculo, triángulo, cuadrado.',
        type: PuzzleType.visualChoice,
        options: ['●', '▲', '■', '★'],
        visualKind: 'shapes_sequence',
        visualPayload: '●,▲,■,●,▲,?',
      ),
    ),
    BookPage(
      pageNumber: 6, collectibleId: 'nebelheim-6',
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
        experiencia: 20,
        correctAnswer: '14',
        hintText: 'Resta a 21 las dos caras que sí ves: 5 y 2.',
        type: PuzzleType.multipleChoice,
        options: ['12', '14', '16', '19'],
      ),
    ),
    // ── CAPÍTULO 2: La plaza detenida (7-12) ──
    BookPage(
      pageNumber: 7, collectibleId: 'nebelheim-7',
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
        experiencia: 25,
        correctAnswer: '47',
        hintText: 'El día anterior al lleno total ocupaban justo la mitad.',
      ),
    ),
    BookPage(
      pageNumber: 8, collectibleId: 'nebelheim-8',
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
        experiencia: 45,
        correctAnswer: '312211',
        hintText: 'Lee cada número en voz alta contando las cifras: "una vez uno"...',
      ),
    ),
    BookPage(
      pageNumber: 9, collectibleId: 'nebelheim-9',
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
        experiencia: 20,
        correctAnswer: '8',
        hintText: 'Cada persona brinda 2 veces, pero cada brindis se cuenta una sola vez.',
      ),
    ),
    BookPage(
      pageNumber: 10, collectibleId: 'nebelheim-10',
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
        experiencia: 40,
        correctAnswer: 'azul',
        hintText: 'Si solo una dice la verdad, prueba suponer que es la del cofre azul.',
        type: PuzzleType.visualChoice,
        options: ['rojo', 'azul', 'verde'],
        visualKind: 'chests',
        visualPayload: 'rojo,azul,verde',
      ),
    ),
    BookPage(
      pageNumber: 11, collectibleId: 'nebelheim-11',
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
        experiencia: 25,
        correctAnswer: '0.5',
        hintText: 'Plantea X + (X + 10) = 11.',
        type: PuzzleType.multipleChoice,
        options: ['0.5', '1', '1.5', '5'],
      ),
    ),
    BookPage(
      pageNumber: 12, collectibleId: 'nebelheim-12',
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
        experiencia: 30,
        correctAnswer: '78',
        hintText: 'Suma del 1 al 12: (12 × 13) / 2.',
      ),
    ),
    // ── CAPÍTULO 3: La biblioteca subterránea (13-18) ──
    BookPage(
      pageNumber: 13, collectibleId: 'nebelheim-13',
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
        experiencia: 15,
        correctAnswer: '3',
        hintText: 'Solo hay dos colores posibles.',
        type: PuzzleType.multipleChoice,
        options: ['2', '3', '10', '11'],
      ),
    ),
    BookPage(
      pageNumber: 14, collectibleId: 'nebelheim-14',
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
        experiencia: 25,
        correctAnswer: '2',
        hintText: 'Debe recorrer 2 km en total.',
      ),
    ),
    BookPage(
      pageNumber: 15, collectibleId: 'nebelheim-15',
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
        experiencia: 20,
        correctAnswer: '5',
        hintText: 'Dos triángulos sueltos serían 6, pero comparten 1 cerilla.',
        type: PuzzleType.visualChoice,
        options: ['4', '5', '6', '7'],
        visualKind: 'matchsticks',
        visualPayload: '2-triangulos-comparten-lado',
      ),
    ),
    BookPage(
      pageNumber: 16, collectibleId: 'nebelheim-16',
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
        experiencia: 25,
        correctAnswer: '10',
        hintText: 'Dos páginas consecutivas de una hoja suman un impar: N + (N+1) = 21.',
      ),
    ),
    BookPage(
      pageNumber: 17, collectibleId: 'nebelheim-17',
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
        experiencia: 35,
        correctAnswer: '6',
        hintText: 'Llena la de 5, pasa a la de 3, vacía la de 3 y pasa los 2 sobrantes.',
        type: PuzzleType.multipleChoice,
        options: ['4', '5', '6', '8'],
      ),
    ),
    BookPage(
      pageNumber: 18, collectibleId: 'nebelheim-18',
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
        experiencia: 15,
        correctAnswer: '21',
        hintText: 'Suma los dos últimos números.',
        type: PuzzleType.multipleChoice,
        options: ['18', '20', '21', '22'],
      ),
    ),
    // ── CAPÍTULO 4: El taller del relojero (19-24) ──
    BookPage(
      pageNumber: 19, collectibleId: 'nebelheim-19',
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
        experiencia: 25,
        correctAnswer: '3',
        hintText: 'Para el primero máximo 2 fallos; para el segundo, 1.',
        type: PuzzleType.multipleChoice,
        options: ['2', '3', '5', '6'],
      ),
    ),
    BookPage(
      pageNumber: 20, collectibleId: 'nebelheim-20',
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
        experiencia: 20,
        correctAnswer: '7',
        hintText: 'El otro lado pesa 3×4 + 2×1 = 14 kg.',
        type: PuzzleType.visualChoice,
        options: ['5', '6', '7', '8'],
        visualKind: 'balance',
        visualPayload: '3x4+2x1 vs Nx2',
      ),
    ),
    BookPage(
      pageNumber: 21, collectibleId: 'nebelheim-21',
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
        experiencia: 50,
        correctAnswer: '17',
        hintText: 'Las dos personas más lentas deben cruzar juntas.',
      ),
    ),
    BookPage(
      pageNumber: 22, collectibleId: 'nebelheim-22',
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
        experiencia: 55,
        correctAnswer: '042',
        hintText: 'El 6 queda descartado; el 2 y el 0 están mal ubicados en la tercera pista.',
      ),
    ),
    BookPage(
      pageNumber: 23, collectibleId: 'nebelheim-23',
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
        experiencia: 45,
        correctAnswer: '204',
        hintText: 'Suma 1² + 2² + … + 8².',
        type: PuzzleType.multipleChoice,
        options: ['64', '128', '204', '256'],
      ),
    ),
    BookPage(
      pageNumber: 24, collectibleId: 'nebelheim-24',
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
        experiencia: 15,
        correctAnswer: '3',
        hintText: 'Van en una sola fila en hilera.',
        type: PuzzleType.multipleChoice,
        options: ['3', '4', '5', '6'],
      ),
    ),
    // ── CAPÍTULO 5: La medianoche (25-30) ──
    BookPage(
      pageNumber: 25, collectibleId: 'nebelheim-25',
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
        experiencia: 35,
        correctAnswer: '14',
        hintText: 'Suma 9 + 4 + 1.',
        type: PuzzleType.visualChoice,
        options: ['9', '12', '13', '14'],
        visualKind: 'grid_squares',
        visualPayload: '3x3',
      ),
    ),
    BookPage(
      pageNumber: 26, collectibleId: 'nebelheim-26',
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
            'El guardián del carillón pronuncia la palabra "ocho" y debes responder 4. Pronuncia "catorce" y respondes 7. Pronuncia "seis". ¿Qué debes responder?',
        experiencia: 30,
        correctAnswer: '4',
        hintText: 'No es la mitad: cuenta las letras de la palabra pronunciada ("ocho" tiene 4, "catorce" 7, "seis" 4).',
        type: PuzzleType.multipleChoice,
        options: ['2', '3', '4', '6'],
      ),
    ),
    BookPage(
      pageNumber: 27, collectibleId: 'nebelheim-27',
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
        experiencia: 25,
        correctAnswer: '4',
        hintText: 'La mitad del agua pesa 20 − 12 = 8 kg.',
        type: PuzzleType.multipleChoice,
        options: ['2', '4', '6', '8'],
      ),
    ),
    BookPage(
      pageNumber: 28, collectibleId: 'nebelheim-28',
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
        experiencia: 30,
        correctAnswer: '16',
        hintText: 'El día 16 sube los últimos 5 m sin resbalar.',
      ),
    ),
    BookPage(
      pageNumber: 29, collectibleId: 'nebelheim-29',
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
        experiencia: 25,
        correctAnswer: '24',
        hintText: 'Calcula el mínimo común múltiplo de 8 y 12.',
        type: PuzzleType.multipleChoice,
        options: ['16', '20', '24', '48'],
      ),
    ),
    BookPage(
      pageNumber: 30, collectibleId: 'nebelheim-30',
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
        experiencia: 50,
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
