extends Control

const PATRULLAS := ["Jaguares", "Lobos", "Mapaches", "Pandas"]

@onready var nombre_input:  LineEdit = $VBox/NombreInput
@onready var boton_iniciar: Button   = $VBox/BotonIniciar
@onready var error_label:   Label    = $VBox/ErrorLabel
@onready var btn_jaguares:  Button   = $VBox/PatrullasGrid/BtnJaguares
@onready var btn_lobos:     Button   = $VBox/PatrullasGrid/BtnLobos
@onready var btn_mapaches:  Button   = $VBox/PatrullasGrid/BtnMapaches
@onready var btn_pandas:    Button   = $VBox/PatrullasGrid/BtnPandas

var _patrulla_idx: int = -1
var _syncing: bool = false

func _ready() -> void:
	print("onboarding _ready START")
	btn_jaguares.pressed.connect(func(): _sel(0))
	btn_lobos.pressed.connect(func(): _sel(1))
	btn_mapaches.pressed.connect(func(): _sel(2))
	btn_pandas.pressed.connect(func(): _sel(3))
	boton_iniciar.pressed.connect(_on_iniciar)
	nombre_input.text_changed.connect(_on_nombre_cambiado)
	error_label.visible = false

	# Conectar señales de Firebase (sincronización con Firestore)
	if FirebaseSync:
		FirebaseSync.scout_found.connect(_on_scout_found)
		FirebaseSync.scout_not_found.connect(_on_scout_not_found)
		FirebaseSync.multiple_matches.connect(_on_multiple_matches)
		FirebaseSync.progress_loaded.connect(_on_progress_loaded)
		FirebaseSync.sync_error.connect(_on_sync_error)

	print("onboarding _ready DONE")

func _on_nombre_cambiado(_t: String) -> void:
	_check()

func _sel(idx: int) -> void:
	print("patrulla idx=", idx)
	_patrulla_idx = idx
	btn_jaguares.modulate = Color(0.3, 1.0, 0.4) if idx == 0 else Color(1, 1, 1)
	btn_lobos.modulate    = Color(0.3, 1.0, 0.4) if idx == 1 else Color(1, 1, 1)
	btn_mapaches.modulate = Color(0.3, 1.0, 0.4) if idx == 2 else Color(1, 1, 1)
	btn_pandas.modulate   = Color(0.3, 1.0, 0.4) if idx == 3 else Color(1, 1, 1)
	_check()

func _check() -> void:
	var ok := nombre_input.text.strip_edges().length() >= 2 and _patrulla_idx >= 0
	boton_iniciar.disabled = not ok or _syncing

func _on_iniciar() -> void:
	var nombre := nombre_input.text.strip_edges()
	if nombre.length() < 2 or _patrulla_idx < 0:
		_show_error("Completa nombre y patrulla")
		return

	_syncing = true
	boton_iniciar.disabled = true
	error_label.text = "Validando scout..."
	error_label.modulate.a = 1.0  # normal (no es error)
	error_label.visible = true

	# Búsqueda fuzzy en Firestore (colección scouts)
	var patrulla = PATRULLAS[_patrulla_idx]
	print("Iniciando búsqueda: nombre='%s', patrulla='%s'" % [nombre, patrulla])
	FirebaseSync.find_scout_in_firestore(nombre, patrulla)

func _on_scout_found(scout_id: String, name: String, patrol: String) -> void:
	print("✓ Scout encontrado: %s (ID: %s)" % [name, scout_id])
	error_label.text = "Descargando progreso..."
	error_label.visible = true

	# Descargar progreso desde Firestore
	FirebaseSync.get_scout_progress("127", scout_id)

func _on_scout_not_found(error_message: String) -> void:
	_show_error(error_message)
	_syncing = false
	boton_iniciar.disabled = false

func _on_multiple_matches(matches: Array[Dictionary]) -> void:
	# Mostrar lista de coincidencias para que el usuario elija
	error_label.text = "Se encontraron múltiples scouts similares"
	error_label.modulate.a = 0.7  # warning
	error_label.visible = true

	# TODO: Mostrar diálogo con opciones
	_show_error("Se encontraron múltiples scouts. Intenta con el nombre completo.")
	_syncing = false
	boton_iniciar.disabled = false

func _on_progress_loaded(data: Dictionary) -> void:
	print("✓ Progreso cargado desde Firestore")

	# Cargar datos en GameState
	var nombre = nombre_input.text.strip_edges()
	var patrulla = PATRULLAS[_patrulla_idx]

	GameState.nombre_scout = nombre
	GameState.patrulla = patrulla
	GameState.scout_id = FirebaseSync.get_current_scout_id()

	# Desempacar datos de Firestore en formato local
	_cargar_progreso_firestore(data)

	# Guardar en localStorage (backup local)
	SaveManager.guardar()

	error_label.text = "✓ ¡Bienvenido de vuelta!"
	error_label.modulate.a = 1.0
	await get_tree().create_timer(1.0).timeout
	error_label.visible = false

	# Cambiar a mapa
	SceneRouter.ir_a("mapa")

func _on_sync_error(error_msg: String) -> void:
	print("⚠ Error de sincronización: %s" % error_msg)
	_show_error("Error de conexión: %s" % error_msg)
	_syncing = false
	boton_iniciar.disabled = false

func _cargar_progreso_firestore(firestore_data: Dictionary) -> void:
	"""Desempaca datos de Firestore al formato de GameState."""
	# Firestore devuelve datos en formato {"fields": {...}}
	var fields = firestore_data.get("fields", {})

	# Extraer valores usando helper
	GameState.xp = _get_int_field(fields, "xp_total", 0)
	GameState.rango = _get_string_field(fields, "rango", "Pietierno")

	# Capítulos completados
	var cap_array = _get_array_field(fields, "capitulos_completados", [])
	GameState.capitulos_completados.clear()
	for cap_id in cap_array:
		if cap_id is String:
			GameState.capitulos_completados.append(int(cap_id))
		else:
			GameState.capitulos_completados.append(cap_id as int)

	# Insignias desbloqueadas
	var insig_array = _get_array_field(fields, "insignias_desbloqueadas", [])
	GameState.insignias.clear()
	for insig in insig_array:
		if insig is String:
			GameState.insignias.append(int(insig))
		else:
			GameState.insignias.append(insig as int)

	print("Progreso cargado: XP=%d, Rango=%s, Capítulos=%s, Insignias=%s" % [
		GameState.xp, GameState.rango, GameState.capitulos_completados, GameState.insignias
	])

func _get_string_field(fields: Dictionary, field_name: String, default: String = "") -> String:
	if fields.has(field_name) and fields[field_name].has("stringValue"):
		return fields[field_name]["stringValue"]
	return default

func _get_int_field(fields: Dictionary, field_name: String, default: int = 0) -> int:
	if fields.has(field_name) and fields[field_name].has("integerValue"):
		return int(fields[field_name]["integerValue"])
	return default

func _get_array_field(fields: Dictionary, field_name: String, default: Array = []) -> Array:
	if fields.has(field_name) and fields[field_name].has("arrayValue"):
		var arr = fields[field_name]["arrayValue"].get("values", [])
		return arr if arr is Array else default
	return default

func _show_error(message: String) -> void:
	error_label.text = message
	error_label.modulate.a = 0.8  # rojo/error
	error_label.visible = true
	await get_tree().create_timer(4.0).timeout
	if error_label.visible:
		error_label.visible = false
