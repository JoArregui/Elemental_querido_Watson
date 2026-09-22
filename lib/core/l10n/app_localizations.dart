import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ?? const AppLocalizations(Locale('es'));

  static const _localizedValues = <String, Map<String, String>>{
    'es': {
      'appTitle': 'Elemental, querido Watson',
      'appSubtitle': 'Biblioteca de casos · cada libro es una etapa',
      'continueGame': 'Continuar partida',
      'newGame': 'Nueva partida',
      'confirmNewGameTitle': '¿Empezar una nueva partida?',
      'confirmNewGameBody': 'Se borrará todo el progreso guardado: acertijos resueltos, experiencia y la última posición. Esta acción no se puede deshacer.',
      'cancel': 'Cancelar',
      'deleteAndStart': 'Borrar y empezar',
      'newGameSnick': 'Partida nueva: la biblioteca vuelve a empezar.',
      'stage': 'ETAPA',
      'pages': 'págs.',
      'solved': 'acertijos',
      'completed': 'Completado',
      'lockedStage': 'La etapa {stage} se desbloquea al completar "{title}".',
      'xp': 'experiencia',
      'rankApprentice': 'Aprendiz',
      'rankInvestigator': 'Investigador',
      'rankWatson': 'Watson',
      'rankHolmes': 'Holmes',
      'dailyChallenge': 'Reto diario',
      'loadingDaily': 'Cargando reto diario...',
      'streak': 'Racha',
      'language': 'Idioma',
      'spanish': 'Español',
      'english': 'English',
      'selectLanguage': 'Seleccionar idioma',
      // reader
      'bookStage': 'Etapa {stage} · {count} páginas · 1 acertijo por página',
      'openingBook': 'Abriendo el libro…',
      'aBookOfPuzzles': 'Un libro de acertijos',
      'pageOf': 'Página {current} / {total}',
      'puzzlesSolved': '{count} acertijos resueltos',
      'gainXpIfSolve': '¡+{xp} ⭐ si aciertas esta!',
      'gainedXp': '¡Sumaste los experiencia!',
      'bookSheetPuzzle': '✦  Acertijo de la página {num}  ✦',
      'passPage': 'Pasar la página →',
      'solveAndGain': '¡Resuélvelo y gana +{xp} experiencia ⭐! Si saltas, los pierdes.',
      'continueWithoutSolving': 'Continuar sin resolver →',
      'hintUse': 'usa el botón "Pista" del acertijo — ¡cada acierto cuenta!',
      'lastPageUnsolved': 'Última página sin resolver: te faltan {xp} ⭐.',
      'viewFinalSummary': 'Ver resumen final',
      'viewFinalWithXp': 'Ver resumen final (con {xp}/{max} ⭐)',
      'finalPerfect': '¡Fin del libro perfecto!',
      'finalGood': '¡Caso resuelto!',
      'finalHalf': '¡Libro terminado!',
      'finalLow': '¡Historia completada!',
      'finalPerfectQuote1': 'La torre de Nebelheim vuelve a latir. Holmes cierra su violín y yo sonrío: "Todo caso digno termina… con otro misterio".',
      'finalGenericQuote': '"{title}" queda resuelto. Holmes enciende su pipa: "Es elemental, querido Watson".',
      'finalGoodQuote': 'Holmes asiente: "Buen trabajo, Watson. Quedaron cabos sueltos, pero el misterio principal está resuelto".',
      'finalHalfQuote': 'Watson anota: "Avanzamos, pero varios enigmas nos vencieron. Volveremos con más pistas".',
      'finalLowQuote': 'Holmes guarda la lupa: "Leímos la historia, mas los acertijos nos superaron. Reinténtalos para el final verdadero".',
      'xpScore': '⭐ {xp} / {max} experiencia',
      'solvedOf': '{solved}/{total} acertijos resueltos',
      'backToLibrary': 'Volver a la biblioteca',
      'goToStart': 'Ir al inicio',
      'reread': 'Releer página a página',
      'retryPending': 'Intentar acertijos pendientes',
      'startOver': 'Empezar de nuevo',
      'indexTitle': 'Índice del libro',
      'streakFire': '🔥 {count}',
      // puzzle card
      'dareAndGain': '¡Atrévete! Acierta y gana +{xp} experiencia ⭐ para tu puntuación final.',
      'dareAndGain2': '¡Resuélvelo y gana +{xp} experiencia ⭐! Si saltas, los pierdes y tu puntuación final será menor.',
      'solvedCanPass': '¡Resuelto! Puedes pasar la página.',
      'answer': 'Responder',
      'writeAnswer': 'Escribe tu respuesta',
      'hint': 'Pista',
      'hintRecommended': 'Pista (recomendada)',
      'hideHint': 'Ocultar pista',
      'hideHints': 'Ocultar pistas',
      'hintLevel': 'Pista {level} / {total}',
      'free': 'gratis',
      'ifSolveNow': 'Si aciertas ahora: +{xp} XP',
      'incorrectStay': 'Respuesta incorrecta. ¡No te rindas! Aún puedes ganar +{xp} ⭐ si aciertas.',
      'correctXp': '¡Correcto! +{xp} experiencia',
      'skipConfirmTitle': '¿Saltar sin resolver?',
      'skipConfirmBody': 'Si continúas sin acertar, no ganarás los {xp} experiencia ⭐ de esta página y tu puntuación final será menor.\n\n¡Intenta adivinar! Cada acierto suma y acerca al 100%.',
      'keepTrying': 'Seguir intentando',
      'skipAnyway': 'Saltar igual',
      'start': 'Inicio',
      'back': 'Atrás',
      'next': 'Siguiente',
      'skip': 'Saltar',
      'viewEnd': 'Ver final',
    },
    'en': {
      'appTitle': 'Elementary, my dear Watson',
      'appSubtitle': 'Case library · each book is a stage',
      'continueGame': 'Continue',
      'newGame': 'New game',
      'confirmNewGameTitle': 'Start a new game?',
      'confirmNewGameBody': 'All saved progress will be deleted: solved puzzles, XP and last position. This cannot be undone.',
      'cancel': 'Cancel',
      'deleteAndStart': 'Delete & start',
      'newGameSnick': 'New game: the library starts over.',
      'stage': 'STAGE',
      'pages': 'pages',
      'solved': 'puzzles',
      'completed': 'Completed',
      'lockedStage': 'Stage {stage} unlocks after completing "{title}".',
      'xp': 'XP',
      'rankApprentice': 'Apprentice',
      'rankInvestigator': 'Investigator',
      'rankWatson': 'Watson',
      'rankHolmes': 'Holmes',
      'dailyChallenge': 'Daily challenge',
      'loadingDaily': 'Loading daily challenge...',
      'streak': 'Streak',
      'language': 'Language',
      'spanish': 'Español',
      'english': 'English',
      'selectLanguage': 'Select language',
      'bookStage': 'Stage {stage} · {count} pages · 1 puzzle per page',
      'openingBook': 'Opening book…',
      'aBookOfPuzzles': 'A puzzle book',
      'pageOf': 'Page {current} / {total}',
      'puzzlesSolved': '{count} puzzles solved',
      'gainXpIfSolve': '+{xp} ⭐ if you solve this!',
      'gainedXp': 'XP earned!',
      'bookSheetPuzzle': '✦  Page {num} puzzle  ✦',
      'passPage': 'Turn page →',
      'solveAndGain': 'Solve it and earn +{xp} XP ⭐! If you skip, you lose them.',
      'continueWithoutSolving': 'Continue without solving →',
      'hintUse': 'use the puzzle "Hint" button — every solve counts!',
      'lastPageUnsolved': 'Last page unsolved: {xp} ⭐ missing.',
      'viewFinalSummary': 'View final summary',
      'viewFinalWithXp': 'View final summary ({xp}/{max} ⭐)',
      'finalPerfect': 'Perfect book finish!',
      'finalGood': 'Case closed!',
      'finalHalf': 'Book finished!',
      'finalLow': 'Story completed!',
      'finalPerfectQuote1': 'Nebelheim tower ticks again. Holmes closes his violin and I smile: "Every worthy case ends… with another mystery".',
      'finalGenericQuote': '"{title}" solved. Holmes lights his pipe: "Elementary, my dear Watson".',
      'finalGoodQuote': 'Holmes nods: "Good work, Watson. Loose ends remain, but the main mystery is solved".',
      'finalHalfQuote': 'Watson notes: "We made progress, but several riddles beat us. We will return with more hints".',
      'finalLowQuote': 'Holmes pockets the lens: "We read the story, but the puzzles beat us. Retry for the true ending".',
      'xpScore': '⭐ {xp} / {max} XP',
      'solvedOf': '{solved}/{total} puzzles solved',
      'backToLibrary': 'Back to library',
      'goToStart': 'Go to start',
      'reread': 'Reread page by page',
      'retryPending': 'Retry pending puzzles',
      'startOver': 'Start over',
      'indexTitle': 'Book index',
      'streakFire': '🔥 {count}',
      'dareAndGain': 'Go for it! Solve and earn +{xp} XP ⭐ for your final score.',
      'dareAndGain2': 'Solve it and earn +{xp} XP ⭐! If you skip, you lose them and your final score will be lower.',
      'solvedCanPass': 'Solved! You can turn the page.',
      'answer': 'Answer',
      'writeAnswer': 'Type your answer',
      'hint': 'Hint',
      'hintRecommended': 'Hint (recommended)',
      'hideHint': 'Hide hint',
      'hideHints': 'Hide hints',
      'hintLevel': 'Hint {level} / {total}',
      'free': 'free',
      'ifSolveNow': 'If you solve now: +{xp} XP',
      'incorrectStay': 'Incorrect. Don\'t give up! You can still earn +{xp} ⭐ if you solve it.',
      'correctXp': 'Correct! +{xp} XP',
      'skipConfirmTitle': 'Skip without solving?',
      'skipConfirmBody': 'If you continue without solving, you will not earn the {xp} XP ⭐ from this page and your final score will be lower.\n\nTry guessing! Every correct answer counts toward 100%.',
      'keepTrying': 'Keep trying',
      'skipAnyway': 'Skip anyway',
      'start': 'Home',
      'back': 'Back',
      'next': 'Next',
      'skip': 'Skip',
      'viewEnd': 'View ending',
    },
  };

  String _t(String key, [Map<String, String> params = const {}]) {
    final lang = locale.languageCode == 'en' ? 'en' : 'es';
    var value = _localizedValues[lang]![key] ?? _localizedValues['es']![key] ?? key;
    params.forEach((k, v) => value = value.replaceAll('{$k}', v));
    return value;
  }

  // getters
  String get appTitle => _t('appTitle');
  String get appSubtitle => _t('appSubtitle');
  String get continueGame => _t('continueGame');
  String get newGame => _t('newGame');
  String get confirmNewGameTitle => _t('confirmNewGameTitle');
  String get confirmNewGameBody => _t('confirmNewGameBody');
  String get cancel => _t('cancel');
  String get deleteAndStart => _t('deleteAndStart');
  String get newGameSnick => _t('newGameSnick');
  String get language => _t('language');
  String get spanish => _t('spanish');
  String get english => _t('english');
  String get selectLanguage => _t('selectLanguage');
  String get dailyChallenge => _t('dailyChallenge');
  String get loadingDaily => _t('loadingDaily');
  String get openingBook => _t('openingBook');
  String get aBookOfPuzzles => _t('aBookOfPuzzles');
  String get viewFinalSummary => _t('viewFinalSummary');
  String get backToLibrary => _t('backToLibrary');
  String get goToStart => _t('goToStart');
  String get reread => _t('reread');
  String get retryPending => _t('retryPending');
  String get startOver => _t('startOver');
  String get indexTitle => _t('indexTitle');
  String get hintRecommended => _t('hintRecommended');
  String get hideHints => _t('hideHints');
  String get free => _t('free');
  String get dareAndGain => _t('dareAndGain'); // with param handled via tr()
  String tr(String key, [Map<String, String> p = const {}]) => _t(key, p);
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['es', 'en'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);
  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
