# Elemental, querido Watson — Documentación Definitiva

> **Proyecto** `elemental_querido_watson` — `com.example.elemental_querido_watson` — **v1.0.0+1** — **SDK ^3.11.5**
> **Stack** Flutter (Android/iOS/Web/Windows) — **Ramas** `main` (producción, `origin/main`) / `develop` (integración, desde 2026-09-22)
> **Fecha de consolidación** 2026-09-23 — Reescritura completa. Este archivo sustituye a todos los anteriores (`DOCUMENTACION.md`, `ROADMAP_DEVELOP.md`, `README.md`). Es la **única fuente de verdad**.
> **Estado** C3, D1 y D2 terminados. Ver §16 para roadmap final.

---

## Índice

1. Visión y premisa
2. Ficha técnica
3. La biblioteca: 6 libros
4. Sistema de acertijos
5. Arquitectura
6. Dominio y entidades
7. BLoCs, estados y eventos
8. Persistencia y progreso
9. Navegación y páginas
10. Widgets
11. Servicios transversales
12. Internacionalización
13. Assets, marca y audio
14. Gamificación y progresión
15. Accesibilidad y responsive
16. Roadmap — estado final
17. Estructura de carpetas
18. Desarrollo y convenciones
19. Decisiones de diseño
20. Trabajo restante

---

## 1. Visión y premisa

**Elemental, querido Watson** es una biblioteca de **6 libros-etapa** de Holmes y Watson (dominio público). Cada **página** narra un fragmento y termina con **1 acertijo**. Resolverlo otorga **experiencia (XP) ⭐**; fallar no bloquea la lectura — se puede saltar con confirmación perdiendo el XP.

Es una **aventura narrativa de puzles** (`Puzzle > Aventura narrativa` en Play Store) con audiolibro con resaltado, pistas progresivas, finales ramificados, 90 coleccionables, 18 secretos y estadísticas.

La historia troncal es *El Reloj Detenido de Nebelheim* (torre a las 10:10, relojero Anselm, Marta, alcalde Crow, partitura de Elena). Los otros cinco libros son casos autoconclusivos con el mismo bucle.

**Principios de diseño:**
- Navegación libre (`BookState.isPageUnlocked` siempre `true`): leer siempre es posible; la recompensa requiere resolver.
- Saltar con coste: modal de confirmación, XP perdido y mensaje `skipConfirmBody`.
- Persistencia total en `SharedPreferences`: todo sobrevive a reinicios.

---

## 2. Ficha técnica

**`pubspec.yaml:1`** — `name: elemental_querido_watson`, `description: "Elemental, querido Watson: biblioteca de casos de Holmes y Watson."`, `publish_to: none`.

| Dependencia | Versión | Rol |
|---|---|---|
| `flutter` | sdk | Framework |
| `cupertino_icons` | ^1.0.8 | Iconos iOS |
| `flutter_bloc` | ^9.1.1 | `LibraryBloc`, `BookBloc`, `PuzzleBloc` |
| `dartz` | ^0.10.1 | `Either<Failure,T>` |
| `get_it` | ^9.2.1 | DI (`injection_container.dart:20`) |
| `equatable` | ^2.1.0 | Entidades/estados |
| `shared_preferences` | ^2.5.5 | Progreso, idioma, accesibilidad |
| `flutter_tts` | ^4.2.5 | Audiolibro C3 (`tts_service.dart:16`) |
| `audioplayers` | ^6.7.1 | Música por libro + duck (`audio_service.dart:1`) |
| `share_plus` | ^13.3.0 | Postal y export `.elemental` (`sync_service.dart:6`) |
| `flutter_localizations` | sdk | i18n |

**Dev:** `flutter_test`, `flutter_lints ^6.0.0`, `build_runner ^2.15.1`, `flutter_launcher_icons ^0.14.4`.

**Icono `pubspec.yaml:61`:** `flutter_launcher_icons` desde `assets/Icono_Watson.jpg`, `adaptive_icon_background: "#1A1009"`, `remove_alpha_ios: true`.

**Assets `pubspec.yaml:80`:**
```
assets/Icono_Watson.jpg
assets/Splash_Watson.jpg
assets/rewards/                 # 6 portadas nebelheim/lighthouse/carnival/observatory/train/abbey.png
assets/rewards/collectibles/    # 90 imágenes nebelheim-1..30, lighthouse-1..10, etc.
assets/rewards/secrets/         # 18 imágenes 101..118.png
assets/audio/                   # 6 loops nebelheim.wav, lighthouse.wav, carnival.wav, observatory.wav, train.wav, abbey.wav
```

---

## 3. La biblioteca: 6 libros

**Fuente** `lib/features/book/data/datasources/book_local_data_source.dart:27` — `BookLocalDataSourceImpl` (`getLibrary`, `getBook`, `getBookPages`). Caché por `locale`, delay 300 ms (`if (!_isTest) Future.delayed`) salvo en tests.

