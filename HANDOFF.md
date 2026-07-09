# Handoff — Libro Animado Investidura GS127

**Fecha última actualización:** 2026-07-09
**Versión app:** `0.5.0`
**Rama:** `main` → desplegado en `gh-pages`
**URL producción:** https://gaffyjes99-bot.github.io/investidura127/
**Panel dirigente:** https://gaffyjes99-bot.github.io/investidura127/panel/

---

## Estado actual del proyecto

App web educativa (Godot 4.7 → WebGL) para scouts del Grupo 127 de Colombia.
12 capítulos con narrativa, mini-juegos, quizzes y examen final. Progreso sincronizado con Firestore.
Optimizada para celular. **Verificado funcionando por el cliente** (login, progreso, capítulos).

### Marca de versión (diagnóstico de caché)
Esquina inferior derecha de cada capítulo muestra `vX.Y.Z-M` (móvil) o `-D` (escritorio).
Sirve para confirmar si el celular tiene la versión nueva o una cacheada. Se genera en
`SceneRouter._crear_marca_version()` y lee `application/config/version` de `project.godot`.

### Features completas

| Feature | Estado |
|---------|--------|
| Login con validación Firestore (nombre + patrulla) + búsqueda fuzzy | ✅ |
| Guardar/cargar progreso (localStorage + Firestore) | ✅ |
| 12 capítulos con contenido, mini-juegos y quizzes | ✅ |
| Insignias por capítulo + Ken Burns animations | ✅ |
| Panel del Dirigente (`/panel/`) | ✅ |
| Botones badge scout (PNG transparentes) | ✅ |
| **Soporte móvil**: teclado virtual, orientación landscape, aviso "gira tu celular", escala global 1.4× en táctil, texto de lectura 28pt | ✅ |
| **Sprite del narrador correcto por capítulo** (CAP_SPRITES) | ✅ |
| **Examen final integrador** (cap 12): 20 preguntas al azar del banco de los 12 caps, 90%, reintentos ilimitados, animación Gran Ceremonia al aprobar | ✅ |
| **Oración de patrulla** (cap 10) con nombre personalizado | ✅ |
| **Promesa scout** (cap 3) con texto oficial + nombre personalizado | ✅ |
| **Llamados de pito en Morse** (cap 8) | ✅ |
| **Fondo de bosque en capítulos** con velo de legibilidad | ✅ |
| **Circuito de validación por código** (caps 11-12): scout ingresa el código del dirigente → marca `aprobado` en Firestore | ✅ |
| **Panel muestra el progreso real** (fix de clave de documento, commit `9b09a4c`) | ✅ |

---

## Cambios de esta sesión (2026-07-08)

Ver commits `f8fb1ce`, `74f5c7d`, `8a78191`, `84fc6ce`, `ea0177e`, `7eb596e`, `1b5e7b2`, `3614d38`, `99bc946` en `main`.

1. **Soporte móvil completo** (`export_presets.cfg`, `project.godot`, `SceneRouter.gd`):
   - `html/experimental_virtual_keyboard=true` — teclado al tocar campos de texto.
   - `window/handheld/orientation=4` (landscape).
   - Overlay CSS "Gira tu celular" (solo en `orientation: portrait` táctil) vía `html/head_include`.
   - `content_scale_factor = 1.4` cuando `_es_movil()` — todo 40% más grande en táctil.
   - Texto de lectura (RichTextLabel) 28pt en móvil.
   - El pellizco para zoom del navegador **no funciona** (el motor captura el gesto); la escala 1.4 es el reemplazo.

2. **`{nombre}` en narración** (`SceneRouter.gd` ~línea 620): `texto.replace("{nombre}", GameState.nombre_scout)`.
   Usado en la oración de patrulla (cap 10), promesa (cap 3) e intro del examen (cap 12).

