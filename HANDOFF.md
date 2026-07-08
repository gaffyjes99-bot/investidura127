# Handoff — Libro Animado Investidura GS127

**Fecha:** 2026-07-07  
**Rama:** `main` → desplegado en `gh-pages`  
**URL producción:** https://gaffyjes99-bot.github.io/investidura127/  
**Panel dirigente:** https://gaffyjes99-bot.github.io/investidura127/panel/

---

## Estado actual del proyecto

App web educativa (Godot 4.7 → WebGL) para scouts del Grupo 127 de Colombia.  
12 capítulos con narrativa, mini-juegos y quizzes. Progreso sincronizado con Firestore.

### Lo que funciona hoy

| Feature | Estado |
|---------|--------|
| Login con validación Firestore (nombre + patrulla) | ✅ |
| Búsqueda fuzzy de scouts (Levenshtein) | ✅ |
| Guardar progreso en Firestore (XP, rango, capítulos) | ✅ |
| Cargar progreso al volver a ingresar | ✅ |
| 12 capítulos con contenido y quizzes | ✅ |
| Mini-juego decisiones + biografía (cap 1) | ✅ |
| Insignias por capítulo completado | ✅ |
| Ken Burns animations | ✅ |
| Web export en GitHub Pages | ✅ |
| Colección `scouts_busqueda` (datos mínimos, pública) | ✅ |
| Colección `scouts` (datos sensibles, privada) | ✅ |
| **Panel del Dirigente** (`/panel/`) | ✅ |
| **Botones con imagen PIL** (madera dorada/verde) | ✅ |
| **Fondo Mapa Senda** actualizado | ✅ |

---

## Sesiones anteriores — resumen acumulado

Ver `docs/FIRESTORE_RULES_FINAL.md` para reglas Firestore completas.  
Ver `docs/migrar_scouts_busqueda.py` para script de migración (ya ejecutado).

### Fixes previos
- `firebase_sync.gd::_fetch_async`: reescrita con concatenación (sin `%`), polling 0.1s
- `_convert_to_firestore_format`: arrays convertidos recursivamente a formato Firestore tipado
- `_try_sync`: `updateMask.fieldPaths` para no sobreescribir metadata
- `_create_default_progress`: cambiado de POST a PATCH
- `onboarding.gd::_get_array_field`: desempaca objetos tipados Firestore
- Seguridad: colección `scouts` privada, `scouts_busqueda` pública con solo 4 campos
- Quizzes caps 02, 03, 04, 07, 12: distractores corregidos

---

## Sesión de hoy (2026-07-07 — noche)

### 1. Fase 8 — Panel del Dirigente

**Archivo:** `export/web/panel/index.html` (single-file HTML/JS/CSS, vanilla)  
**URL:** `/panel/`  
**Clave de acceso:** `gs127panel2026` (cambiar en `const CLAVE_PANEL` del HTML)

**Funcionalidades:**
- Tabla de todos los scouts (de `scouts_busqueda`) con XP, rango, capítulos 1–12
- Filtros: patrulla, nombre, orden por XP/caps/nombre
- Stats resumen: total scouts, promedios, totales buenas acciones y campamento
- Contadores +/− para buenas acciones y noches de campamento por scout (debounce 1s → Firestore)
- Generar códigos de validación (6 chars alfanuméricos) para:
  - Cap 11: `validaciones.comportamiento_hogar.codigo_validacion`
  - Cap 12: `validaciones.rendimiento_academico.codigo_validacion`
- Lee de `scouts_busqueda` + `libro_interactivo_progreso`, escribe solo `validaciones` con `updateMask`
- Auth: clave de sesión en `sessionStorage`

**Pendiente del circuito de validación:** el scout todavía NO puede ingresar el código en el quiz del cap 11/12 para que se marque como validado. Eso es la pieza que falta.

### 2. Fondo_Mapa_Senda1.png actualizado

Nueva imagen (ilustración detallada del mapa scout) copiada a:
- `godot/assets/backgrounds/Fondo_Mapa_Senda1.png`
- `godot/assets/sprites/Fondo_Mapa_Senda1.png`

Godot la reimportó automáticamente en el export.

### 3. Botones con imagen PIL

**Archivos generados:** `godot/assets/ui/btn_p_n.png`, `btn_p_h.png`, `btn_p_p.png` (primary/Siguiente), `btn_s_n.png`, `btn_s_h.png`, `btn_s_p.png` (secondary/Mapa)

**Diseño:** 480×112 px, madera dorada (Siguiente) y verde oscura (Mapa).  
Cada imagen tiene: gradiente vertical, sombra, borde con gradado, bisel superior, veta de madera, 3 estados (normal/hover/pressed).

**Integración:** `godot/scenes/capitulo/capitulo.tscn` usa `StyleBoxTexture` con NinePatch margins=22px.  
Disabled state: `StyleBoxFlat` semi-transparente.  
Tamaños mínimos: Mapa `180×60`, Siguiente `262×60`.

