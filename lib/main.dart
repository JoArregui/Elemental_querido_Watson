import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/book/presentation/bloc/library_bloc.dart';
import 'features/book/presentation/bloc/library_event.dart';
import 'features/book/presentation/pages/library_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<LibraryBloc>()..add(const LoadLibraryEvent()),
      child: MaterialApp(
        title: 'Layton - Biblioteca de Acertijos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: const LibraryPage(),
      ),
    );
  }
}