3. **CAP_SPRITES corregido** (`SceneRouter.gd`): cada capítulo muestra el sprite de su narrador real
   (1,3,9,11 BP · 2,10 Akela · 4 Baloo · 5 Jacala · 6 Wontolla · 7 Kaa · 8 Kotick · 12 BP celebrate).

4. **Examen final** (`SceneRouter.gd` + `capitulos/12/escenas.json`):
   - `_cargar_banco_examen(n)` junta las preguntas de los 12 caps (105 válidas) y toma `n` al azar.
   - Flag `examen_final` + `num_preguntas` + `minimo_aprobar_pct: 90` en la escena `evaluacion`.
   - Estado `_cap_estado = 3` (aprobado, pendiente ceremonia) → botón "Ver la Gran Ceremonia".
   - `_lanzar_ceremonia()` / `_ceremonia_final()` reutilizan el motor Ken Burns; 6 viñetas en campo `ceremonia`.

5. **Fix de sincronización de progreso** (`firebase_sync.gd`, `SaveManager.gd`) — ver sección abajo.

6. **Contenido**: promesa cap 3 (texto oficial + `{nombre}` + "mi familia"), oración patrulla cap 10,
   llamados de pito en Morse cap 8, fondo `Fondo_Capitulos.png` + velo 62%.

---

## Fix de sincronización de progreso (importante)

**Bug encontrado y resuelto:** al reabrir el libro con progreso guardado, la app va directo al mapa
**sin re-login**, pero `FirebaseSync._current_scout_id` solo se seteaba en el login → `push_scout_data`
abortaba y **ningún capítulo posterior al primero se sincronizaba** a Firestore (ni al panel).

**Solución (commit `8a78191`):**
- `FirebaseSync.ensure_scout_context(scout_id)` — restaura el `scout_id` desde `GameState`.
- `SaveManager._sync_to_firestore()` llama `ensure_scout_context` antes de cada push.
- `SaveManager.cargar()` hace una sincronización de puesta al día del estado local completo.
- `ultima_actualizacion` ahora usa `Time.get_unix_time_from_system()` (antes `get_ticks_msec`, que se reiniciaba).

**Nota:** la puesta al día sube lo que esté en localStorage del dispositivo. Si el guardado local se perdió
(incógnito, borrar datos), no hay nada que recuperar de esas partidas — pero de ahí en adelante sincroniza bien.

---

## Convención de clave del documento de progreso (IMPORTANTE — no romper)

El documento de `libro_interactivo_progreso` de cada scout se llama:

```
127_<ID del documento en scouts_busqueda>      ej. 127_127_Tropa_430002057
```

Es decir: `GRUPO_ID` + `"_"` + el **ID del documento** de `scouts_busqueda` (que ya empieza por `127_Tropa_...`),
lo que produce el doble `127_`. **NO** se usa el campo `idScout` (`430002057`) para la clave.

- La app (Godot) lo construye así porque `FirebaseSync._current_scout_id` = `doc.name.split("/")[-1]`
  de `scouts_busqueda` (ver `_process_find_scout_response`), y el doc de progreso es `127_<_current_scout_id>`.
- El **panel** debe usar la misma clave: `docId = 127_<d.name.split('/').pop()>` (arreglado en commit `9b09a4c`).
  Antes usaba `127_<campo idScout>` y no encontraba el progreso (mostraba ceros) ni escribía los códigos
  de validación donde la app los lee.

> Si algún día se cambia la clave, hay que cambiarla **a la vez** en `firebase_sync.gd` (app) y en
> `export/web/panel/index.html` (panel), y migrar los documentos existentes.

---

## Arquitectura técnica