| Etapa | ID | Título ES | Título EN | Págs | Ambientación | `coverKey` | `colorValue` |
|---|---|---|---|---|---|---|---|
| 1 | `nebelheim` | El Reloj Detenido de Nebelheim | The Stopped Clock of Nebelheim | **30** | Villa, torre 10:10 | `clock` | `0xFF4E342E` |
| 2 | `lighthouse` | El Faro de las Mareas Perdidas | *vía `_enPageMap`* | 10 | Pueblo pesquero, contrabando | `lighthouse` | `0xFF0D47A1` |
| 3 | `carnival` | El Carnaval de las Máscaras | — | 10 | Robo en carnaval | `masks` | `0xFF6A1B9A` |
| 4 | `observatory` | La Estrella del Observatorio | — | 10 | Noche del cometa Azul | `observatory` | `0xFF1A237E` |
| 5 | `train` | El Misterio del Expreso de Medianoche | — | 15 | Tren nocturno | `train` | `0xFF3E2723` |
| 6 | `abbey` | La Abadía de los Susurros | — | 15 | Relicario, monjes | `abbey` | `0xFF3E2723` |

Total jugable **90 páginas**. Cada `BookPage` (`book_page.dart:5`) trae `pageNumber`, `chapterLabel/Title`, `storyTitle/Text`, `puzzle: Puzzle`, `collectibleId` (`nebelheim-1` … `abbey-15`) y `watsonNote` opcional.

- **Libro 1** (`book_local_data_source.dart:231`) es `static const List<BookPage> _pages` inline: 5 capítulos × 6 págs (carta del relojero 1-6, plaza detenida 7-12, biblioteca subterránea 13-18, taller 19-24, medianoche 25-30).
- **Libros 2–6** se construyen con `buildLighthouseBook` / `buildCarnivalBook` / `buildObservatoryBook` / `buildTrainBook` / `buildAbbeyBook` (`books/*.dart:1`), reutilizando **100 puzzles clásicos** por `id` desde `PuzzleLocalDataSource`. Ningún `id` se repite entre libros (test). Traducción EN en `_translateBook` + `_enPageMap:94` y puzzles `F05/C05/O05/O09/O10/T08/T13/A06/A11` → `f05En` etc. en `lib/core/l10n/book_en.dart:1`.
- **Desbloqueo** (`library_page.dart:46`): etapa 1 siempre abierta; `isBookUnlocked(i)` exige `solvedCount(anterior)==pageCount`. Dentro del libro, navegación libre.

---

## 4. Sistema de acertijos

### 4.1 Tipos

`lib/features/puzzle/domain/entities/puzzle.dart:3`:

```dart
enum PuzzleType { textInput, multipleChoice, visualChoice }
```

- **Texto libre** (`textInput`): `TextField`, compara normalizado `correctAnswer.trim().toLowerCase() == answer.trim().toLowerCase()` (`puzzle.dart:57`).
- **Opción múltiple / visual con opciones** (`multipleChoice`/`visualChoice`): `ChoiceChip` (`puzzle_card.dart:166`).
- **Visuales** (`visual_puzzle_widget.dart:13`, sin assets): `shapes_sequence`, `odd_one_out`, `chests`, `matchsticks`, `coin_triangle`, `balance`, `grid_squares` (2×2/3×3/4×4), `dials` (previstos `drag_order`, `slider_number`, `dial_interactive`). `visualPayload` varía el contenido (ej. `●,▲,■,●,▲,?`).

### 4.2 Catálogo clásico — 100 puzzles

`lib/features/puzzle/data/datasources/puzzle_local_data_source.dart:12` — `_esPuzzlesList` / `_enPuzzlesList`. Acceso vía `PuzzleRepositoryImpl` + usecases `GetPuzzle`/`GetAllPuzzles` (`Either`). Cada `PuzzleModel` (`puzzle_model.dart:10`) tiene `hints: List<String>` (3 por puzzle, ej. 001: `"Cuenta intervalos..."` / `"5s/5 huecos..."` / `"11 huecos"`), `hintText` legacy, `experiencia` 10–60, `correctAnswer`, `type/options/visualKind/visualPayload`, y `difficulty` (`puzzle.dart:48`: `>=40 hard`, `>=25 medium`, resto `easy`) + `allHints`/`hintForLevel`.

IDs 001–100 cubren: campanadas 11, río 7, sombreros 3, velas 2, interruptores 2, jarras 6, monedas 2, cuerdas 5, edades 5, gato 2, nenúfares 47, pastel 8, náufragos 100, calcetines 3, secuencia `312211`, caramelos 7, túnel 2, familia 7, caracol 8, cubos 1, código `042`, manzanas 3, ladrillo 3, cajas 1, bolígrafo 0.5, dados 19, oso blanco, cartas 2, cumpleaños 31 dic, brindis 8, gatos 3, mosca 80, tonel 4, pastor 9, pirámide 14, cerilla, nueves `99+9/9`, retrato su hijo, lámparas 12, relojes arena 9, cesta sí, 1089, páginas 10, vapor ningún lado, balanza 2, cerrojos 3, serie 64, harina 20, puente 17, dados 7, cerillas 5, patos 3, monedas 1, rueda 16, 1 de enero, eléctrico ningún lado, peces 0, hermanos 2, campanario 78, cubo 12, cuadrados 36, manzanas 3, tapón 0.05, mosca 40, ángulos 4, cajas 20, meses 12, rana 16, coche 1, contraseña 4, monedas 2, árbol 8, balanza 7, tijeras 2, ases 49, perro cuerda suelta, fibonacci 21, barril 5, velas 2, tablero 204, cerdos 4, manzana 3, barco nunca, chapas 4, sobres verde, invertido 12, etc. (ver archivo fuente líneas 21–900+).

