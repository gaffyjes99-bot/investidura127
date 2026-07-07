# Firestore — Integración al Proyecto scouts-app Existente

## Objetivo
Sincronizar el progreso del Libro Interactivo (Godot) con el Firestore existente del proyecto `fichas-actividad-scout`, permitiendo que:
1. El scout cambie de dispositivo y su progreso se restaure automáticamente (sincronización bidireccional).
2. El dirigente vea el progreso del Libro Interactivo en un panel web nuevo (sin tocar el panel de progresión de habilidades existente).

---

## 1. Configuración — Reutilizar Firestore Existente

**NO crear un nuevo proyecto Firebase.** El proyecto `fichas-actividad-scout` (project ID del grupo 127) ya está configurado y funcionando. Se reutiliza directamente.

### 1.1 Obtener credenciales del proyecto existente
1. Acceder a https://console.firebase.google.com/ y seleccionar el proyecto `fichas-actividad-scout`.
2. Ir a **Configuración del proyecto** → **Tu app** → copiar credenciales web:
   - `apiKey`
   - `projectId` (debería ser `fichas-actividad-scout`)
   - `databaseURL` (no aplica, es Firestore, no Realtime DB)
   - `authDomain`

Estos valores irán en el `firebase_config.gd` de Godot, en la sección `[Firestore Web API]`.

---

## 2. Estructura de datos en Firestore (colección nueva)

Se agrega una colección nueva `libro_interactivo_progreso` al proyecto existente `fichas-actividad-scout`. No interfiere con las colecciones actuales (`scouts`, `progresion_scouts`, etc.).

```
Firestore (fichas-actividad-scout)
├── scouts/                    [existente, no tocar]
├── progresion_scouts/         [existente, no tocar]
├── progresiones/              [existente, no tocar]
├── ... [otras colecciones existentes]
└── libro_interactivo_progreso/     [NUEVA — progreso del Libro Interactivo]
    ├── {grupoId}_{scoutId}/    [documento único por scout]
    │   ├── grupoId: "127"
    │   ├── scoutId: "scout123" (ID del scout desde la colección scouts)
    │   ├── nombre: "Carlos"
    │   ├── patrulla: "Jaguares"
    │   ├── creado_en: timestamp
    │   ├── ultima_actualizacion: timestamp
    │   ├── rango: "Aspirante"
    │   ├── xp_total: 450
    │   ├── capitulos_completados: ["01", "02"]
    │   ├── capitulos_detalle: {
    │   │   "01": {
    │   │       estado: "completado",
    │   │       xp_ganado: 100,
    │   │       quiz_resultado: 95,
    │   │       insignia_desbloqueada: true,
    │   │       fecha_completado: timestamp
    │   │   },
    │   │   "02": {...},
    │   │   ...
    │   │ }
    │   ├── validaciones: {
    │   │   buenas_acciones: 2,
    │   │   noches_campamento: 1,
    │   │   meses_participacion: 2,
    │   │   comportamiento_hogar: {
    │   │       aprobado: false,
    │   │       codigo_validacion: null,
    │   │       fecha_validacion: null,
    │   │       aprobado_por: null
    │   │   },
    │   │   rendimiento_academico: {
    │   │       aprobado: false,
    │   │       codigo_validacion: null,
    │   │       fecha_validacion: null,
    │   │       aprobado_por: null
    │   │   }
    │   │ }
    │   ├── insignias_desbloqueadas: ["🔥 Guardián de la Historia", "⚖️ Guardián de la Ley"]
    │   └── morral_coleccionables: ["brujula_1", "flor_lis_2", ...] [24 máximo]
    └── {otro_scout}/
        └── ...
```

**Nota sobre la clave del documento:** usar `{grupoId}_{scoutId}` (ej: `127_scout123`) para poder hacer joins fáciles con la colección `scouts` existente si es necesario después.

---

## 3. Implementación en Godot

### 3.1 Firestore REST API (Godot 4 + HttpRequest nativo)

No se necesita instalar plugins externos. Godot 4 puede hablar con Firestore REST API directamente usando nodos `HttpRequest` nativos.

