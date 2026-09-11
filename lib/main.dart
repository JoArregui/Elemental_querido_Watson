import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/puzzle/presentation/bloc/board_bloc.dart';
import 'features/puzzle/presentation/bloc/board_event.dart';
import 'features/puzzle/presentation/bloc/puzzle_bloc.dart';
import 'features/puzzle/presentation/pages/board_page.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<BoardBloc>()..add(InitBoardEvent('')),
        ),
        BlocProvider(
          create: (_) => di.sl<PuzzleBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Profesor Layton - Tablero Dinámico',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: const BoardPage(),
      ),
    );
  }
}
