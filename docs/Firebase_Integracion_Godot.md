# Integración Firebase Firestore — Godot Proyecto fichas-actividad-scout

## Estado actual: Implementado para Fase 7

### Archivos creados

1. **`godot/firebase_config.gd`** — Configuración centralizada
   - Credenciales API (obtener de Firebase Console)
   - URLs endpoints Firestore
   - Constantes de sincronización

2. **`godot/scripts/firebase_sync.gd`** — Lógica principal de sincronización
   - `find_scout_in_firestore(nombre, patrulla)` — búsqueda fuzzy 80%
   - `get_scout_progress(grupo_id, scout_id)` — descarga/crea progreso
   - `push_scout_data(updates)` — sincroniza cambios a Firestore
   - Sincronización automática cada 5 segundos
   - Buffer local + reintentos en caso de desconexión

---

## Configuración previa (antes de ejecutar)

### 1. Obtener credenciales Firebase

1. Acceder a: https://console.firebase.google.com/
2. Seleccionar proyecto **fichas-actividad-scout**
3. Ir a **Configuración del proyecto** (⚙️ engranaje)
4. Pestaña **Tu app** → seleccionar app web
5. Copiar:
   - `apiKey`
   - `projectId` (debería ser `fichas-actividad-scout`)
   - `authDomain`

### 2. Actualizar godot/firebase_config.gd

Reemplazar placeholders:

```gdscript
const API_KEY = "AIzaSyD_... [copiar de Firebase Console]"
const AUTH_DOMAIN = "fichas-actividad-scout.firebaseapp.com"
```

### 3. Verificar reglas de Firestore

En Firebase Console → Firestore → Reglas:

Si el proyecto está en **modo de prueba**, está listo (acceso abierto).

Si tiene reglas restrictivas, agregar esta regla para la colección `libro_interactivo_progreso`:

```
match /libro_interactivo_progreso/{document=**} {
  allow read: if true;
  allow write: if request.auth == null;
  allow create: if request.resource.data.keys().hasAll(['grupoId', 'scoutId', 'nombre']);
}
```

---

## Uso en Godot

### 1. Crear instancia de FirebaseSync (Autoload)

En `project.godot`, agregar:

```gdscript
autoload/FirebaseSync="res://scripts/firebase_sync.gd"
```

O crear manualmente en una escena:

```gdscript
var firebase_sync = FirebaseSync.new()
add_child(firebase_sync)
```

### 2. FLUJO DE LOGIN

```gdscript
# En escena de login
func _on_login_button_pressed() -> void:
	var nombre_input = $LineEditNombre.text
	var patrulla_selected = $OptionButtonPatrulla.get_item_text($OptionButtonPatrulla.selected)
	
	# Conectar señales antes de buscar
	FirebaseSync.scout_found.connect(_on_scout_found)
	FirebaseSync.scout_not_found.connect(_on_scout_not_found)
	FirebaseSync.multiple_matches.connect(_on_multiple_matches)
	
	# Iniciar búsqueda fuzzy
	FirebaseSync.find_scout_in_firestore(nombre_input, patrulla_selected)

func _on_scout_found(scout_id: String, name: String, patrol: String) -> void:
	print("✓ Scout encontrado: %s (ID: %s)" % [name, scout_id])
	
	# Descargar progreso
	FirebaseSync.progress_loaded.connect(_on_progress_loaded)
	FirebaseSync.get_scout_progress("127", scout_id)

func _on_progress_loaded(data: Dictionary) -> void:
	print("✓ Progreso cargado para scout")
	# Cargar escena del libro interactivo
	get_tree().change_scene_to_file("res://scenes/libro/libro.tscn")

func _on_scout_not_found(error_message: String) -> void:
	$LabelError.text = error_message
	$LabelError.show()

func _on_multiple_matches(matches: Array[Dictionary]) -> void:
	# Mostrar diálogo con opciones
	$DialogMultipleMatches.clear()
	for match in matches:
		var text = "%s (%.0f%% similitud)" % [match["nombre"], match["similarity"] * 100]
		$DialogMultipleMatches.add_item(text)
	$DialogMultipleMatches.popup_centered_ratio(0.6)
```

### 3. DURANTE EL JUEGO — Sincronizar progreso

Después de cada acción importante (completar escena, quiz, validación):

