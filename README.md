# investidura127

**La Senda del Pietierno** — Libro Interactivo Animado de Investidura
Grupo Scout 127 Liceo de Cervantes

Aplicación web progresiva (PWA) gamificada, construida en Godot Engine 4, que prepara a los scouts (10–15 años) para su ceremonia de investidura. Costo: $0 COP.

## Ubicación local del proyecto
```
C:\Users\gaffy\OneDrive\DocumentosJES\Singular_AI\Clientes\GS127\Tropa\Libro_Animado_investidura
```
Este directorio es la raíz del repositorio Git y el punto de partida para trabajar con Claude Code:
```
cd "C:\Users\gaffy\OneDrive\DocumentosJES\Singular_AI\Clientes\GS127\Tropa\Libro_Animado_investidura"
claude
```

**Nota OneDrive:** el `.gitignore` ya excluye builds y carpetas pesadas de Godot (`.godot/`, exports). Aun así, se recomienda excluir esta carpeta de la sincronización automática de OneDrive mientras se trabaja activamente en Fase 7 (Godot), para evitar conflictos de sincronización con archivos binarios de export.

## Estado del proyecto
🟢 Fase 0 — Kickoff y arquitectura: **Completa** (repo en GitHub, estructura de carpetas)
🟢 Validación técnica — Proyecto Godot mínimo exportado a Web y probado (incluye Safari/iPhone): **Completa**
🟢 Fase 1 — Extracción de contenidos: **Completa** (matriz maestra + banco de 120 preguntas)
🟢 Fase 2 — Guion pedagógico y de juego: **Completa** (guion.md, escenas.json, preguntas.json en cada capítulo + docs/Fase2_Guion_Pedagogico.md)
🟢 Fase 3 — Storyboard: **Especificación completa** (docs/Fase3_Guia_de_Estilo.md + docs/Fase3_Storyboard_48_Escenas.md)
🟡 Fase 4 — Producción gráfica: **En curso** — arte generado con IA (fondo transparente). Sprites, escudos y badges de caps 1–11 listos. Tarjetas de mapa (cap_NN_bloqueada/desbloqueada) completas.
🟡 Fase 7 — Implementación Godot: **En curso activo** — ver detalle abajo
⬜ Fase 5, 6, 8 — Pendientes

## Fase 7 — Estado de implementación Godot (2026-07-06)

### Funcional y deployado en gh-pages
- **Mapa de capítulos:** TextureButton con tarjetas `cap_NN_bloqueada/desbloqueada.png`, toast para capítulos bloqueados, badge de insignia animada (pop) sobre capítulo completado.
- **Escenas de narración:** texto typewriter, imagen lateral, Ken Burns con viñetas animadas.
- **Juego (mini-game):** decisiones de opción múltiple con retroalimentación inmediata + fill-in-the-blank (banco de palabras). Cap 2 completamente configurado.
- **Cuestionario (evaluación):** preguntas de opción múltiple, retroalimentación por respuesta, badge de insignia al aprobar.
- **Sistema XP:** acumulado por escena, mostrado en header.
- **Caps 1–11:** `escenas.json` + `preguntas.json` con contenido real. Cap 12 pendiente (examen integrador).

### Decisiones técnicas críticas
| Tema | Decisión |
|------|----------|
| Lógica UI | Todo en `godot/autoload/SceneRouter.gd` (AutoLoad). Scripts de escena `.gd` NO ejecutan en web export. |
| `expand_mode` badges | Usar `EXPAND_IGNORE_SIZE` (= 1). `EXPAND_KEEP_SIZE` (= 0) fuerza tamaño de textura (600×600). |
| Limpieza de nodos en web | `remove_child(c)` + `c.queue_free()` — más confiable que solo `queue_free()` en web. |
| Tarjetas de mapa | `TextureButton` con `ignore_texture_size = true` + `STRETCH_SCALE`. |
| Distractores quiz | Soporta dos formatos: string `"a \| b \| c"` (caps 1, 3–11) y array JSON `["a","b","c"]` (cap 2). |
| Edición de SceneRouter.gd | Usar Python via Bash para reemplazos exactos con tabs — el Edit tool falla por indentación. |