**Ventajas:**
- Sintaxis simple, nativa de Godot.
- No depende de SDKs externos.
- Suficiente para la sincronización necesaria (cada 5-10 segundos, no requiere WebSocket en tiempo real).

**Endpoint de Firestore REST API:**
```
POST https://firestore.googleapis.com/v1/projects/{projectId}/databases/(default)/documents/libro_interactivo_progreso
GET  https://firestore.googleapis.com/v1/projects/{projectId}/databases/(default)/documents/libro_interactivo_progreso/{documentId}
PATCH https://firestore.googleapis.com/v1/projects/{projectId}/databases/(default)/documents/libro_interactivo_progreso/{documentId}
```

Usa `apiKey` como parámetro de query: `?key={apiKey}`

### 3.2 Flujo de sincronización

**Al iniciar sesión:**
1. Scout ingresa `nombre` (completo, tal como aparece en la colección `scouts`) y elige `patrulla`.
2. Script busca en la colección `scouts` existente usando **búsqueda fuzzy (80% de similitud)** del nombre + filtro por patrulla exacta.
   - Si encuentra una coincidencia: obtiene el `scoutId` de ese documento.
   - Si NO encuentra coincidencia o tiene múltiples resultados (ambigüedad): mostrar mensaje "Scout no encontrado" o "Coincidencias múltiples, intenta con el nombre completo" — NO crear documento nuevo.
3. Una vez identificado el scoutId (ej: `scout123`), construye documentId `{grupoId}_{scoutId}` (ej: `127_scout123`).
4. HttpRequest GET a `https://firestore.googleapis.com/v1/projects/fichas-actividad-scout/databases/(default)/documents/libro_interactivo_progreso/{documentId}?key={apiKey}` para descargar su progreso.
5. Si el documento de progreso NO existe (primer acceso al Libro Interactivo), crea un documento nuevo en Firestore con valores por defecto (XP=0, rango=Pietierno, etc.), usando el scoutId validado.
6. Carga los datos en memoria (variables locales del scout).

**Después de cada acción (completar escena, pasar quiz, validación):**
1. Actualiza la variable local en Godot.
2. HttpRequest PATCH para sincronizar el campo cambiado a Firestore (ej: `xp_total`, `capitulos.01.estado`, `validaciones.buenas_acciones`).
3. Si hay conexión, se sincroniza. Si no hay conexión, se guarda localmente en un buffer y se intenta sincronizar cada 5 segundos.
4. La app muestra un icono de "sincronizando" si hay cambios pendientes.

**Al cambiar de dispositivo:**
1. Scout abre la app en un dispositivo nuevo.
2. Ingresa el mismo `nombre` y `patrulla`.
3. La app busca su documentId en Firestore y descarga su progreso completo.
4. Continúa donde lo dejó, con todos los capítulos y validaciones intactos.

---

## 4. Reglas de seguridad de Firestore (después de la Fase 7)

**IMPORTANTE:** Verificar si el proyecto `fichas-actividad-scout` tiene reglas de seguridad activadas o está en modo de prueba.

Si el proyecto está en **modo de prueba** (acceso abierto), la app Godot puede escribir sin problemas. Si hay reglas restrictivas, pedir al admin del proyecto que agregue estas reglas a la colección `libro_interactivo_progreso`:

```
match /libro_interactivo_progreso/{document=**} {
  allow read: if true;                              // Cualquiera puede leer
  allow write: if request.auth == null;             // Solo sin autenticación (app Godot)
  allow create: if request.resource.data.keys().hasAll(['grupoId', 'scoutId', 'nombre']);
  allow update: if true;                            // Actualizar campo por campo
}
```

(Los scouts no se autentican en Firestore — la app escribe con `request.auth == null` — así que las reglas deben permitir escritura sin credenciales.)

---

## 5. Panel web del dirigente (Fase 9)

Se agrega un nuevo componente React a la app scouts-app existente (`src/components/LibroInteractivoProgreso.jsx`) que:

**Funcionalidad:**
- Muestra tabla de scouts (nombre, patrulla, XP, capítulos completados, validaciones pendientes).
- Filtra por patrulla.
- Permite al dirigente generar/validar códigos para:
  - Buenas acciones (valida en Firestore `validaciones.buenas_acciones`)
  - Noches de campamento (valida en `validaciones.noches_campamento`)
  - Comportamiento en el hogar (código de padres)
  - Rendimiento académico (código de dirigente)
