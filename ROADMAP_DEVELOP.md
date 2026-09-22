# Roadmap `develop` — Elemental, querido Watson

> Rama `develop` creada desde `main` el 2026-09-22. Este roadmap ordena el backlog según tu preferencia: **A > C > B > D > E**.

## Orden de implementación acordado
1.  **FASE 1 - Jugabilidad Core (A)** - impacto inmediato en retención
2.  **FASE 1b - Narrativa e Inmersión (C)** - eleva de puzzle genérico a aventura narrativa
3.  **FASE 2 - Progresión y Metajuego (B)** - piloto tras validar A+C
4.  **FASE 3 - D (UX/Store) y E (Técnico/Monetización)** - al final, cuando el core esté sólido

---

### FASE 1: Jugabilidad Core — prioritaria

#### A1. Pistas progresivas (3 niveles) con coste XP
- **Archivos:** `lib/features/puzzle/domain/entities/puzzle.dart:9` añadir `List<String> hints` (hintText -> hints[0] compat), `lib/features/puzzle/data/models/puzzle_model.dart:10`, `lib/features/puzzle/data/datasources/puzzle_local_data_source.dart:8` poblar 3 hints por puzzle (ej. 001: nivel1 "intervalos", nivel2 "6 campanadas = 5 huecos", nivel3 "11s").
- **Lógica:** `lib/features/book/presentation/widgets/puzzle_card.dart:228` `TextButton Pista` -> contador `hintLevel 0..3`, cada uso descuenta 5 XP del `experiencia` final si se acierta después. Persistir `hintsUsed` en `book_progress_repository.dart:65`.
- **Criterio done:** sin pistas = XP completo, con 3 pistas = -15 XP, test en `test/widget_test.dart`.

#### A2. Dificultad adaptativa + modo contrarreloj opcional
- Etiquetar cada `PuzzleModel` con `difficulty` derivado de `experiencia` (10-20 Easy, 25-35 Med, 40+ Hard) + reordenar páginas dentro de libro: Easy primero, Hard al final para curva.
- Switch "Contrarreloj ⏱️ 60s" en `book_reader_page.dart:377` AppBar, bonus +20% XP si resuelve <30s, `failedAttemptsOnPage` ya existe `lib/features/book/presentation/bloc/book_state.dart:26`.
- **Paquete:** ninguno, `Timer.periodic`.

#### A3. Vidas / 3 intentos + segunda oportunidad
- Bloquear `onSubmit` en `puzzle_card.dart:210` tras `failedAttemptsOnPage >=3`, mostrar modal: "Usar pista forzada (-5 XP) o saltar con -50% XP".
- Modificar `book_progress_repository.dart:65` `markSolved` para aceptar `xpAwarded = puzzle.experiencia * factor`.

#### A4. Nuevos tipos interactivos
- Extender `visual_puzzle_widget.dart:13` : `drag_order`, `slider_number`, `dial_interactive` (rotar con GestureDetector, ya existe `_dials` placeholder).
- **Pool:** convertir 10 puzzles de texto a nuevo tipo (ej. 062 cubo pintado -> slider 0-20, 099 faro -> dial MCM).

### FASE 1b: Narrativa e Inmersión — en paralelo a A

#### C1. Audio SFX + hápticos + música ambiente
- **Paquetes:** `audioplayers: ^6.x`, `vibration: ^2.x`
- `lib/features/book/presentation/widgets/solved_celebration.dart:1` + sonido victoria 3.2s, `puzzle_card.dart:272` vibración corta en fallo, largo en acierto.
- Música loop de fondo por libro (lighthouse = olas, abbey = coro) con `audioplayers` en `book_reader_page.dart:30` `initState`, volumen 0.3 y duck al TTS.

#### C2. Finales ramificados por XP
- `lib/features/book/presentation/pages/book_reader_page.dart:147` `_summaryContent` ya distingue `isPerfect` vs parcial. Ampliar a 3 finales: `<60%` "Watson decepcionado", `60-99%` "Caso resuelto", `100%` "Holmes: Elemental". Texto en `story_book.dart` + `abbey_book.dart` etc.
- Desbloquea epílogo secreto si 6/6 libros al 100%.

#### C3. Narración mejorada
- `tts_service.dart` ya existe: añadir resaltado de palabra leída (stream de `flutter_tts` progress) + pausa por frase.

### FASE 2: Progresión y Metajuego — piloto (feature-flag)

#### B1. Rango Detective + Logros
- `library_state.dart:23` `totalexperiencia` -> `Rank {Aprendiz <300, Investigador <800, Watson <1500, Holmes 1500+}` mostrar en `library_page.dart:141` chip.
- `lib/features/book/data/repositories/book_progress_repository.dart` añadir `unlockedAchievements: Set<String>` (ej. "Primer libro perfecto", "10 sin pistas").

#### B2. Estrellas 1-3 por libro
- `library_page.dart:364` `LinearProgressIndicator` -> `Row` 3 estrellas: 1 si `solvedCount>0`, 2 si `>=70% XP`, 3 si `100%`. Animación al desbloquear.

#### B3. Puzzle Diario + racha
- Nuevo `DailyPuzzleRepository` con `shared_preferences` key `daily_puzzle_date`, `streak`. Notificación `flutter_local_notifications` 19:00 "Caso diario listo".
- Desacoplado del progreso libros, XP diario cuenta para rango global.

> Flag `enableMetagame` en `injection_container.dart` para poder probar B sin afectar FASE 1.

### FASE 3: D (UX/Store) y E (Técnico) — al final

#### D1. Estadísticas + telemetría UX
- Pantalla perfil: tiempo medio por puzzle, tasa acierto, libro más jugado. Datos de `book_bloc.dart:80` `SubmitPageAnswerEvent`.

#### D2. Internacionalización + ASO
- `l10n` EN/ES, fichas Play Store: categoría `Puzzle > Aventura narrativa`, screenshots libro abierto + video 30s.

#### D3. Google Play Games
- `games_services` leaderboard XP + achievements, cloud save wrap de `book_progress_repository.dart:19` `init()`.

#### E1. Analytics + CI + Monetización
- `firebase_analytics` funnel `puzzle_view -> attempt -> solved/skipped/hint`, `firebase_crashlytics`.
- GitHub Actions `flutter analyze && flutter test` en push a `develop`.
- IAP: pista extra / desbloqueo anticipado libro 6 (solo después de FASE 1 estable, no antes).

---

## Cómo trabajamos en `develop`
```bash
git checkout develop
git pull origin develop        # integración
git checkout -b feat/A1-pistas-progresivas
# ... commit ...
git push -u origin feat/A1-pistas-progresivas -> PR a develop
# develop -> main solo tras QA + tag 1.1.0
```
- Cada tarjeta A1..E1 = branch `feat/<codigo>` desde `develop`.
- Commits con conventional: `feat(puzzle): pistas progresivas`, `feat(audio): SFX victoria`.

## Próximo paso propuesto
Empezar por **A1 (pistas) + C1 (SFX/hápticos)** en paralelo — son independientes, bajo riesgo y validan el loop.
¿Arranco con `feat/A1-pistas-progresivas` (modifico `puzzle.dart:9` + `puzzle_card.dart:228`)?