### 4.3 Puzzles de los libros

Libro 1 usa **B01–B30 inline** (no del pool 001–100), XP 15–55:

| Pág | ID | Título | XP | Resp. |
|---|---|---|---|---|
|1|B01|Las campanadas|20|11|
|2|B02|El cruce del río|30|7|
|3|B03|La familia de la niña|20|7|
|4|B04|La cerilla primera|15|la cerilla|
|5|B05|La secuencia del friso|25|■|
|6|B06|Los dados opuestos|20|14|
|7|B07|El lago de nenúfares|25|47|
|8|B08|La secuencia que habla|45|312211|
|9|B09|Los brindis|20|8|
|10|B10|Los cofres mentirosos|40|azul|
|11|B11|El precio del recuerdo|25|0.5|
|12|B12|Las campanadas del campanario|30|78|
|13|B13|Los calcetines a oscuras|15|3|
|14|B14|El tren del túnel|25|2|
|15|B15|Los triángulos de cerillas|20|5|
|16|B16|Las páginas arrancadas|25|10|
|17|B17|Las jarras|35|6|
|18|B18|Fibonacci|15|21|
|19|B19|Las tres llaves|25|3|
|20|B20|La balanza exacta|20|7|
|21|B21|El puente de noche|50|17|
|22|B22|El candado del diario|55|042|
|23|B23|El tablero de la melodía|45|204|
|24|B24|Los patos de la escalera|15|3|
|25|B25|El mosaico|35|14|
|26|B26|La contraseña del carillón|30|4|
|27-30|B27-30|El corazón detenido y cierre|—|—|

Libros 2–6 reutilizan del pool (ej. Lighthouse: `007,005,003,004,010,009…`).

### 4.4 Pistas, dificultad, vidas y bonus

- **Pistas progresivas:** `Puzzle.hints` (`puzzle.dart:16`) + `hintForLevel`. `PuzzleCard` (`puzzle_card.dart:32`) lleva `_hintLevel 0..3`; cada uso resta **-5 XP** (`book_bloc.dart:114`: `penalty=(hints*5).clamp(0,exp-1)`, `awarded=(exp-penalty).clamp(1,999)`). Auto-pista al fallar 1 vez → nivel 1, al fallar 2 veces → nivel 2 + mensaje *“el siguiente fallo cambia la historia”*.
- **Dificultad:** `easy <25`, `medium 25-39`, `hard 40+` (`puzzle.dart:48`). Reordenamiento Easy→Hard pendiente (A2 resto).
- **Vidas:** `isBlockedByAttempts = failedAttempts>=3` (`book_state.dart:73`), `BookBloc` bloquea `SubmitPageAnswerEvent`. Tras 2 fallos se marca `branchedPuzzleIds` y al avanzar (`NextPageEvent:62`) se sustituye la siguiente página por puzzle **101–112** (`_branchIdFor`).
- **Contrarreloj:** `_isTimed/_secondsLeft` (`book_reader_page.dart:34`) + `timedBonus` → `awarded*1.3`.
- **XP:** entero por puzzle; suma por libro `StoryBook.totalexperiencia` (`story_book.dart:29`) y global `BookProgressRepository.totalexperiencia()`.

---

## 5. Arquitectura

```
lib/
├── main.dart
├── injection_container.dart
├── core/
│   ├── error/failures.dart
│   ├── usecases/usecase.dart
│   ├── l10n/app_localizations.dart + book_en.dart
│   ├── services/ tts_service.dart(C3) + audio_service.dart + feedback_service.dart + locale_service.dart + sync_service.dart + accessibility_service.dart
│   └── widgets/responsive.dart
└── features/
    ├── book/
    │   ├── data/datasources/book_local_data_source.dart + books/*.dart
    │   ├── data/repositories/book_progress_repository.dart(D1) + daily_puzzle_repository.dart
    │   ├── data/services/tts_service.dart
    │   ├── domain/entities/story_book.dart + book_page.dart
    │   └── presentation/bloc/{book,library}_* + pages/{splash,library,book_reader,map,stats}_page.dart + widgets/{puzzle_card,visual_puzzle_widget,solved_celebration,daily_banner}.dart
    └── puzzle/
        ├── data/datasources/puzzle_local_data_source.dart + models/puzzle_model.dart + repositories/puzzle_repository_impl.dart
        ├── domain/entities/puzzle.dart + repositories/puzzle_repository.dart + usecases/get_puzzle.dart + get_all_puzzles.dart
        └── presentation/bloc/puzzle_*.dart
```

**DI `injection_container.dart:22`:**
- Factories: `PuzzleBloc`, `BookBloc(dataSource,progress)`, `LibraryBloc(dataSource,progress)`.
- LazySingletons: `GetPuzzle`, `GetAllPuzzles`, `PuzzleRepositoryImpl`, `TtsService`, `FeedbackService`, `AudioService`, `DailyPuzzleRepository`, `SyncService`, `PuzzleLocalDataSourceImpl`, `BookLocalDataSourceImpl`.
- Singletons con `init()`: `BookProgressRepository`, `LocaleService`, `AccessibilityService`.

