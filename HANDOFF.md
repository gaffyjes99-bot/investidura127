# Handoff — Libro Animado Investidura GS127

**Fecha última actualización:** 2026-07-07  
**Rama:** `main` → desplegado en `gh-pages`  
**URL producción:** https://gaffyjes99-bot.github.io/investidura127/  
**Panel dirigente:** https://gaffyjes99-bot.github.io/investidura127/panel/

---

## Estado actual del proyecto

App web educativa (Godot 4.7 → WebGL) para scouts del Grupo 127 de Colombia.  
12 capítulos con narrativa, mini-juegos y quizzes. Progreso sincronizado con Firestore.

### Features completas

| Feature | Estado |
|---------|--------|
| Login con validación Firestore (nombre + patrulla) | ✅ |
| Búsqueda fuzzy de scouts (Levenshtein + keywords) | ✅ |
| Guardar/cargar progreso en Firestore | ✅ |
| 12 capítulos con contenido y quizzes | ✅ |
| Mini-juego decisiones + biografía (cap 1) | ✅ |
| Insignias por capítulo completado | ✅ |
| Ken Burns animations | ✅ |
| Web export en GitHub Pages | ✅ |
| Colección `scouts_busqueda` (pública, datos mínimos) | ✅ |
| Colección `scouts` (privada, datos sensibles) | ✅ |
| **Panel del Dirigente** (`/panel/`) | ✅ |
| **Botones badge scout** (insignias PNG transparentes) | ✅ |
| **Fondo Mapa Senda** actualizado | ✅ |

---

## Arquitectura técnica

```
Godot 4.7 (GDScript)
├── AutoLoads: GameState, SaveManager, SceneRouter, FirebaseSync, FirebaseConfig
├── Escenas: onboarding, mapa_senda, capitulo, perfil, quiz
├── Assets/UI: godot/assets/ui/btn_siguiente.png, btn_mapa.png (insignias scout)
└── Web export → export/web/ → gh-pages

Firebase (fichas-actividad-scout)
├── scouts/            — privada, datos completos del scout
├── scouts_busqueda/   — pública, solo nombre/patrulla/grupoId/idScout
└── libro_interactivo_progreso/ — pública R/W, progreso por scout (127_scoutId)
   └── campos clave: xp_total, rango, capitulos_completados, insignias_desbloqueadas
       validaciones.{buenas_acciones, noches_campamento, comportamiento_hogar, rendimiento_academico}
          └── cada sub-campo tiene: valor, aprobado, codigo_validacion, aprobado_por, fecha_validacion

Panel del Dirigente
└── export/web/panel/index.html — HTML/JS/CSS vanilla, sin build
    ├── Lee: scouts_busqueda + libro_interactivo_progreso
    └── Escribe: validaciones (con updateMask)
    └── Clave de acceso: gs127panel2026 (cambiar const CLAVE_PANEL en el HTML)
```

---

## Botones de capítulo (estado actual)

Ambos botones son insignias circulares PNG con fondo transparente, 160×160 px:

| Botón | Imagen | Estilo |
|-------|--------|--------|
| SIGUIENTE | `godot/assets/ui/btn_siguiente.png` | Círculo dorado, flecha amarilla, banner "SIGUIENTE" |
| MAPA | `godot/assets/ui/btn_mapa.png` | Círculo madera, mapa del tesoro, banner "MAPA" |

- **Sin NinePatch**: `texture_margin_* = 0` — imagen llena el área sin deformar
- **Footer**: anchor_top=0.78 (antes 0.88), anchor_bottom=1.0
- **ContenidoArea**: anchor_bottom=0.77 (antes 0.87)
- **Texto en runtime**: vacío en estados normales (texto bakeado en imagen); "Volver al Mapa" / "Reintentar" se muestran sobreimpresos con outline negro

---

## Próxima prioridad — Circuito de validación caps 11-12

### Contexto
El Panel del Dirigente ya genera un código (6 chars alfanuméricos) y lo guarda en Firestore:
- Cap 11: `validaciones.comportamiento_hogar.codigo_validacion`
- Cap 12: `validaciones.rendimiento_academico.codigo_validacion`

### Qué falta
El scout NO puede aún ingresar el código en el quiz. Hay que implementar:

1. **Nuevo tipo de pregunta** `"Codigo"` en `godot/capitulos/11/preguntas.json` y `12/preguntas.json`
   - Q3 o Q8 del cap 11 (actualmente `null` distractores)
   - Q1 o Q2 del cap 12 (actualmente `null` distractores)