Script para regenerar imágenes si se necesita cambiar colores: ver commit `d784c76`, la lógica PIL está inline en el commit message / se puede reproducir con el script del contexto anterior.

---

## Arquitectura técnica

```
Godot 4.7 (GDScript)
├── AutoLoads: GameState, SaveManager, SceneRouter, FirebaseSync, FirebaseConfig
├── Escenas: onboarding, mapa_senda, capitulo, perfil, quiz
├── Assets/UI: godot/assets/ui/btn_*.png (botones PIL)
└── Web export → export/web/ → gh-pages

Firebase (fichas-actividad-scout)
├── scouts/           — privada, datos completos del scout
├── scouts_busqueda/  — pública, solo nombre/patrulla/grupoId/idScout
└── libro_interactivo_progreso/ — pública R/W, progreso por scout (127_scoutId)
   └── campos clave: xp_total, rango, capitulos_completados, insignias_desbloqueadas
       validaciones.{buenas_acciones, noches_campamento, comportamiento_hogar, rendimiento_academico}

Panel del Dirigente
└── export/web/panel/index.html — HTML/JS/CSS vanilla, sin build
    └── Lee: scouts_busqueda + libro_interactivo_progreso
    └── Escribe: validaciones (con updateMask)
```

---

## Próximas fases (del roadmap)

### Próxima prioridad — Cerrar circuito validación caps 11-12

El panel genera un código (6 chars) y lo guarda en Firestore bajo `validaciones.comportamiento_hogar.codigo_validacion` o `validaciones.rendimiento_academico.codigo_validacion`.

Falta: en el quiz del cap 11 y 12, hay preguntas de validación externa (`null` distractores). El scout debería poder ingresar el código del dirigente, la app lo compara con Firestore y marca `aprobado: true`.

Archivo relevante: `godot/capitulos/11/preguntas.json` y `godot/capitulos/12/preguntas.json` — Q3 y Q8 en cap 11, Q1-Q2 en cap 12 son las candidatas.

Approach sugerido: nueva lógica en `SceneRouter.gd` para preguntas de tipo `"Codigo"` que abre un campo de texto y llama a Firebase a verificar.

### Fase 9 — Notificaciones
- Scout logra nuevo rango → notificación
- Insignia desbloqueada → animación

### Mejoras de contenido pendientes

| Cap | Problema |
|-----|----------|
| 05 | Q2, Q5, Q6 con 1 distractor |
| 06 | Q4, Q5, Q8 con 1 distractor; Q6 y Q9 con `null` (datos del grupo) |
| 08 | Preguntas de audio sin soporte de audio |
| 09 | Q5–Q7 son simuladores visuales (`null`) — feature no implementada |
| 10 | Q4, Q9, Q10 con `null` — requieren datos del grupo |
| 11 | Q3, Q8 `null` — pendiente circuito validación |

---

## Comandos útiles

```bash
# Exportar a web
C:\Godot\Godot_v4.7-stable_win64.exe --headless --path godot --export-release "Web" C:/...ruta.../export/web/index.html

# Desplegar a GitHub Pages
git add -f export/web/index.html export/web/index.pck
git commit -m "build: web export"
git subtree push --prefix=export/web origin gh-pages

# Regenerar imágenes de botones (PIL)
# Ver script Python en el contexto de la sesión anterior (commit d784c76)
# Los colores están en las variables P_BG_N, P_BD_N, S_BG_N, etc.

# Verificar panel
curl https://gaffyjes99-bot.github.io/investidura127/panel/
```

---

## Archivos clave

| Archivo | Propósito |
|---------|-----------|
| `godot/scripts/firebase_sync.gd` | Toda la comunicación con Firestore vía fetch API |
| `godot/firebase_config.gd` | Endpoints, API key, colecciones |
| `godot/scenes/onboarding/onboarding.gd` | Login + carga de progreso |
| `godot/autoload/SceneRouter.gd` | Navegación + lógica de capítulos/quizzes |
| `godot/autoload/SaveManager.gd` | Guardar local (localStorage) + sync Firestore |
| `godot/autoload/GameState.gd` | Estado global del scout (XP, rango, capítulos) |
| `godot/scenes/capitulo/capitulo.tscn` | Escena principal con botones PNG (StyleBoxTexture) |
| `godot/assets/ui/btn_*.png` | Texturas de botones (6 PNGs, PIL) |
| `godot/capitulos/NN/preguntas.json` | Preguntas y distractores del quiz de cada cap |
| `godot/capitulos/NN/escenas.json` | Narrativa y mini-juegos de cada cap |
| `export/web/panel/index.html` | Panel del Dirigente (vanilla HTML/JS) |
| `docs/FIRESTORE_RULES_FINAL.md` | Reglas Firestore actuales |
| `docs/migrar_scouts_busqueda.py` | Script de migración (ya ejecutado) |

---

## Suggested skills

- `superpowers:systematic-debugging` — si hay bugs en el flujo de login, progreso o validación
- `superpowers:verification-before-completion` — antes de dar por terminada cualquier feature
- `claude-mem:mem-search` — para buscar contexto de sesiones anteriores