**Flujos:**
- **Biblioteca** (`LibraryBloc`): `LoadLibraryEvent` → `_load` (lee `BookLocalDataSource.getLibrary()` + `BookProgressRepository` por libro) → `LibraryLoaded`; `incrementSessions()` cada carga (D1).
- **Lector** (`BookBloc`): `LoadBookEvent` → `BookLoaded` + `saveLastPosition`; `SubmitPageAnswerEvent(answer,hintsUsed,timedBonus)` → `checkAnswer` → `recordAttempt` (D1) + `markSolved` con XP ajustado o `failedAttempts++` + `recordBranch` al 2º fallo; `GoToPage/NextPage/PreviousPage/ClearPageResult/ResetBook`.

---

## 6. Dominio y entidades

- **`StoryBook`** (`story_book.dart:6`): `id, stage, title, subtitle, description, coverKey, colorValue, pages`. `pageCount`, `totalexperiencia`.
- **`BookPage`** (`book_page.dart:5`): `pageNumber, chapterLabel/Title, storyTitle/Text, puzzle, collectibleId, watsonNote`. `copyWith` para branching.
- **`Puzzle`** (`puzzle.dart:9`): `id, title, statement, experiencia, correctAnswer, hintText, hints, type, options, visualKind/visualPayload`. `allHints`, `hintForLevel`, `isVisual`, `hasOptions`, `difficulty`, `checkAnswer`.
- **`PuzzleModel`** (`puzzle_model.dart:10`): extiende `Puzzle`.

---

## 7. BLoCs, estados y eventos

**Library:** estados `LibraryInitial/Loading/Loaded(books,solvedCounts,completedBookIds,experienciaPerBook,totalexperiencia,lastBookId/lastPageIndex,hasSave,resumeBook)/Error`; eventos `LoadLibraryEvent/RefreshLibraryEvent/ResetAllProgressEvent`; helpers `isBookUnlocked`, `solvedFor`.

**Book (lector)** (`book_state.dart:5`):
- Estados `BookInitial/Loading/Loaded(book,pages,currentIndex,solvedPuzzleIds,totalexperiencia,lastAnswerCorrect?,failedAttemptsOnPage,branchedPuzzleIds,lastWasAlternative)/Error`.
- Getters: `currentPage`, `isCurrentSolved`, `solvedCount`, `progress`, `isPageUnlocked=>true`, `canGoNext/canGoPrevious/isLastPage/isFirstPage`, `maxPossibleexperiencia/missedexperiencia`, `isBlockedByAttempts/canAttempt`, `isFullyCompleted`, `completionRate`, `endingTier` (`perfect` si fullyCompleted, `good >=0.7`, `half >=0.4`, `low`), `isBookCompleted`.
- Eventos `LoadBookEvent(bookId,initialPage)`, `GoToPageEvent`, `NextPageEvent`, `PreviousPageEvent`, `SubmitPageAnswerEvent(answer,hintsUsed,timedBonus)`, `ClearPageResultEvent`, `ResetBookEvent`.
- **Branching** (`book_bloc.dart:170`): `_branchIdFor` `B05→101, B10→102, 007→103, 005→104, C05→105, O05→106, T08→107, A06→108, B22→109, B25→110, 009→111, 029→112`; `NextPage` reemplaza `pages[next]` por `branchPuzzle` + `altStory/Title` ES/EN.

**Puzzle (legado):** `PuzzleBloc` con `GetPuzzle/GetAllPuzzles` existe pero el flujo principal usa `BookBloc` directo.

---

## 8. Persistencia y progreso

**`BookProgressRepository`** (`book_progress_repository.dart:6`) singleton `await progressRepo.init()` en `injection_container.dart:50`.

| Clave `SharedPreferences` | Tipo | Contenido |
|---|---|---|
| `progress_solved_<bookId>` | `List<String>` | IDs resueltos por libro |
| `progress_picarats_<bookId>` | `int` | XP por libro (legacy `picarats`) |
| `progress_picarats_secrets` | `int` | XP secretos/deducciones |
| `progress_last_book/_page` | `String/int` | Última posición |
| `collectibles` | `List<String>` | `nebelheim-1`…`abbey-15` (90) |
| `secrets_solved` | `List<String>` | `101`…`118` (18) |
| `branchChoices` | `List<String>` | `pageId=main\|alt` |
| `timePerPuzzle` | `List<String>` | `puzzleId=seconds` |
| `stats_attempts/success/hints` | `List<String>` | **D1** telemetría por puzzle |
| `stats_sessions` | `int` | **D1** sesiones |
| `app_locale` (`LocaleService`) | `String` | `es`/`en` |
| `a11y_high_contrast/font_scale` | `bool/double` | Accesibilidad |
| `daily_*` (`DailyPuzzleRepository`) | — | `daily_puzzle_date`, `streak` |