2. **Lógica en `SceneRouter.gd`** para manejar tipo `"Codigo"`:
   - Mostrar un `LineEdit` en el `QuizPanel` en lugar de botones de opciones
   - Al confirmar: llamar a Firestore para leer `validaciones.X.codigo_validacion` del scout actual
   - Si coincide: PATCH `validaciones.X.aprobado = true`, `aprobado_por = "scout"`, `fecha_validacion = fecha_actual`
   - Si no coincide: mostrar error, permitir reintento

3. **Firebase helper** en `firebase_sync.gd` o inline en SceneRouter para leer el código esperado

### Archivos clave para implementar
- `godot/autoload/SceneRouter.gd` — función `_quiz_mostrar_pregunta()` y `_quiz_verificar()`
- `godot/scripts/firebase_sync.gd` — helpers de Firestore (fetch GET con filtros)
- `godot/capitulos/11/preguntas.json` — cambiar tipo de Q3/Q8 a `"Codigo"`
- `godot/capitulos/12/preguntas.json` — cambiar tipo de Q1/Q2 a `"Codigo"`
- `godot/scenes/capitulo/capitulo.tscn` — agregar nodo `LineEdit` en `QuizPanel`

---

## Mejoras de contenido pendientes

| Cap | Problema |
|-----|----------|
| 05 | Q2, Q5, Q6 con 1 distractor |
| 06 | Q4, Q5, Q8 con 1 distractor; Q6 y Q9 con `null` (datos del grupo) |
| 08 | Preguntas de audio sin soporte de audio |
| 09 | Q5–Q7 son simuladores visuales (`null`) — feature no implementada |
| 10 | Q4, Q9, Q10 con `null` — requieren datos del grupo |
| 11 | Q3, Q8 `null` — pendientes circuito de validación |
| 12 | Q1-Q2 `null` — pendientes circuito de validación |

---

## Fase 9 (futura) — Notificaciones

- Scout logra nuevo rango → notificación visual
- Insignia desbloqueada → animación de celebración

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
| `godot/scenes/capitulo/capitulo.tscn` | Escena principal con botones badge PNG |
| `godot/assets/ui/btn_siguiente.png` | Botón SIGUIENTE — insignia circular dorada |
| `godot/assets/ui/btn_mapa.png` | Botón MAPA — insignia circular madera |
| `godot/capitulos/NN/preguntas.json` | Preguntas y distractores del quiz de cada cap |
| `godot/capitulos/NN/escenas.json` | Narrativa y mini-juegos de cada cap |
| `export/web/panel/index.html` | Panel del Dirigente (vanilla HTML/JS) |
| `docs/FIRESTORE_RULES_FINAL.md` | Reglas Firestore actuales |

---

## Historial de commits relevantes

```
87f1005  fix: replace siguiente button JPEG with transparent PNG
49a1c76  feat: replace chapter buttons with scout-style badge images
dc1b05a  docs: actualizar HANDOFF.md
d784c76  feat: botones con imagen PIL (reemplazados)
96474d6  assets: actualizar fondo del mapa de la Senda
9fce649  feat: Panel del Dirigente
```

---

## Comandos útiles

```bash
# Exportar a web
C:\Godot\Godot_v4.7-stable_win64.exe --headless --path godot --export-release "Web" C:/<ruta>/export/web/index.html

# Desplegar a GitHub Pages
git add -f export/web/index.html export/web/index.pck
git commit -m "build: web export"
git subtree push --prefix=export/web origin gh-pages

# Panel del Dirigente: clave de acceso
# const CLAVE_PANEL = 'gs127panel2026'  ← está en export/web/panel/index.html
```

---

## Fixes previos importantes (sesiones anteriores)

- `firebase_sync.gd::_fetch_async`: polling 0.1s, sin format strings `%`
- `_try_sync`: `updateMask.fieldPaths` para no sobreescribir metadata
- `_create_default_progress`: PATCH en vez de POST
- `onboarding.gd::_get_array_field`: desempaca objetos tipados Firestore
- Colección `scouts` privada; `scouts_busqueda` pública con solo 4 campos
- Quizzes caps 02, 03, 04, 07, 12: distractores corregidos y formato estandarizado

---

## Suggested Skills

- `superpowers:systematic-debugging` — bugs en login, progreso o validación
- `superpowers:verification-before-completion` — antes de dar una feature por terminada
- `claude-mem:mem-search` — contexto de sesiones anteriores
