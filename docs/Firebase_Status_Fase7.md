# Estado Firebase Firestore — Fase 7 (Implementación completada)

**Proyecto:** fichas-actividad-scout (Grupo 127)  
**Fecha:** 2026-07-07  
**Status:** ✅ Implementado, pendiente configuración de credenciales

---

## Resumen de implementación

### ✅ Completed — Código implementado

**Archivos creados:**

1. `godot/firebase_config.gd` — Configuración centralizada
   - URLs endpoints REST API Firestore
   - Constantes de sincronización
   - Estructura por defecto para documentos

2. `godot/scripts/firebase_sync.gd` (~500 líneas) — Motor de sincronización
   - ✓ `find_scout_in_firestore(nombre, patrulla)` — búsqueda fuzzy Levenshtein 80%
   - ✓ `get_scout_progress(grupo_id, scout_id)` — descarga/crea documento
   - ✓ `push_scout_data(updates)` — sincroniza cambios
   - ✓ `_on_sync_timer_timeout()` — reintentos cada 5 segundos
   - ✓ Buffer local + fallback offline
   - ✓ Sistema de señales completo

**Archivos modificados:**

3. `godot/scenes/onboarding/onboarding.gd` (67 líneas agregadas)
   - Integración búsqueda fuzzy en login
   - Descarga de progreso desde Firestore
   - Desempaque de datos Firestore a GameState
   - Manejo de múltiples coincidencias

4. `godot/autoload/GameState.gd`
   - ✓ Agregado `scout_id: String` para tracking de Firestore

5. `godot/autoload/SaveManager.gd`
   - ✓ Agregado `scout_id` en guardar/cargar
   - ✓ `_sync_to_firestore()` — sincroniza automáticamente después de guardar

6. `godot/scenes/mecanicas/quiz.gd`
   - ✓ `_sync_quiz_result()` — sincroniza resultado del quiz

7. `godot/scenes/capitulo/capitulo.gd`
   - ✓ `_sync_chapter_completed()` — sincroniza capítulo completado

8. `godot/project.godot`
   - ✓ Registrados `FirebaseConfig` y `FirebaseSync` como autoloads

**Documentación:**

9. `docs/Firebase_Integracion_Godot.md` — Guía de integración completa
10. `docs/Firebase_Ejemplos_Integracion.gd` — Código ejemplo para todas las escenas
11. `docs/Firebase_Checklist_Setup.md` — Checklist paso a paso
12. `docs/Firebase_Status_Fase7.md` — Este archivo

---

## Flujo de login implementado (crítico)

```
1. Scout ingresa nombre + elige patrulla
   ↓
2. FirebaseSync.find_scout_in_firestore(nombre, patrulla)
   - Búsqueda fuzzy 80% Levenshtein en colección 'scouts'
   - Si 1 match → retorna scout_id
   - Si múltiples → muestra lista para confirmar
   - Si ninguno → error "Scout no encontrado"
   ↓
3. FirebaseSync.get_scout_progress(grupoId, scout_id)
   - Descarga desde libro_interactivo_progreso/{grupoId}_{scoutId}
   - Si no existe → crea documento con valores por defecto
   ↓
4. Desempacar datos Firestore a GameState
   - xp_total → GameState.xp
   - rango → GameState.rango
   - capitulos_completados → GameState.capitulos_completados
   - insignias_desbloqueadas → GameState.insignias
   ↓
5. SaveManager.guardar() → sincroniza a localStorage + Firestore
   ↓
6. Cambiar a escena mapa
```

---

## Flujo de sincronización durante el juego

```
Scout completa escena/quiz/capítulo
   ↓
GameState.dar_xp() + GameState.completar_capitulo()
   ↓
SaveManager.guardar()
   ├── Guardar en localStorage
   └── _sync_to_firestore() → FirebaseSync.push_scout_data()
   ↓
FirebaseSync genera PATCH a Firestore
   ├── Si conexión OK → envía inmediatamente
   ├── Si sin conexión → guarda en buffer local
   └── Timer cada 5s intenta reintentar
   ↓
Mostrar "Sincronizando..." si >10s sin conexión
   ↓
Cuando restaura conexión → sincroniza automáticamente
```

---

## Cambio de dispositivo (multi-device support)

```
Dispositivo A: Scout completa capítulos, todo sincronizado a Firestore ✓

Dispositivo B: Scout abre app
   ↓
Ingresa mismo nombre + patrulla
   ↓
find_scout_in_firestore() → encuentra su scout_id
   ↓
get_scout_progress() → descarga su progreso completo
   ↓
GameState cargado con progreso remoto
   ↓
Continúa donde lo dejó en Dispositivo A ✓
```

---

## Estructura Firestore implementada

**Colección:** `libro_interactivo_progreso`

**Documento ID:** `{grupoId}_{scoutId}` (ej: `127_scout123`)

**Schema:**

```json
{
  "grupoId": "127",
  "scoutId": "scout123",
  "nombre": "Carlos López",
  "patrulla": "Jaguares",
  "creado_en": "2026-07-07T12:00:00Z",
  "ultima_actualizacion": "2026-07-07T15:30:45Z",
  "rango": "Pietierno",
  "xp_total": 450,
  "capitulos_completados": ["01", "02"],
  "capitulos_detalle": {
    "01": {
      "estado": "completado",
      "xp_ganado": 100,
      "quiz_resultado": 95,
      "insignia_desbloqueada": true,
      "fecha_completado": "2026-07-07T10:00:00Z"
    }
  },
  "validaciones": {
    "buenas_acciones": 2,
    "noches_campamento": 1,
    "meses_participacion": 2,
    "comportamiento_hogar": {"aprobado": false, "codigo_validacion": null},
    "rendimiento_academico": {"aprobado": false, "codigo_validacion": null}
  },
  "insignias_desbloqueadas": ["🔥 Guardián de la Historia"],
  "morral_coleccionables": []
}
```