**API:**
- `init()` carga todo a memoria.
- Lecturas: `solvedFor`, `experienciaFor`, `totalexperiencia()`, `isBookCompleted`, `solvedCount`, `hasSave`, `collectibles/secrets/allSolvedIds/rewardsUnlocked/isHolmesRank(>=1500)`, `branchChoices/timePerPuzzle` + **D1** `attemptsPerPuzzle/successPerPuzzle/hintsPerPuzzle/totalSessions/totalAttempts/successRate/avgTimePerPuzzle/totalTimeSeconds/avgHintsPerPuzzle/mostPlayedBookId/totalSolvedPuzzles`.
- Escrituras: `markSolved(bookId,puzzleId,experiencia,collectibleId)`, `markSecretSolved`, `recordBranch`, `recordTime`, **D1** `recordAttempt(puzzleId,success,hintsUsed,seconds)` + `incrementSessions()`, `saveLastPosition`, `resetBook`, `resetAll`.

**`DailyPuzzleRepository`:** `getDailyPuzzle()`, `getStreak()`.

---

## 9. Navegación y páginas

### `SplashPage` (`splash_page.dart:1`)
`assets/Splash_Watson.jpg` full-screen con `errorBuilder`, **3,5 s** + `FadeTransition` a `LibraryPage`. Dispara `LibraryBloc LoadLibraryEvent` en `main.dart:32`.

### `LibraryPage` (`library_page.dart:23`)
- **AppBar:** título/subtítulo localizados, `settings` (alto contraste/fuente/compartir/export/daily link), `map` → `MapPage`, `collections` → `_showGallery`, **`bar_chart` → `StatsPage` (D1)**, idioma `Popup ES/EN`, `more_vert` → Nueva partida con confirmación, chip `⭐ total · rango` (`<300 Aprendiz, <800 Investigador, <1500 Watson, 1500+ Holmes`).
- **Body:** `DailyBanner` + `_continueCard` si `hasSave` (botón ámbar con `book.title` y `page X/Y`) + `Responsive` (1 col móvil `ListView`, 2–3 cols tablet `GridView`) con `_bookCard:494` (lomo 96 px `coverColor`, chip `ETAPA`, icono, `pages`, título/subtítulo/descripción, estrellas 1–3 por `progress/xpRate`, `LinearProgress`, `solved/pageCount`, lock/arrow, borde dorado Holmes o verde completado).
- **Galería** (`_showGallery:110`): dialog con recompensas 6 (3 cols), secretos 18 (6 cols), coleccionables 90 (6 cols), marco dorado si `isHolmesRank`.

### `BookReaderPage` (`book_reader_page.dart:19`)

**State:** `PageController(viewportFraction:0.96)`, `_syncing`, `_isReading/_isPaused`, `_mirror`, `_isTimed/_secondsLeft`, `_textScale 1.0→1.3→1.6`, `TtsService _tts`, **C3** `_highlightStart/_highlightEnd/_currentSentence/_ttsFullText` + `StreamSubscription` a `progress/sentenceIndex`.

- **Lifecycle:** `initState` → `AudioService.playForBook`; `dispose` → `stop TTS + audio`; `_ttsService()` con `onComplete` resetea flags y `duck(false)`.
- **Audiolibro C3:** `_toggleReading` concatena `storyTitle. storyText Acertijo página N: puzzle.title. statement` → `duck(true)` + `speakWithHighlight(pausePerSentence:true, 650ms)`. Pausa/reanuda con `pause()/resume()`, stop global. Resaltado: `_buildHighlightedTitle/_buildHighlightedStory/_buildSentenceHighlightedRichText` (oración ámbar `amber.shade200`, palabra `brown.shade700+amber` bold) + `_buildNarrationBar` (`🔊 3/7 + LinearProgress + "Palabra: reloj" + nota pausa 0,65 s`). Si `progressHandler` no existe, solo resalta oración.
- **Navegación:** `PageView.builder` libre (`onPageChanged → GoToPageEvent`), `AnimatedBuilder` escala 0.94–1.0, `_syncing` evita loop. `_progressHeader:669` (page X/Y, chip ⭐, `LinearProgress`, `+XP`), `_bottomBar:947` (Inicio/Atrás/X/Y/Siguiente-Saltar-Ver final), `first_page/flip/format_size/volume_up+stop_circle/menu_book` en AppBar.
- **Índice** (`_showIndex:384`): bottomSheet grid 6 cols verde/ámbar/blanco.
- **Resumen final** (`_summaryContent:162`): `DraggableScrollableSheet` con `assets/rewards/<bookId>.png`, 4 finales por `endingTier` (perfect/good/half/low), chip recompensa si `perfect`, `⭐ xp/max`, botones Biblioteca/Deducción final/Inicio/Releer/Pendientes/Nuevo.
- **Deducción 113–118:** mapa `nebelheim→113…abbey→118`, `getPuzzle` + `PuzzleCard` dialog + `markSecretSolved`.
- **Celebración** (`Stack:647`): `SolvedCelebration` 3,2 s si `lastAnswerCorrect && isCurrentSolved` → `ClearPageResultEvent`; `BlocListener` vibración.

### `StatsPage` (D1) (`stats_page.dart:7`)
AppBar `Estadísticas/Statistics` + share. Scroll con: resumen global (chip ⭐+rango, grid 6 tiles: resueltos, tasa %, tiempo medio/total, pistas medias, sesiones), `mostPlayed` card, desglose por libro (6 cards con `colorValue`, solved/XP, tasa, `LinearProgress`, tiempo medio), colección `90/18/6` y telemetría (`totalAttempts, successes, branches, hints`). Datos 100% locales.

### `MapPage`
Mapa Nebelheim con `onSelect(alley)`, desde Library.

