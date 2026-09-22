import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/l10n/app_localizations.dart';
import 'core/services/locale_service.dart';
import 'features/book/presentation/bloc/library_bloc.dart';
import 'features/book/presentation/bloc/library_event.dart';
import 'features/book/presentation/pages/splash_page.dart';
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
    final localeService = di.sl<LocaleService>();
    return ValueListenableBuilder<Locale>(
      valueListenable: localeService,
      builder: (context, locale, _) {
        return BlocProvider(
          create: (_) => di.sl<LibraryBloc>()..add(const LoadLibraryEvent()),
          child: MaterialApp(
            title: 'Elemental, querido Watson',
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: const [Locale('es'), Locale('en')],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              primarySwatch: Colors.amber,
              useMaterial3: false,
            ),
            home: const SplashPage(),
          ),
        );
      },
    );
  }
}
