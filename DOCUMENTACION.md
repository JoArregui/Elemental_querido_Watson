# Elemental, querido Watson — Documentación del proyecto

Biblioteca de casos de **Sherlock Holmes y el Dr. Watson**: seis libros-etapa
interactivos donde cada página cuenta un fragmento de la historia y termina
con un acertijo. Resolverlo desbloquea la página siguiente.

> Personajes de dominio público (Arthur Conan Doyle). Proyecto sin material
> con derechos de terceros.

---

## 1. Características

| Área | Descripción |
|---|---|
| Biblioteca | Home con 6 libros-etapa, cada uno con portada, progreso y bloqueo por etapas |
| Lectura | `PageView` con efecto libro, historia + 1 acertijo por página |
| Celebración | Animación de ~3,2 s al resolver cada página (✔ elástico, estrellas, experiencia; se salta tocando) |
| Acertijos | 90 distintos (texto, opción múltiple y visuales dibujados con widgets) |
| Guardado | Partida persistente: progreso, experiencia y última posición |
| Continuar | Botón para retomar donde se dejó; *Nueva partida* con confirmación |
| Audiolibro | Lectura en voz alta en español (icono 🔊) + tamaño de letra ajustable |
| Splash | Imagen de presentación durante 3,5 s con fundido a la biblioteca |
| Icono | Generado desde `assets/Icono_Watson.jpg` (Android + iOS) |

---

## 2. Los seis libros

| Etapa | Libro | Páginas | Ambientación |
|---|---|---|---|
| 1 | El Reloj Detenido de Nebelheim | 30 | Villa con la torre parada a las 10:10 |
| 2 | El Faro de las Mareas Perdidas | 10 | Pueblo pesquero y contrabando |
| 3 | El Carnaval de las Máscaras | 10 | Robo en pleno carnaval |
| 4 | La Estrella del Observatorio | 10 | La noche del cometa Azul |
| 5 | El Misterio del Expreso de Medianoche | 15 | Desaparición en un tren nocturno |
| 6 | La Abadía de los Susurros | 15 | Relicario robado entre monjes |

**Regla de desbloqueo:** la etapa 1 siempre está abierta; cada etapa exige
completar la anterior. Dentro de un libro, cada página exige resolver el
acertijo de la anterior.

---

## 3. Acertijos

- **Texto libre** (`PuzzleType.textInput`): la respuesta se normaliza
  (minúsculas, sin espacios extra) antes de comparar.
- **Opción múltiple** (`multipleChoice`) y **visual con opciones**
  (`visualChoice`): se responden con `ChoiceChip`.
- **Visuales** (`visualKind`, en `visual_puzzle_widget.dart`, sin assets):
  `shapes_sequence`, `odd_one_out`, `chests`, `matchsticks`,
  `coin_triangle`, `balance`, `grid_squares` (2×2, 3×3 y 4×4) y `dials`.
  Varios aceptan `visualPayload` para variar el contenido
  (p. ej. `★,●,★,●,★,?` o `2×5kg + 2×1kg|? × 3kg`).
- La moneda del juego son los **experiencia** ⭐ (cada acertijo indica su valor).
- Los libros 2–6 reutilizan acertijos clásicos por `id` desde
  `puzzle_local_data_source.dart` (100 disponibles); ningún `id` se repite
  entre libros (verificado por test).

---

## 4. Arquitectura

Clean Architecture por *features* (`book`, `puzzle`) + BLoC + GetIt:

```text
lib/
├── main.dart                      # App + SplashPage inicial
├── injection_container.dart       # GetIt: blocs, repos, datasources, TTS
├── core/                          # failures, usecase base
└── features/
    ├── book/
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── book_local_data_source.dart   # Biblioteca (libro 1 + composición)
    │   │   │   └── books/                        # Libros 2-6 (historia + puzles)
    │   │   ├── repositories/
    │   │   │   └── book_progress_repository.dart # Guardado persistente
    │   │   └── services/tts_service.dart         # Voz en español (flutter_tts)
    │   ├── domain/entities/       # StoryBook, BookPage
    │   └── presentation/
    │       ├── bloc/              # book_* (lector) y library_* (biblioteca)
    │       ├── pages/             # splash, library, book_reader
    │       └── widgets/           # puzzle_card, visual_puzzle_widget
    └── puzzle/                    # Entidad Puzzle, 100 clásicos, PuzzleBloc
```

### Flujos principales

- **Biblioteca** (`LibraryBloc`): carga los libros, calcula progreso por libro
  (resueltos, completados, experiencia) y expone `resumeBook` para continuar.
- **Lector** (`BookBloc` por libro): navegación entre páginas, envío de
  respuestas y guardado automático de la última posición.
- **Progreso** (`BookProgressRepository` + `shared_preferences`):
  - `progress_solved_<bookId>` → lista de acertijos resueltos
  - `progress_picarats_<bookId>` → experiencia por libro (clave histórica)
  - `progress_last_book` / `progress_last_page` → dónde continuar

---

## 5. Accesibilidad

- **Audiolibro**: icono 🔊 en el lector; lee título, historia y acertijo de
  la página (`es-ES`, ritmo pausado). Se detiene al cambiar de página, al
  salir o con el icono ⏹. Si el dispositivo no tiene motor de voz, la app
  sigue funcionando (los errores de TTS se absorben).
- **Tamaño de letra**: icono 🔠 que alterna normal → grande → extragrande.
- Botones con `tooltip` para lectores de pantalla del sistema.

---

## 6. Marca y assets

- Nombre de app: **Elemental, querido Watson** · paquete
  `elemental_querido_watson` (`com.example.elemental_querido_watson`).
- `assets/Icono_Watson.jpg` → icono (config en `pubspec.yaml`,
  regenerar con `dart run flutter_launcher_icons`).
- `assets/Splash_Watson.jpg` → splash de 3,5 s (`splash_page.dart`):
  imagen completa sin recortes sobre fondo difuminado; con `errorBuilder`
  de respaldo.

---

## 7. Desarrollo

```bash
flutter pub get        # dependencias
flutter analyze        # lints (solo 2 infos preexistentes)
flutter test           # 4 tests: splash, biblioteca, guardado, accesibilidad
```

- Rama única: **`main`** (remoto `origin/main`).
- Reglas útiles: los `Future.delayed` de los datasources simulan carga;
  en tests, avanzar el reloj **por pasos** (`pump(300ms)` en bucle).
- No llamar a `bloc.close()` en tests (bloc 9 + fake async se cuelga);
  en producción el `BlocProvider` lo gestiona solo.
- Ficheros autogenerados (`windows/flutter/generated_*`) pueden aparecer
  como modificados por finales de línea: es ruido, sin cambios reales.