---

## 10. Widgets

- **`PuzzleCard`** (`puzzle_card.dart:7`): `puzzle/isSolved/lastAnswerCorrect/failedAttempts/onSubmit(answer,hintsUsed)/textScale`. Controla `TextEditingController`, `_selectedOption`, `_hintLevel`. Build: contenedor `#FFFF3CD`, header marrón+ámbar, `statement`, `VisualPuzzleWidget`, banner `¡Atrévete! +XP`, `¡Resuelto!` o `ChoiceChip`/`TextField` + Responder, pista `Watson susurra` + `Pista 1/3 (-5)` / `2/3 (-10) — siguiente fallo cambia historia`, feedback rojo/verde.
- **`VisualPuzzleWidget`** (`visual_puzzle_widget.dart:13`): `shapes_sequence`, `odd_one_out`, `chests`, `matchsticks`, `coin_triangle`, `balance`, `grid_squares`, `dials` (placeholders `drag_order/slider/ dial_interactive` para A4).
- **`SolvedCelebration`** (`solved_celebration.dart:1`): overlay 3,2 s, ✔ elástico, estrellas, `+XP`, SFX+vibración, tap para saltar.
- **`DailyBanner`** (`daily_banner.dart:1`): reto diario + racha `🔥`.

---

## 11. Servicios transversales

