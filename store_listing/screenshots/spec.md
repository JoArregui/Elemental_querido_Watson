# Elemental — Screenshots & Video Spec (D2 ASO)

## Formato
- **Teléfono**: 1080×1920 (9:16) mínimo 2, máximo 8
- **Tablet 7" y 10"**: 1200×1920 / 1920×1200
- **Icono**: 512×512 PNG-32 (Icono_Watson.jpg sin alpha, fondo #1A1009)
- **Feature Graphic**: 1024×500 (Watson + título + “6 libros · 90 acertijos”)

## 8 Screenshots obligatorios (orden Play Store)

1. **Biblioteca** — 6 portadas, chips ETAPA, estrellas 1-3, barra XP y chip “⭐ 420 · Investigador”. Mostrar “Continuar partida” arriba. Texto overlay: “6 casos · Cada libro es una etapa”.
2. **Hoja abierta** — Libro abierto #FFFFFBEB con lomo marrón, título serifa, historia justificada y tarjeta acertijo al pie. Overlay: “Lee · Resuelve · Gana XP”.
3. **Acertijo visual** — Mosaico 3×3 / balanza / cofres con ChoiceChip. Overlay: “100+ acertijos: texto, opción múltiple y visuales”.
4. **Pistas progresivas** — Tarjeta con “Watson susurra: pista 1/3 (-5 XP)”. Overlay: “3 pistas por acertijo”.
5. **Audiolibro C3** — Página con frase resaltada ámbar + palabra en marrón + barra “🔊 Leyendo 3/7 · Pausa automática 0,65 s · palabra: ‘reloj’”. Overlay: “Audiolibro con resaltado y pausa por frase”.
6. **Final ramificado** — Resumen con “¡Caso resuelto!” vs “¡Fin del libro perfecto!”, imagen recompensa y “⭐ 210/310”. Overlay: “4 finales según tu XP · 12 ramas secretas”.
7. **Estadísticas D1** — Pantalla Stats con “Tiempo medio 18s · Tasa 72% · Más jugado: Nebelheim” + gráfico por libro. Overlay: “Estadísticas y telemetría local”.
8. **Colección** — Grilla 6×6 coleccionables + 18 secretos + 6 recompensas con marco dorado Holmes. Overlay: “90 coleccionables · 18 secretos · 6 recompensas”.

> Generar capturas con `flutter screenshot` en Pixel 7 y iPad: `flutter run -d <device> --route /library` y `--route /book/nebelheim/0`.

## Video 30 s (YouTube + Play Store preview)

**Guion 30 s, 16:9, sin voz en off (solo SFX + música loop):**
- 0-3 s: Splash_Watson.jpg fade → Biblioteca zoom.
- 3-8 s: Tap “El Reloj Detenido”, PageView efecto libro, pasar 2 páginas rápido.
- 8-13 s: Resolver mosaico → celebración 3,2 s (✔ elástico + estrellas +991 XP) → “Pasar página”.
- 13-18 s: Tocar 🔊 → frase se ilumina palabra a palabra, pausa entre frases visible.
- 18-23 s: Fallar 2 veces → Watson “Pista 2/3 — el siguiente fallo cambia la historia” → branch.
- 23-28 s: Resumen final perfecto → Stats → Colección → Postal compartida.
- 28-30 s: Pantalla título “Elemental, querido Watson” + CTA “Disponible en Google Play”.

**Export**: 1920×1080 MP4, 30 fps, <50 MB, subtítulos ES/EN opcionales.

## Localización
- Duplicar 8 capturas para ES y EN (cambiar idioma en `LocaleService` antes de capturar).
- Textos overlay traducidos (ver `play_store/es|en/full_description.txt`).

## Checklist D2
- [x] Fichas ES/EN (título 50c, corta 80c, larga 4000c, keywords)
- [x] 8 screenshots ES/EN + Feature Graphic 1024×500
- [ ] Video 30 s MP4 (pendiente render final)
- [x] Categoría: Puzzle > Aventura narrativa (Puzzle > Adventure)
- [x] Icono adaptativo #1A1009 (flutter_launcher_icons)
- [x] Etiquetas y long-tail keywords
