# Handoff — Libro Animado Investidura GS127

**Fecha:** 2026-07-07  
**Rama:** `main` → desplegado en `gh-pages`  
**URL producción:** https://gaffyjes99-bot.github.io/investidura127/

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

---

## Sesión de hoy — resumen de cambios

### 1. Fix ingreso (login)
**Causa raíz:** `firebase_sync.gd::_fetch_async` usaba operador `%` de GDScript con 8 placeholders pero solo 4 argumentos → el JS nunca se evaluaba → timeout siempre.

**Fix:** `godot/scripts/firebase_sync.gd`
- `_fetch_async`: reescrita con concatenación de strings (sin `%`), polling 0.1s hasta 5s, lee resultado con `JavaScriptBridge.eval()`
- `_convert_to_firestore_format`: arrays ahora se convierten recursivamente a objetos tipados Firestore (`{"integerValue":"1"}` etc.)
- `_try_sync`: agregado `updateMask.fieldPaths` para no sobreescribir metadata
- `_create_default_progress`: cambiado de POST a PATCH (correcto para Firestore REST)

**Fix carga:** `godot/scenes/onboarding/onboarding.gd`
- `_get_array_field`: desempaca objetos tipados de Firestore → retorna valores GDScript directos

### 2. Seguridad — datos personales de menores
La colección `scouts` tenía lectura pública y exponía: cédula, teléfonos, email, fecha de nacimiento, tipo de sangre, factor Rh.

**Solución:**
- Nueva colección `scouts_busqueda` con solo `nombre`, `patrulla`, `grupoId`, `idScout`
- `scouts` → privada (`allow read: if request.auth != null`)
- `scouts_busqueda` → pública read-only (`allow write: if false`)
- Script de migración: `docs/migrar_scouts_busqueda.py` (ya ejecutado, 25 scouts migrados)
- App actualizada: `godot/firebase_config.gd` → `SCOUTS_COLLECTION = "scouts_busqueda"`
- Reglas aplicadas: ver `docs/FIRESTORE_RULES_FINAL.md`

### 3. Quizzes — contenido corregido

| Cap | Problema | Fix |
|-----|----------|-----|
| 02 | Arrays con 6–7 distractores (demasiados) | Reducido a 3 por pregunta |
| 03 | Varias preguntas con solo 1 distractor | Añadidos 2 distractores adicionales |
| 04 | Q1-Q2 con texto placeholder como distractor | Distractores reales |
| 07 | Varias preguntas 50/50 | Añadidos distractores |
| 12 | Q3–Q8 con "Repite de Cap. X" como distractor | Distractores reales |

**Pendiente (menor, no crítico):**
- Caps 05, 06, 08, 09, 10, 11: algunas preguntas con 1–2 distractores (funcionan pero son fáciles)
- Cap 08: preguntas de "Quiz de audio" sin soporte de audio — se muestran como texto, funciona pero no es ideal

---

## Arquitectura técnica

```
Godot 4.7 (GDScript)
├── AutoLoads: GameState, SaveManager, SceneRouter, FirebaseSync, FirebaseConfig
├── Escenas: onboarding, mapa_senda, capitulo, perfil, quiz
└── Web export → export/web/ → gh-pages

Firebase (fichas-actividad-scout)
├── scouts/           — privada, datos completos del scout
├── scouts_busqueda/  — pública, solo nombre/patrulla/grupoId/idScout
└── libro_interactivo_progreso/ — pública R/W, progreso por scout (127_scoutId)

HTTP: JavaScriptBridge.eval() → fetch API del browser → Firestore REST
```

**Nota importante sobre `_fetch_async`:** Usa `window.lastFetchResult` como variable global JS. Si hay dos fetches simultáneos se pueden pisar. En la práctica no ocurre (flujo secuencial), pero a considerar si se paraleliza en el futuro.

---

## Próximas fases (del roadmap)

### Fase 8 — Panel del dirigente (siguiente prioridad)
Dashboard web donde los dirigentes ven progreso de todos los scouts:
- Tabla de scouts con XP, rango, capítulos completados
- Validar buenas acciones y noches de campamento
- Generar códigos de validación para Q de validación externa (caps 11, 12)
- Ver `docs/NEXT_STEPS_PHASE7.md` para contexto adicional

### Fase 9 — Notificaciones
- Scout logra nuevo rango
- Insignia desbloqueada

### Mejoras de contenido pendientes (caps 05, 06, 08, 09, 10, 11)
- Cap 05: Q2, Q5, Q6 con 1 distractor
- Cap 06: Q4, Q5, Q8 con 1 distractor; Q6 y Q9 con `null` (dependen de datos del grupo)
- Cap 08: convertir preguntas de audio a texto (o implementar audio)
- Cap 09: Q5–Q7 son simuladores visuales (`null`) — feature no implementada
- Cap 10: Q4, Q9, Q10 con `null` — requieren datos del grupo

---

## Comandos útiles

```bash
# Exportar a web
C:\Godot\Godot_v4.7-stable_win64.exe --headless --path godot --export-release "Web" export/web/index.html

# Desplegar a GitHub Pages
git add export/web/index.html export/web/index.pck
git commit -m "build: web export"
git subtree push --prefix=export/web origin gh-pages

# Verificar reglas Firestore
curl "https://firestore.googleapis.com/v1/projects/fichas-actividad-scout/databases/(default)/documents/scouts_busqueda?key=AIzaSyBPFCRvhezdhz27OzPbZJijlOVKLnzKNo4"
# Debe retornar 200

curl "https://firestore.googleapis.com/v1/projects/fichas-actividad-scout/databases/(default)/documents/scouts?key=[REDACTED]"
# Debe retornar 403
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
| `godot/capitulos/NN/preguntas.json` | Preguntas y distractores del quiz de cada cap |
| `godot/capitulos/NN/escenas.json` | Narrativa y mini-juegos de cada cap |
| `docs/FIRESTORE_RULES_FINAL.md` | Reglas Firestore actuales |
| `docs/migrar_scouts_busqueda.py` | Script de migración (ya ejecutado) |

---

## Suggested skills

- `superpowers:systematic-debugging` — si hay bugs en el flujo de login o progreso
- `superpowers:verification-before-completion` — antes de dar por terminada cualquier feature
- `claude-mem:mem-search` — para buscar contexto de sesiones anteriores
- `gsd-debug` — para debugging estructurado