```gdscript
# Actualizar progreso local y sincronizar
var updates = {
	"xp_total": 450,
	"capitulos_completados": ["01", "02"],
	"validaciones.buenas_acciones": 2
}

FirebaseSync.push_scout_data(updates)

# Conectar para feedback
FirebaseSync.progress_synced.connect(_on_progress_synced)
FirebaseSync.sync_error.connect(_on_sync_error)
FirebaseSync.sync_status_changed.connect(_on_sync_status_changed)

func _on_progress_synced(field: String) -> void:
	print("✓ Campo sincronizado: %s" % field)

func _on_sync_status_changed(syncing: bool) -> void:
	if syncing:
		$LabelSyncStatus.text = "Sincronizando..."
		$LabelSyncStatus.show()
	else:
		$LabelSyncStatus.hide()

func _on_sync_error(error_msg: String) -> void:
	print("⚠ Error de sincronización: %s" % error_msg)
	# App continúa funcionando offline
```

### 4. CAMBIAR DE DISPOSITIVO

Scout ingresa el mismo nombre + patrulla en otro dispositivo:

```
1. Ingresa: "Carlos López" + "Jaguares"
2. find_scout_in_firestore() encuentra su scoutId
3. get_scout_progress() descarga su progreso completo
4. Continúa donde lo dejó ✓
```

---

## Estructura de datos en Firestore

### Colección: `libro_interactivo_progreso`

**Documento ID:** `{grupoId}_{scoutId}` (ej: `127_scout123`)

**Estructura:**

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
    },
    "02": { ... }
  },
  "validaciones": {
    "buenas_acciones": 2,
    "noches_campamento": 1,
    "meses_participacion": 2,
    "comportamiento_hogar": {
      "aprobado": false,
      "codigo_validacion": null,
      "fecha_validacion": null,
      "aprobado_por": null
    },
    "rendimiento_academico": {
      "aprobado": false,
      "codigo_validacion": null,
      "fecha_validacion": null,
      "aprobado_por": null
    }
  },
  "insignias_desbloqueadas": ["🔥 Guardián de la Historia", "⚖️ Guardián de la Ley"],
  "morral_coleccionables": ["brujula_1", "flor_lis_2", ...]
}
```

---

## Señales disponibles

```gdscript
# Búsqueda
signal scout_found(scout_id: String, name: String, patrol: String)
signal scout_not_found(error_message: String)
signal multiple_matches(matches: Array[Dictionary])

# Progreso
signal progress_loaded(data: Dictionary)
signal progress_synced(field: String)

# Sincronización
signal sync_error(error_message: String)
signal sync_status_changed(syncing: bool)  # true = sincronizando, false = listo
```

---

## Manejo offline

- **Sin conexión?** Los cambios se guardan en buffer local (`_pending_sync_buffer`)
- **Reintentos:** Automático cada 5 segundos
- **Feedback:** "Sincronizando..." después de 10 segundos sin conexión
- **Recuperación:** Cuando se restaura conexión, todos los cambios se envían automáticamente

---

## Debugging

Habilitar logging en `godot/scripts/firebase_sync.gd`:

```gdscript
# Ya está incluido en _process_sync_response()
print("[FirebaseSync] Cambios sincronizados a Firestore: %s" % ", ".join(update_keys))
```

Ver logs en Godot Output o en DevTools del navegador (web export).

---

## Próximos pasos (Fase 9)

1. Crear componente React `src/components/LibroInteractivoProgreso.jsx` en app scouts-app
2. Leer colección `libro_interactivo_progreso` desde panel web del dirigente
3. Permitir validación de:
   - Buenas acciones
   - Noches de campamento
   - Comportamiento en el hogar
   - Rendimiento académico

---

## Troubleshooting

### Scout no encontrado (búsqueda fuzzy)

- Verificar que el nombre está exacto en colección `scouts`
- Mínimo 80% de similitud (algoritmo Levenshtein)
- Ejemplo: "Carlos López" vs "Carlos López García" = ~92% similitud ✓

### Error 404 al descargar progreso

- Primer acceso? Normal — se crea documento automáticamente
- Verificar que `grupoId` y `scoutId` son correctos

### Cambios no se sincronizan

- Verificar conexión a internet
- Revisar logs en Output
- Comprobar que API Key es válida en firebase_config.gd
- Revisar reglas de Firestore (debe permitir write sin autenticación)

### Performance

- Sincronización cada 5 segundos es configurable en `FirebaseConfig.SYNC_INTERVAL_SECONDS`
- Para pruebas, aumentar a 15-30 segundos si hay lag
- REST API es suficiente para esta escala (no requiere WebSocket)

---

## Estructura de directorios actual

```
godot/
├── firebase_config.gd          ← Credenciales
├── scripts/
│   └── firebase_sync.gd        ← Lógica principal
├── autoload/
│   ├── GameState.gd
│   ├── SaveManager.gd
│   └── SceneRouter.gd
└── scenes/
    ├── capitulo/
    ├── perfil/
    ├── mapa/
    ├── mecanicas/
    ├── onboarding/
    └── ...
```

Agregar a `project.godist`:

```
[autoload]
FirebaseSync="res://scripts/firebase_sync.gd"
```
