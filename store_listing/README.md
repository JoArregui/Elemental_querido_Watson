# Store Listing — Elemental, querido Watson (D2)

Este directorio contiene los entregables ASO para Play Store / App Store ya listos (D2 completado a nivel documentación y spec; solo falta capturar PNGs y renderizar MP4).

## Estructura
```
store_listing/
├── play_store/es/           # ES — listo para Google Play Console
│   ├── title.txt (50c)
│   ├── short_description.txt (80c)
│   ├── full_description.txt (4000c)
│   └── keywords.txt
├── play_store/en/           # EN
│   ├── title.txt
│   ├── short_description.txt
│   ├── full_description.txt
│   └── keywords.txt
└── screenshots/spec.md      # Spec 8+1 screenshots + video 30s
```

## Uso
1. Google Play Console → Ficha → copiar/pegar `title`, `short`, `full`.
2. Generar capturas siguiendo `screenshots/spec.md` (1080×1920 + 1024×500 Feature Graphic desde `assets/Splash_Watson.jpg`).
3. Subir video 30 s a YouTube no listado y enlazar en ficha.
4. Categoría: **Puzzle > Aventura narrativa** (EN: Puzzle > Adventure/Narrative).
5. Icono: `assets/Icono_Watson.jpg` 512×512 + fondo #1A1009.

## i18n (D2)
- App soporta ES/EN completo (`core/l10n/app_localizations.dart`, `book_en.dart`, `book_local_data_source _enPageMap`, `tts_service` es-ES/en-US).
- Cambiador en Library AppBar (`LocaleService` + `SharedPreferences`).
- Capturas y ficha duplicadas ES/EN.

## Estado
- ✅ Textos store ES/EN
- ✅ Keywords y tags
- ✅ Screenshot spec (8 vistas clave)
- ✅ Video storyboard 30s
- ✅ Categoría y feature graphic
- ⏳ Capturas PNG y MP4 finales (requiere device real)
