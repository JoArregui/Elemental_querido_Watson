import 'package:flutter_test/flutter_test.dart';
import 'package:layton_app/features/book/data/datasources/book_local_data_source.dart';
import 'package:layton_app/features/puzzle/data/datasources/puzzle_local_data_source.dart';
import 'package:layton_app/main.dart';
import 'package:layton_app/injection_container.dart' as di;

void main() {
  testWidgets('La home muestra la biblioteca con los libros-etapa',
      (WidgetTester tester) async {
    await di.init();
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pump();

    expect(find.text('Biblioteca Layton'), findsOneWidget);
    expect(find.text('El Reloj Detenido de Nebelheim'), findsOneWidget);
    expect(find.text('El Faro de las Mareas Perdidas'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('La Estrella del Observatorio'),
      300,
    );
    await tester.pump();
    expect(find.text('El Carnaval de las Máscaras'), findsOneWidget);
    expect(find.text('La Estrella del Observatorio'), findsOneWidget);
  });

  test('La biblioteca tiene 4 libros con acertijos distintos', () async {
    final ds = BookLocalDataSourceImpl(
        classicPuzzles: PuzzleLocalDataSourceImpl());
    final books = await ds.getLibrary();

    expect(books.length, 4);
    expect(books.map((b) => b.stage).toList(), [1, 2, 3, 4]);
    // El libro 1 mantiene sus 30 páginas; los nuevos, 10 cada uno.
    expect(books[0].pageCount, 30);
    for (final b in books.skip(1)) {
      expect(b.pageCount, 10);
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
    expect(visuals.length, greaterThanOrEqualTo(9));
  });
}
