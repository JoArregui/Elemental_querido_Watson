import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elemental_querido_watson/features/book/data/datasources/book_local_data_source.dart';
import 'package:elemental_querido_watson/features/book/data/repositories/book_progress_repository.dart';
import 'package:elemental_querido_watson/features/book/data/services/tts_service.dart';
import 'package:elemental_querido_watson/features/book/presentation/bloc/book_bloc.dart';
import 'package:elemental_querido_watson/features/book/presentation/bloc/book_event.dart';
import 'package:elemental_querido_watson/features/book/presentation/pages/book_reader_page.dart';
import 'package:elemental_querido_watson/features/puzzle/data/datasources/puzzle_local_data_source.dart';
import 'package:elemental_querido_watson/main.dart';
import 'package:elemental_querido_watson/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('La splash se muestra 3.5s y entra en la biblioteca',
      (WidgetTester tester) async {
    await di.init();
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Splash de presentación con el título.
    expect(find.text('Elemental, querido Watson'), findsOneWidget);
    expect(find.text('Baker Street 221B, Londres'), findsOneWidget);

    // Tras 3.5 segundos entra en la biblioteca (que ya cargó de fondo).
    // Se avanza también el fundido de 600ms para que la splash salga del árbol.
    // Se avanza por pasos para dejar que las cargas encadenadas se resuelvan.
    await tester.pump(const Duration(milliseconds: 3500));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump();

    expect(find.text('Elemental, querido Watson'), findsOneWidget);
    expect(find.text('El Reloj Detenido de Nebelheim'), findsOneWidget);
    expect(find.text('El Faro de las Mareas Perdidas'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('La Abadía de los Susurros'),
      300,
    );
    await tester.pump();
    expect(find.text('El Misterio del Expreso de Medianoche'),
        findsOneWidget);
    expect(find.text('La Abadía de los Susurros'), findsOneWidget);
  });

  test('La biblioteca tiene 6 libros con acertijos distintos', () async {
    final ds = BookLocalDataSourceImpl(
        classicPuzzles: PuzzleLocalDataSourceImpl());
    final books = await ds.getLibrary();

    expect(books.length, 6);
    expect(books.map((b) => b.stage).toList(), [1, 2, 3, 4, 5, 6]);
    // El libro 1 mantiene sus 30 páginas; 2-4 tienen 10 y 5-6 tienen 15.
    expect(books[0].pageCount, 30);
    for (final b in books.skip(1).take(3)) {
      expect(b.pageCount, 10);
    }
    for (final b in books.skip(4)) {
      expect(b.pageCount, 15);
    }

    // Ningún acertijo se repite entre libros.
    final ids = books
        .expand((b) => b.pages.map((p) => p.puzzle.id))
        .toList();
    expect(ids.length, ids.toSet().length);

    // Visuales en varios libros.
    final visuals = books
        .expand((b) => b.pages)
        .where((p) => p.puzzle.visualKind != null)
        .toList();
    expect(visuals.length, greaterThanOrEqualTo(15));
  });

  test('La partida se guarda y se puede retomar', () async {
    final repo = BookProgressRepository();
    await repo.init();
    expect(repo.hasSave, isFalse);

    final firstSave = await repo.markSolved(
        bookId: 'nebelheim', puzzleId: 'B01', indicios: 20);
    expect(firstSave, isTrue);
    await repo.saveLastPosition(bookId: 'nebelheim', pageIndex: 4);

    // Una instancia nueva (p. ej. tras reiniciar la app) recupera todo.
    final resumed = BookProgressRepository();
    await resumed.init();
    expect(resumed.hasSave, isTrue);
    expect(resumed.solvedFor('nebelheim'), contains('B01'));
    expect(resumed.indiciosFor('nebelheim'), 20);
    expect(resumed.lastBookId, 'nebelheim');
    expect(resumed.lastPageIndex, 4);

    // Nueva partida: borra todo.
    await resumed.resetAll();
    final fresh = BookProgressRepository();
    await fresh.init();
    expect(fresh.hasSave, isFalse);
    expect(fresh.lastBookId, isNull);
  });

  testWidgets('El lector ofrece audiolibro y tamaño de letra',
      (WidgetTester tester) async {
    // Viewport alto para que la tarjeta quepa sin hacer scroll.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // El motor de voz no existe en tests: se simula el canal.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_tts'),
      (call) async => 1,
    );
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('flutter_tts'), null);
    });
    if (!di.sl.isRegistered<TtsService>()) {
      di.sl.registerLazySingleton(() => TtsService());
    }
    final ds = BookLocalDataSourceImpl(
        classicPuzzles: PuzzleLocalDataSourceImpl());
    final progress = BookProgressRepository();
    await progress.init();
    final bloc = BookBloc(dataSource: ds, progress: progress)
      ..add(const LoadBookEvent('lighthouse'));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: bloc,
          child: const BookReaderPage(bookId: 'lighthouse'),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.pump();

    expect(find.byTooltip('Escuchar página (audiolibro)'), findsOneWidget);
    expect(find.byTooltip('Tamaño de letra'), findsOneWidget);

    // Activar y detener la lectura no debe romper nada.
    await tester.tap(find.byTooltip('Escuchar página (audiolibro)'));
    await tester.pump();
    expect(find.byTooltip('Detener audiolibro'), findsOneWidget);
    await tester.tap(find.byTooltip('Detener audiolibro'));
    await tester.pump();
    expect(find.byTooltip('Escuchar página (audiolibro)'), findsOneWidget);

    // Cambiar el tamaño de letra tampoco.
    await tester.tap(find.byTooltip('Tamaño de letra'));
    await tester.pump();

    // Resolver la página 1 (puzle 007, respuesta "2") muestra la
    // celebración de ~3.2s y luego el botón de pasar página.
    await tester.enterText(find.byType(TextField).first, '2');
    await tester.tap(find.text('Responder').first);
    await tester.pump();
    expect(find.text('¡Página 1 resuelta!'), findsOneWidget);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pump();
    expect(find.text('¡Página 1 resuelta!'), findsNothing);
    expect(find.text('Pasar la página →'), findsOneWidget);
  });
}