---

## ❌ Pendiente — Configuración de credenciales

**ANTES DE EJECUTAR:**

1. Obtener `API_KEY` real de Firebase Console
   - URL: https://console.firebase.google.com/
   - Proyecto: `fichas-actividad-scout`
   - Configuración del proyecto → Tu app → Copiar `apiKey`

2. Actualizar `godot/firebase_config.gd`:
   ```gdscript
   const API_KEY = "AIzaSyD_[TU_API_KEY_REAL]"
   ```

3. Verificar reglas Firestore (Firebase Console → Firestore → Rules):
   - Si está en **modo de prueba** → OK ✓
   - Si tiene reglas, agregar:
   ```
   match /libro_interactivo_progreso/{document=**} {
     allow read: if true;
     allow write: if request.auth == null;
     allow create: if request.resource.data.keys().hasAll(['grupoId', 'scoutId', 'nombre']);
   }
   ```

4. Verificar que la colección `scouts` existe con datos reales
   - Necesita campos: `nombre`, `patrulla` (al menos)
   - Ejemplo: `{"nombre": "Carlos López", "patrulla": "Jaguares", ...}`

---

## Plan de pruebas (QA Phase 7)

### Test 1: Búsqueda fuzzy en login

```
Input: "Carlos Lopez" (sin acento)
DB: "Carlos López" (con acento)
Resultado esperado: ✓ Match encontrado (>80% similitud)
```

### Test 2: Progreso descargado en primer login

```
1. Scout ingresa nombre + patrulla
2. Si NO existe documento progreso en Firestore:
   - Esperado: Se crea automáticamente con xp_total=0, rango=Pietierno
3. Si EXISTE documento progreso:
   - Esperado: Se descarga completo (xp, rango, capítulos, etc.)
```

### Test 3: Sincronización después de quiz

```
1. Scout completa quiz y aprueba
2. XP ganado se suma a GameState.xp
3. Esperado: PATCH a Firestore con xp_total actualizado en <1s
4. Verificar en Firestore Console que xp_total cambió
```

### Test 4: Offline y reconexión

```
1. Scout usa app con conexión OK
2. Completar capítulo → sincronización exitosa
3. Desactivar conexión (DevTools → Network: offline)
4. Scout completa otra actividad
5. Esperado: Cambios en buffer local, "Sincronizando..." mostrado después de 10s
6. Restaurar conexión
7. Esperado: Automático sync, cambios llegan a Firestore
```

### Test 5: Cambio de dispositivo

```
Dispositivo A:
1. Scout login, completa capítulo 1
2. Verificar en Firestore que capitulos_completados = ["01"]

Dispositivo B:
1. Scout login con mismo nombre + patrulla
2. get_scout_progress() descarga capitulos_completados = ["01"]
3. Esperado: Capítulo 1 aparece como completado en mapa
4. Scout completa capítulo 2
5. Guardar → sincroniza capitulos_completados = ["01", "02"]

Dispositivo A:
1. Reabrir app (recarga localStorage)
2. Esperado: Capítulo 2 aparece como completado (sincronizado desde B)
```

---

## Checklist de deployment (antes de fase 8)

- [ ] API_KEY configurada en `godot/firebase_config.gd`
- [ ] Reglas Firestore verificadas/actualizadas
- [ ] Colección `scouts` poblada con datos reales
- [ ] Test 1 — Búsqueda fuzzy PASS
- [ ] Test 2 — Descarga progreso PASS
- [ ] Test 3 — Sync quiz PASS
- [ ] Test 4 — Offline/reconexión PASS
- [ ] Test 5 — Multi-device PASS
- [ ] Web export funcional con persistencia
- [ ] Logs en Output verificados (sin errores)
- [ ] Documentación actualizada con resultados

---

## Próximas fases

### Fase 8: Panel web del dirigente
- Crear componente React `LibroInteractivoProgreso.jsx`
- Leer colección `libro_interactivo_progreso`
- Mostrar tabla: scouts, XP, capítulos, validaciones
- Permitir validar buenas acciones, campamentos, comportamiento

### Fase 9: Notificaciones y validaciones
- Código de validación para buenas acciones
- Sistema de notificaciones push
- Sincronización bidireccional de validaciones

---

## Troubleshooting

| Problema | Causa | Solución |
|----------|-------|----------|
| "Scout no encontrado" | Nombre no es exacto en DB | Verificar nombre en colección `scouts` |
| "Error 404" en descarga | Documento progreso no existe | Normal en primer acceso — se crea automático |
| "cambios no se sincronizan" | API_KEY inválida | Verificar key en firebase_config.gd |
| "Performance lento" | Sync cada 5s es muy frecuente | Aumentar `SYNC_INTERVAL_SECONDS` a 15s |
| "Firestore rechaza request" | Reglas de seguridad restrictivas | Actualizar rules con allow write |

---

## Commits relacionados

- `fc2ea18` — feat: implement Firestore persistence (configuración + core)
- `df606df` — feat: integrate Firebase Firestore sync (escenas + autoloads)

---

## Contact

Documentación técnica:
- `Firebase_Especificacion_Tecnica.md` — Especificación original
- `Firebase_Integracion_Godot.md` — Guía de uso
- `Firebase_Ejemplos_Integracion.gd` — Código ejemplo
- `Firebase_Checklist_Setup.md` — Setup paso a paso

Código:
- `godot/firebase_config.gd` — Configuración
- `godot/scripts/firebase_sync.gd` — Motor de sync
- `godot/scenes/onboarding/onboarding.gd` — Login integration
- `godot/autoload/SaveManager.gd` — Auto-sync hook