```
Godot 4.7 (GDScript)
├── AutoLoads: GameState, SaveManager, SceneRouter, FirebaseConfig, FirebaseSync
├── Escenas: onboarding, mapa_senda, capitulo, perfil, quiz
├── Fondo capítulos: godot/assets/sprites/Fondo_Capitulos.png (+ Velo ColorRect 62% en capitulo.tscn)
├── Sprites narrador: godot/assets/sprites/<personaje>_talking_v1.png (CAP_SPRITES)
└── Web export → export/web/ → gh-pages (vía git subtree)

Firebase (fichas-actividad-scout)
├── scouts/            — privada, datos completos
├── scouts_busqueda/   — pública, solo nombre/patrulla/grupoId/idScout
└── libro_interactivo_progreso/ — pública R/W, doc id = 127_<scoutId>
   └── xp_total, rango, capitulos_completados, insignias_desbloqueadas, ultima_actualizacion
       validaciones.{buenas_acciones, noches_campamento, comportamiento_hogar, rendimiento_academico}

Panel del Dirigente
└── export/web/panel/index.html — HTML/JS/CSS vanilla, sin build
    ├── Lee: scouts_busqueda + libro_interactivo_progreso
    ├── Escribe: validaciones (updateMask) + genera códigos
    └── Clave acceso: gs127panel2026 (const CLAVE_PANEL en el HTML)
```

---

## Circuito de validación por código caps 11-12 (COMPLETADO en v0.5.0)

Implementado en commit `c391c9c`. El Panel del Dirigente genera un código de 6 chars y lo guarda en
Firestore; el scout lo ingresa en el libro para aprobar el requisito.

- **Escena tipo `"codigo"`** en `capitulos/11/escenas.json` (`validacion: comportamiento_hogar`) y
  `capitulos/12/escenas.json` (`validacion: rendimiento_academico`), insertada antes de la `evaluacion`.
  Campos: `validacion`, `titulo`, `instruccion`, `xp`.
- **`firebase_sync.gd`**: `obtener_validacion(tipo)` (GET estado) y `verificar_codigo(tipo, codigo)`
  (GET + compara case-insensitive + PATCH `validaciones.<tipo>.{aprobado,aprobado_por,fecha_validacion}`
  con **updateMask anidado** — verificado que NO borra el `codigo_validacion` ni campos hermanos).
- **`SceneRouter.gd`**: rama `"codigo"` en `_cap_mostrar_escena`, `_mostrar_codigo()`, `_codigo_check_estado()`,
  `_on_validar_codigo()`, `_codigo_bloquear_ok()`. Var `_codigo_tipo`. No bloquea: el scout puede continuar
  sin código y volver luego. Muestra "ya validado" / "aún no hay código" / errores.
- **`capitulo.tscn`**: nodo `CodigoPanel` (Titulo, Instruccion, CodigoInput LineEdit, BotonValidar, EstadoLabel).

> Pendiente de prueba jugable end-to-end en dispositivo (login + caps desbloqueados): generar código en
> el panel, ingresarlo en el cap 11/12, confirmar el ✓ en el panel.

---

## Próximas prioridades (sugeridas)

1. Prueba end-to-end del circuito de validación en dispositivo real.
2. Mejoras de contenido con preguntas `null`/1 distractor (tabla abajo) — requieren datos del Grupo 127.
3. Fase 9 (notificaciones de rango/insignia).

---

## Mejoras de contenido pendientes

| Cap | Problema |
|-----|----------|
| 05 | Q2, Q5, Q6 con 1 distractor |
| 06 | Q4, Q5, Q8 con 1 distractor; Q6/Q9 `null` (datos del grupo) |
| 08 | Preguntas de audio sin soporte de audio (los llamados ya están en Morse en texto) |
| 09 | Q5–Q7 simuladores visuales (`null`) — no implementados |
| 10 | Q4, Q9, Q10 `null` — datos del grupo |
| 11 | Validación por código ya implementada (escena `codigo`); resto de preguntas OK |
| 12 | Evaluación = examen final integrador; validación por código ya implementada |

---

## Flujo de trabajo: export, deploy y verificación