- **`TtsService` C3** (`tts_service.dart:16`): `FlutterTts`, `TtsProgress(text,start,end,word)`, `Stream<TtsProgress> progress` / `sentenceIndex`, `setProgressHandler`, split `[^.!?]+[.!?]+`, `speakWithHighlight(pausePerSentence, 650ms)` con `Completer` por oración, `pause/resume/stop`, `isPaused`, catch-all para no romper app.
- **`AudioService`** (`audio_service.dart:1`): `AudioPlayer` loop, vol 0.30 → duck 0.08 en TTS, `playForBook` mapea `nebelheim/lighthouse/carnival/observatory/train/abbey → audio/*.wav`, `stop/duck`.
- **`FeedbackService`:** vibración corta fallo / larga acierto + SFX.
- **`AccessibilityService`:** `ValueNotifier<bool> highContrast` (negro `#000` vs `#2C1A0E`), `fontScale 1.0→1.3→1.6` vía `MediaQuery.textScaler` (`main.dart:51`), `toggleHighContrast/cycleFontScale`, `SharedPreferences`.
- **`LocaleService`:** `ValueNotifier<Locale>` ES/EN, `setLocale`, notifica `MaterialApp.locale`.
- **`SyncService`:** `generatePostalText` (rank/total/collectibles/secrets/rewards/streak/#ElementalWatson), `sharePostal`, `exportElemental()` → `temp/elemental_YYYY-MM-DD.elemental.json` + `_export_version`, `shareExport` → `shareXFiles`, `copyDailyLink` → `Clipboard elemental://daily/YYYY-MM-DD`.
- **`DailyPuzzleRepository`:** `getDailyPuzzle`, `getStreak`.

---

## 12. Internacionalización

- `main.dart:37`: `supportedLocales [es,en]`, `AppLocalizationsDelegate` + `GlobalMaterial/Widgets/Cupertino`, `locale = LocaleService.value`.
- `app_localizations.dart:10`: mapa ES/EN ~70 claves (`appTitle`, `continueGame`, `newGame`, `stage/lockedStage`, `rank*`, `pageOf/gainXpIfSolve`, `dareAndGain`, `hint/correctXp`, `skipConfirm*`, `xpScore`, `statistics/globalSummary/successRate…` etc.) con `_t(key,params)` y `tr/goToStart…`.
- `book_en.dart:1` + `book_local_data_source.dart:94` `_enPageMap`: EN para 50 págs de libros 2–6 + `f05En` etc. También EN para puzzles inline.
- Cambiador `LibraryPage` Popup: `setLocale` + `LoadLibraryEvent`.
- TTS idioma sigue `LocaleService` (`es-ES` / `en-US`, `speechRate 0.46`).

---

## 13. Assets, marca y audio

- **Nombre:** *Elemental, querido Watson* / *Elementary, my dear Watson*.
- **Icono:** `assets/Icono_Watson.jpg` → launcher (`pubspec.yaml:61`).
- **Splash:** `assets/Splash_Watson.jpg` 3,5 s `SplashPage`.
- **Recompensas:** 6 `assets/rewards/*.png` en `_bookCard`, galería y resumen (solo si `perfect`).
- **Coleccionables:** 90 `assets/rewards/collectibles/<book>-<n>.png` al resolver página.
- **Secretos:** 18 `assets/rewards/secrets/101..118.png` (101-112 ramas, 113-118 deducciones) en galería.
- **Audio:** 6 loops `assets/audio/*.wav` con duck 0.08 en TTS, control `BookReaderPage initState/dispose`.

---

## 14. Gamificación y progresión

- **XP:** `experiencia` 10–60, `awarded = (exp - hints*5).clamp(1,999)` ×1.3 si timed. Persiste por libro y global (`StoryBook.totalexperiencia`, `BookProgressRepository`).
- **Rangos** (`library_page:348` / `sync_service:19`): `<300 Aprendiz`, `<800 Investigador`, `<1500 Watson`, `1500+ Holmes` (marco dorado 3.5 + sombra).
- **Estrellas 1–3** (`library_page:602`): `progress>=1 →3`, `xpRate>=0.7||progress>=0.7 →2`, `>0 →1`.
- **Coleccionables 90**, **Secretos 18** (101-112 ramas + 113-118 deducciones), **Recompensas 6** (`rewardsUnlocked`).
- **Finales** (`book_state:82` + `book_reader_page:162`): `completionRate=total/max` → `perfect` (100%), `good >=70%`, `half >=40%`, `low`; citas distintas + chip recompensa si `perfect`; epílogo si 6/6 100%.
- **Branching:** 2 fallos → `Pista 2/3` + `branchedPuzzleIds` → `NextPage` inyecta `branchPuzzle 101-112` + `altStory/Title` ES/EN (`_branchStoryFor/_branchTitleFor`).
- **Estadísticas D1:** tiempo medio/total, tasa acierto `successRate`, `mostPlayedBookId`, sesiones, colección, racha (`StatsPage`).

---

## 15. Accesibilidad y responsive

- **Audiolibro:** 🔊 en `BookReaderPage`, lee título+historia+acertijo, pausable, stop al cambiar página/salir, TTS tolerante a fallo.
- **Fuente:** 🔠 alterna `1.0→1.3→1.6` (`_cycleTextScale` + `AccessibilityService` global vía `MediaQuery.textScaler`).
- **Contraste:** `SwitchListTile` en ajustes (`LibraryPage:251`) → scaffold negro.
- **Tooltips** en todos los `IconButton` para screen readers.
- **Responsive** (`responsive.dart:1`): `isPhone`, `libraryCrossAxisCount`, `pagePadding`, `bookSheetMaxWidth`, `ResponsiveCenter`. Lista vs grid, hoja ancho máx centrada.

---

## 16. Roadmap — estado final

Orden original **A > C > B > D > E**, 3 fases. Estado a 2026-09-23:

### FASE 1: Jugabilidad Core

**A1. Pistas progresivas (3 niv., -5 XP)** — ✅ Terminado
`Puzzle.hints` 3 por puzzle, `PuzzleCard _hintLevel`, `book_bloc penalty`.

**A2. Dificultad adaptativa + contrarreloj** — 🟡 Parcial
`difficulty` OK, bonus +30% OK (`_isTimed` + `timedBonus`). Pendiente reordenar páginas Easy→Hard.

**A3. Vidas 3 intentos + segunda oportunidad** — ✅ Terminado
`isBlockedByAttempts >=3`, `recordAttempt` + `recordBranch` al 2º fallo → siguiente página ramificada 101-112 (evolución de “pista forzada/-50%”).

**A4. Tipos interactivos nuevos** — 🟡 Parcial
`visual_puzzle_widget` base operativa + placeholders `drag_order/slider/dial_interactive`. Pool 10 conversiones pendiente.

### FASE 1b: Narrativa e Inmersión

**C1. SFX + hápticos + música** — ✅ Terminado
`audioplayers ^6.7.1` + `AudioService` 6 loops + duck, `SolvedCelebration` 3,2 s + `FeedbackService` vibración.

**C2. Finales ramificados por XP** — ✅ Terminado
4 finales por `endingTier` + epílogo 6/6 100%.

**C3. Narración mejorada** — ✅ Terminado (2026-09-23)
`TtsService` split oraciones + `progressHandler` palabra, `pausePerSentence 650ms` con `Completer`, `pause/resume/stop`; `BookReaderPage` resaltado oración ámbar + palabra marrón + barra `🔊 3/7 + palabra`.

### FASE 2: Progresión y Metajuego

**B1. Rango Detective + Logros** — ✅ Terminado
Rangos 4 niveles + chip, `rewardsUnlocked` + `secrets` como logros.

**B2. Estrellas 1-3** — ✅ Terminado
`Row 3 estrellas` por progreso/XP + borde dorado.

**B3. Puzzle Diario + racha** — ✅ Base
`DailyPuzzleRepository` + `DailyBanner` + `SyncService` postal; notificación 19:00 pendiente (`flutter_local_notifications`).

### FASE 3: D (UX/Store) y E (Técnico)

**D1. Estadísticas + telemetría** — ✅ Terminado (2026-09-23)
`BookProgressRepository` telemetría (`attempts/success/hints/sessions`), `recordAttempt` en `BookBloc`, `LibraryBloc incrementSessions`, `StatsPage` completa + acceso `bar_chart`, +11 claves l10n.

**D2. i18n + ASO** — ✅ Terminado (2026-09-23)
`l10n` ES/EN completo (+stats), `store_listing/` con `play_store/es|en/{title,short,full,keywords}`, `screenshots/spec.md` (8 capturas 1080×1920 + Feature Graphic 1024×500 + storyboard video 30 s 1920×1080), `store_listing/README.md`. Solo faltan PNGs/MP4 reales.

**D3. Google Play Games** — ⏳ Pendiente
`games_services` leaderboard/achievements/cloud save.

**E1. Analytics/CI/Monetización** — ⏳ Pendiente
`firebase_analytics`/`crashlytics`, GitHub Actions `flutter analyze && flutter test` en `develop`, IAP pistas/desbloqueo libro 6.

**Workflow `develop`:**
```bash
git checkout develop && git pull origin develop
git checkout -b feat/A1-pistas-progresivas
# ... commit ...
git push -u origin feat/A1-pistas-progresivas # → PR a develop
# develop → main tras QA + tag 1.1.0
```
Convención `feat(puzzle): …`, `feat(audio): …`. Próximo: cerrar A2 reordenamiento.

---

## 17. Estructura de carpetas

```
elemental_app/
├── .github/modernize/
├── android/ ios/ web/ windows/
├── assets/
│   ├── Icono_Watson.jpg
│   ├── Splash_Watson.jpg
│   ├── audio/*.wav (6)
│   └── rewards/*.png + collectibles/*.png (90) + secrets/*.png (18)
├── lib/
│   ├── main.dart
│   ├── injection_container.dart
│   ├── core/
│   │   ├── error/failures.dart
│   │   ├── usecases/usecase.dart
│   │   ├── l10n/app_localizations.dart + book_en.dart
│   │   ├── services/ tts_service.dart(C3) + audio_service.dart + feedback_service.dart + locale_service.dart + sync_service.dart + accessibility_service.dart
│   │   └── widgets/responsive.dart
│   └── features/
│       ├── book/
│       │   ├── data/datasources/book_local_data_source.dart + books/*.dart
│       │   ├── data/repositories/book_progress_repository.dart(D1) + daily_puzzle_repository.dart
│       │   ├── data/services/tts_service.dart
│       │   ├── domain/entities/story_book.dart + book_page.dart
│       │   └── presentation/bloc/{book,library}_* + pages/{splash,library,book_reader,map,stats}_page.dart + widgets/{puzzle_card,visual_puzzle_widget,solved_celebration,daily_banner}.dart
│       └── puzzle/
│           ├── data/datasources/puzzle_local_data_source.dart + models/puzzle_model.dart + repositories/puzzle_repository_impl.dart
│           ├── domain/entities/puzzle.dart + repositories/puzzle_repository.dart + usecases/*.dart
│           └── presentation/bloc/puzzle_*.dart
├── store_listing/            # D2 ASO
│   ├── play_store/es|en/{title,short_description,full_description,keywords}.txt
│   ├── screenshots/spec.md
│   └── README.md
├── test/widget_test.dart
├── analysis_options.yaml
├── pubspec.yaml
├── DOCUMENTACION.md          # ← este archivo
└── windows/flutter/generated_*
```

---

## 18. Desarrollo y convenciones

```bash
flutter pub get
flutter analyze        # 0 errores (2026-09-23)
flutter test           # 4/4: splash 3.5s, biblioteca 6 libros, guardado, accesibilidad
dart run flutter_launcher_icons
```

- **Ramas:** `main` (single source) → `develop` → `feat/<codigo>` → PR a `develop` → `develop→main` tras QA + tag `1.1.0`.
- **Convención commits:** `feat(puzzle): pistas progresivas`, `feat(audio): SFX victoria`, `fix(book): …`.
- **Datasources:** delay 300 ms salvo en tests (`_isTest`); en tests avanzar reloj por pasos `pump(300ms)`.
- **Tests BLoC:** no `bloc.close()` (bloc 9 + fakeAsync cuelga); lo gestiona `BlocProvider`.
- **Ruido git:** `windows/flutter/generated_*` puede aparecer modificado por CRLF — ignorar.

---

## 19. Decisiones de diseño

- **Navegación libre vs candado:** `isPageUnlocked=>true`; el incentivo es XP, no bloqueo. Vidas solo fuerzan pista/branching.
- **XP como `picarats` legacy:** claves `progress_picarats_*` mantienen compatibilidad con prototipo Layton-like.
- **Branching real vs modal:** se implementó sustitución de siguiente página 101-112 + narrativa alternativa en lugar de “pista forzada/-50%”, más inmersivo y testeable.
- **i18n incremental:** `_enPageMap` inline evita `arb` pesado; puzzles `F05/C05…` con objetos `f05En`.
- **Audio ducking:** `duck(true)` antes de TTS, `duck(false)` al completar.
- **Coleccionables vs secretos:** 90 ligados a página, 18 (12 ramas + 6 deducciones) con imágenes propias; `allSolvedIds` unifica conteo.
- **Export `.elemental`:** vuelca literal `SharedPreferences` a JSON temporal + `_export_version:1`, comparte vía `share_plus`.
- **TTS C3 fallback:** si `setProgressHandler` no soportado, sigue pausa por frase + resaltado de oración.

---

## 20. Trabajo restante

- **A2 resto:** reordenar páginas por dificultad Easy→Hard.
- **A4:** `drag_order`/`slider_number`/`dial_interactive` completos.
- **B3:** `flutter_local_notifications` 19:00 + XP diario al rango.
- **D2 resto:** generar PNGs 1080×1920 + Feature Graphic 1024×500 + MP4 30 s según `store_listing/screenshots/spec.md`.
- **D3:** `games_services` leaderboard/achievements/cloud save.
- **E1:** `firebase_analytics`/`crashlytics`, GitHub Actions CI, IAP pistas/desbloqueo libro 6.

> Cualquier cambio futuro debe actualizar **este** `DOCUMENTACION.md`. No crear archivos paralelos.