- El código se genera y se registra en Firestore bajo el documento del scout.
- El scout recibe la validación en el siguiente sincronismo (cada 5-10 segundos).

**Integración:**
- Reutiliza el hook `useGrupo()` existente para obtener lista de scouts.
- Lee de la colección `libro_interactivo_progreso` en Firestore.
- Se agrega a `App.jsx` como una ruta nueva (ej: `/libro-interactivo`).

---

## 6. Instrucciones para Claude Code

### Antes de Fase 7:
1. Obtener credenciales del proyecto `fichas-actividad-scout`:
   - `apiKey`
   - `projectId` = `fichas-actividad-scout`
   - Guardarlas en `godot/firebase_config.gd`

2. Crear script `godot/scripts/firebase_sync.gd` con funciones:
   - `find_scout_in_firestore(nombre_input, patrulla)` — **búsqueda fuzzy** en colección `scouts`:
     * Descarga todos los scouts de la patrulla ingresada
     * Usa algoritmo de similitud (Levenshtein o similar) para encontrar coincidencia ≥80% del nombre
     * Si encuentra 1 coincidencia exacta: retorna scoutId
     * Si encuentra múltiples coincidencias: retorna lista para que el usuario confirme
     * Si NO encuentra: retorna null y muestra mensaje "Scout no encontrado en esa patrulla"
   - `get_scout_progress(grupoId, scoutId)` — descarga progreso de `libro_interactivo_progreso` usando el scoutId validado. Si no existe, crea documento nuevo.
   - `push_scout_data(grupoId, scoutId, datos_a_actualizar)` — envía cambios a Firestore usando REST API.
   - `sync_on_interval()` — intenta sincronizar cada 5 segundos si hay cambios locales pendientes.

3. Endpoint de Firestore REST API a usar:
   - GET/PATCH: `https://firestore.googleapis.com/v1/projects/fichas-actividad-scout/databases/(default)/documents/libro_interactivo_progreso/{documentId}?key={apiKey}`

### Durante Fase 7:
- **Login:** 
  * Scout ingresa nombre completo + elige patrulla
  * Llamar a `find_scout_in_firestore(nombre, patrulla)` — búsqueda fuzzy 80% similitud en colección `scouts`
  * Si encuentra coincidencia: obtener scoutId, llamar a `get_scout_progress(grupoId, scoutId)`
  * Si NO encuentra: mostrar mensaje de error, permitir reintentar con otro nombre
  * Si hay múltiples coincidencias: mostrar lista para que confirm cuál es él
- **Durante juego:**
  * Cada vez que el scout completa una escena, quiz o actividad validada, llamar a `push_scout_data()` para actualizar Firestore.
  * El game loop debe llamar a `sync_on_interval()` regularmente (cada 5 segundos) para mantener sincronización en segundo plano.
  * Manejar pérdida de conexión: mostrar icono de "sincronizando..." si hay cambios pendientes >10 segundos, pero la app sigue funcionando localmente.
  * Guardar progreso localmente (en memoria o en archivo) en caso de que Firestore no esté disponible.

### Después de Fase 7 (Fase 9):
- Crear componente React `src/components/LibroInteractivoProgreso.jsx` en la app scouts-app existente.
- El componente lee de `libro_interactivo_progreso` en Firestore y muestra tabla de scouts con su progreso.
- Permite al dirigente emitir códigos de validación.
- Se integra en `App.jsx` como nueva ruta `/libro-interactivo`.

---

## 7. Nota de privacidad

- La colección `libro_interactivo_progreso` contiene **solo progreso educativo** (capítulos completados, XP, insignias, validaciones).
- NO contiene datos personales sensibles (no email, teléfono, dirección, documento, foto, etc. — eso ya está en `scouts`).
- Datos alojados en Google Cloud Platform (Firestore de Google).
- Sujeto a Privacy Policy de Google y Terms of Service de Firebase.
- El proyecto `fichas-actividad-scout` ya está sujeto a estos términos — la colección nueva es solo una extensión del mismo proyecto.