> ⚠️ **Usar Bash/git, NO PowerShell.** El proyecto está en OneDrive; PowerShell dio lecturas
> corruptas de binarios y estados de git falsos ("working tree clean" cuando no lo estaba).
> Con Git Bash el flujo es confiable. Nota: el `python` del sistema es nativo de Windows y no
> entiende rutas MSYS (`/c/...`) al escribir — usar rutas relativas o `C:\...`.

```bash
cd "<ruta del proyecto>"

# 1. Subir versión en godot/project.godot: config/version="0.4.X"

# 2. Exportar a web (importa assets nuevos automáticamente)
"/c/Godot/Godot_v4.7-stable_win64.exe" --headless --path godot \
  --export-release "Web" "$(pwd)/export/web/index.html" 2>&1 | grep -iE "error|parse"
# (sin líneas de error = OK)

# 3. Verificar que el contenido/asset nuevo quedó empaquetado
python -c "d=open('export/web/index.pck','rb').read(); print(d.find('<texto nuevo>'.encode('utf-8'))>=0)"

# 4. Commit y deploy
git add godot/... export/web/index.html export/web/index.pck
git commit -m "..."
git push origin main
git subtree push --prefix=export/web origin gh-pages

# 5. Verificar que producción sirve el pck nuevo (GitHub Pages tarda 1-3 min)
disk=$(sha256sum export/web/index.pck | cut -d' ' -f1)
curl -s -o /tmp/live.pck "https://gaffyjes99-bot.github.io/investidura127/index.pck?t=$(date +%s)"
[ "$disk" = "$(sha256sum /tmp/live.pck | cut -d' ' -f1)" ] && echo "OK" || echo "aún propagando"
```

**Aviso de LFS**: `index.pck` pesa ~58 MB; GitHub muestra warning de tamaño >50 MB en cada push. No bloquea.

---

## Limitación de verificación

El recorrido jugable dentro de un capítulo (narrativa, quiz, examen, ceremonia) **no se puede probar
en el entorno del agente**: requiere login real de Firebase + capítulos desbloqueados. Lo que SÍ se
verifica del lado del agente: JSON válido, export sin errores de script, contenido/asset empaquetado
en el pck, y hash de producción == build local. La legibilidad del fondo se validó con una composición
PIL (imagen + velo + texto). La prueba jugable final la hace el cliente en su dispositivo.

---

## Archivos clave

| Archivo | Propósito |
|---------|-----------|
| `godot/autoload/SceneRouter.gd` | Navegación, capítulos, quiz, examen final, ceremonia, CAP_SPRITES, `{nombre}`, marca de versión |
| `godot/autoload/SaveManager.gd` | Guardar local + sync Firestore + puesta al día en `cargar()` |
| `godot/autoload/GameState.gd` | Estado global (XP, rango, capítulos, scout_id) |
| `godot/scripts/firebase_sync.gd` | Firestore vía fetch API; `ensure_scout_context()` |
| `godot/firebase_config.gd` | Endpoints, API key, colecciones, doc por defecto |
| `godot/scenes/onboarding/onboarding.gd` | Login + carga de progreso |
| `godot/scenes/capitulo/capitulo.tscn` | Escena de capítulo (fondo TextureRect + Velo, paneles, botones badge) |
| `godot/capitulos/NN/escenas.json` | Narrativa, mini-juegos, viñetas de cada cap |
| `godot/capitulos/NN/preguntas.json` | Preguntas y distractores del quiz |
| `export/web/panel/index.html` | Panel del Dirigente (vanilla HTML/JS) |
| `export_presets.cfg` (en `godot/`) | Config export web: teclado virtual, `head_include` (overlay + zoom) |
| `docs/FIRESTORE_RULES_FINAL.md` | Reglas Firestore actuales |

---

## Suggested Skills

- `superpowers:systematic-debugging` — bugs de login, progreso o sincronización (ver método usado en el fix de sync).
- `superpowers:verification-before-completion` — antes de dar una feature por terminada; recordar la limitación de verificación jugable.
- `claude-mem:mem-search` — contexto de sesiones anteriores (esta sesión: obs 2843–2921).