### Pipeline de publicación
```powershell
# Ejecutable Godot
$godot = "C:\Users\gaffy\Downloads\Godot_v4.7-stable_win64.exe\Godot_v4.7-stable_win64.exe"

# 1. Exportar
& $godot --headless --path godot --export-release "Web" export/web/index.html

# 2. Commit + push gh-pages (en Bash)
git add godot/ export/web/
git commit -m "mensaje"
git subtree push --prefix=export/web origin gh-pages
```
> Siempre probar en modo incógnito — el browser cachea el `.pck` agresivamente.

### Pendientes Fase 7
- [ ] Cap 12 — Examen integrador (no implementado)
- [ ] Cap 8 — Audio de señales de silbato (requiere grabación del dirigente)
- [ ] Caps 3–11 `titulo_decision` en `escenas.json` (usan default `"¿Qué harías?"`)
- [ ] Integración Firestore (progreso persistente entre sesiones)
- [ ] Panel dirigente en `scouts-app`

---

## Stack & Arquitectura Técnica
- **Frontend:** Godot Engine 4 → export HTML5 → GitHub Pages (costo: $0)
- **Backend de sincronización:** Firestore (Google, proyecto existente `fichas-actividad-scout` del Grupo 127, reutilizado sin costo adicional)
  - Nueva colección: `libro_interactivo_progreso` (coexiste con colecciones existentes `scouts`, `progresion_scouts`, etc.)
- **Identificación del usuario:** nombre scout + patrulla elegidos por el usuario en el app, **sin email**. Se vincula automáticamente con el scoutId en la colección `scouts` existente.
- **Privacidad:** progreso guardado localmente en el dispositivo + sincronizado automáticamente a Firestore. Sin datos personales sensibles (progreso educativo únicamente). Sujeto a Terms of Service de Google / Privacy de Firestore.
- **Panel dirigente:** nueva sección en la app React existente (`scouts-app`), accesible solo para jefes autenticados, que muestra progreso del Libro Interactivo y permite validaciones.

## Nota sobre el equipo
El proyecto se ejecuta con **una sola persona**. El cronograma y roles del Plan Maestro original (§6) asumían un equipo de 5-6 voluntarios; se ajustó para producir arte con IA en vez de ilustración manual, lo que reduce significativamente el tiempo de Fases 3-6.

## Documentación
- `/docs/Plan_Completo_Libro_Interactivo_Investidura.md` — plan maestro completo (fases, gamificación, cronograma, equipo, asignación de modelos Claude)
- `/docs/Matriz_Maestra_Contenidos.xlsx` — matriz de los 12 capítulos vs. requisitos de investidura
- `/docs/Firebase_Especificacion_Tecnica.md` — cómo funciona la sincronización de progreso en tiempo real (Fase 7)

## Estructura
```
investidura127
├── assets/          # audio, video, imágenes, sprites
├── capitulos/        # 12 carpetas, una por capítulo (01-12)
├── evaluaciones/      # bancos de preguntas en JSON
├── gamificacion/      # sistema de XP e insignias
├── personajes/       # arte de personajes narradores
├── patrullas/        # arte de Jaguares, Lobos, Mapaches, Pandas
├── export/           # builds de Godot (web, android)
└── docs/             # documentación del proyecto
```

## Cómo contribuir
1. Cada capítulo tiene su propia carpeta en `/capitulos/NN_nombre/` con: `guion.md`, `escenas.json`, `preguntas.json`.
2. Los assets van en la subcarpeta correspondiente de `/assets/`, nombrados `capNN_descripcion.ext`.
3. El desarrollo Godot se hace en una carpeta `godot/` en la raíz (se crea al iniciar Fase 7).

## Equipo
| Rol | Responsable |
|---|---|
| Jefe pedagógico scout | Por asignar |
| Diseñador/ilustrador | Por asignar |
| Programador Godot | Por asignar |
| Narradores (2) | Por asignar |
| Testers scouts (4) | Por asignar |

## Licencia
Uso interno del Grupo Scout 127. Contenido pedagógico basado en la Bitácora Scout 2018 y la Tabla de Progresión Personal de la Asociación Scouts de Colombia.
