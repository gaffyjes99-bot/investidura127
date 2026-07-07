# ============================================================================
# EJEMPLOS DE INTEGRACIÓN — Firebase Firestore con Godot
# Proyecto: fichas-actividad-scout (Grupo 127)
#
# Copiar fragmentos según sea necesario en tus escenas
# ============================================================================

# ============================================================================
# ESCENA: OnBoarding / Login
# Archivo: godot/scenes/onboarding/onboarding.gd
# ============================================================================

extends Control

@onready var input_nombre = $VBoxContainer/LineEditNombre
@onready var option_patrulla = $VBoxContainer/OptionButtonPatrulla
@onready var label_error = $VBoxContainer/LabelError
@onready var button_login = $VBoxContainer/ButtonLogin
@onready var label_loading = $VBoxContainer/LabelLoading

var _syncing: bool = false

func _ready() -> void:
	# Conectar señales del FirebaseSync
	FirebaseSync.scout_found.connect(_on_scout_found)
	FirebaseSync.scout_not_found.connect(_on_scout_not_found)
	FirebaseSync.multiple_matches.connect(_on_multiple_matches)
	FirebaseSync.progress_loaded.connect(_on_progress_loaded)
	FirebaseSync.sync_error.connect(_on_sync_error)
	FirebaseSync.sync_status_changed.connect(_on_sync_status_changed)

	# Llenar patrullas (obtener de una lista global o de Firebase)
	var patrullas = ["Jaguares", "Pumas", "Serpientes", "Águilas"]
	for patrulla in patrullas:
		option_patrulla.add_item(patrulla)

	label_error.hide()
	label_loading.hide()
	button_login.pressed.connect(_on_login_pressed)

func _on_login_pressed() -> void:
	var nombre = input_nombre.text.strip_edges()
	var patrulla = option_patrulla.get_item_text(option_patrulla.selected)

	if nombre.is_empty():
		_show_error("Por favor, ingresa tu nombre completo")
		return

	if patrulla.is_empty():
		_show_error("Por favor, selecciona tu patrulla")
		return

	# Iniciar búsqueda
	label_loading.text = "Buscando scout..."
	label_loading.show()
	button_login.disabled = true

	FirebaseSync.find_scout_in_firestore(nombre, patrulla)

func _on_scout_found(scout_id: String, name: String, patrol: String) -> void:
	label_loading.text = "Cargando progreso..."
	# Descargar progreso
	FirebaseSync.get_scout_progress("127", scout_id)

func _on_scout_not_found(error_message: String) -> void:
	_show_error(error_message)
	button_login.disabled = false
	label_loading.hide()

func _on_multiple_matches(matches: Array[Dictionary]) -> void:
	# Mostrar diálogo con opciones de scouts similares
	var dialog = ConfirmationDialog.new()
	dialog.title = "Múltiples coincidencias"
	dialog.dialog_text = "Se encontraron varios scouts similares. Elige cuál eres tú:"

	var item_list = ItemList.new()
	for match in matches:
		var text = "%s (%.0f%% similitud)" % [match["nombre"], match["similarity"] * 100]
		item_list.add_item(text)

	dialog.add_child(item_list)
	add_child(dialog)

	dialog.confirmed.connect(func():
		var idx = item_list.get_selected_items()[0]
		if idx >= 0:
			var selected_match = matches[idx]
			FirebaseSync._current_scout_id = selected_match["scout_id"]
			FirebaseSync.get_scout_progress("127", selected_match["scout_id"])
	)

	dialog.popup_centered_ratio(0.6)

func _on_progress_loaded(data: Dictionary) -> void:
	label_loading.text = "✓ Progreso cargado"
	await get_tree().create_timer(1.0).timeout

	# Guardar scout_id en singleton para acceso global
	GameState.current_scout_id = FirebaseSync.get_current_scout_id()
	GameState.scout_progress = data

	# Cambiar a escena principal del libro
	get_tree().change_scene_to_file("res://scenes/libro/libro.tscn")

func _on_sync_error(error_msg: String) -> void:
	_show_error("Error de sincronización: %s" % error_msg)
	button_login.disabled = false
	label_loading.hide()

func _on_sync_status_changed(syncing: bool) -> void:
	_syncing = syncing
	if syncing:
		label_loading.show()
	else:
		label_loading.hide()

func _show_error(message: String) -> void:
	label_error.text = message
	label_error.show()
	await get_tree().create_timer(4.0).timeout
	label_error.hide()

# ============================================================================
# ESCENA: Libro Interactivo Principal
# Archivo: godot/scenes/libro/libro.gd
# ============================================================================

extends Control

@onready var label_sync_status = $VBoxContainer/LabelSyncStatus
@onready var label_xp = $VBoxContainer/LabelXP
@onready var progress_bar_sync = $VBoxContainer/ProgressBarSync

var _current_xp: int = 0
var _last_sync_time: float = 0.0

func _ready() -> void:
	# Conectar señales de sincronización
	FirebaseSync.progress_synced.connect(_on_field_synced)
	FirebaseSync.sync_error.connect(_on_sync_error)
	FirebaseSync.sync_status_changed.connect(_on_sync_status_changed)

	# Cargar progreso actual en memoria
	var progress = FirebaseSync.get_local_progress()
	_current_xp = int(progress.get("xp_total", 0))
	_update_ui()

func _process(delta: float) -> void:
	# Verificar estado de sincronización periódicamente
	_last_sync_time += delta

func _on_chapter_completed(chapter_id: String, xp_gained: int) -> void:
	"""Llamar cuando el scout completa un capítulo."""
	print("Capítulo %s completado. XP ganado: %d" % [chapter_id, xp_gained])

	_current_xp += xp_gained

	# Preparar datos para sincronizar
	var updates = {
		"xp_total": _current_xp,
		"ultima_actualizacion": Time.get_ticks_msec()
	}

	# Actualizar array de capítulos completados
	var progress = FirebaseSync.get_local_progress()
	var completed = progress.get("capitulos_completados", []) as Array
	if not completed.has(chapter_id):
		completed.append(chapter_id)
		updates["capitulos_completados"] = completed

	# Sincronizar a Firestore
	FirebaseSync.push_scout_data(updates)
	_update_ui()

func _on_quiz_completed(chapter_id: String, score: int, xp_earned: int) -> void:
	"""Llamar cuando el scout completa un quiz."""
	print("Quiz capítulo %s completado con score: %d%%" % [chapter_id, score])

	_current_xp += xp_earned

	var updates = {
		"xp_total": _current_xp,
		"capitulos_detalle.%s.estado" % chapter_id: "completado",
		"capitulos_detalle.%s.quiz_resultado" % chapter_id: score,
		"capitulos_detalle.%s.xp_ganado" % chapter_id: xp_earned
	}

	if score >= 80:  # Insignia desbloqueada si score >= 80
		updates["capitulos_detalle.%s.insignia_desbloqueada" % chapter_id] = true

	FirebaseSync.push_scout_data(updates)
	_update_ui()

func _on_validation_approved(validation_type: String, count: int) -> void:
	"""Llamar cuando se valida una buena acción, noche de campamento, etc."""
	print("Validación '%s' aprobada: %d" % [validation_type, count])

	var updates = {
		"validaciones.%s" % validation_type: count
	}

	FirebaseSync.push_scout_data(updates)

func _on_field_synced(field: String) -> void:
	print("✓ Campo sincronizado: %s" % field)
	# Opcional: animación de feedback

func _on_sync_error(error_msg: String) -> void:
	print("⚠ Error de sincronización: %s" % error_msg)
	label_sync_status.text = "⚠ Error de conexión — trabajando offline"
	label_sync_status.show()

func _on_sync_status_changed(syncing: bool) -> void:
	if syncing:
		label_sync_status.text = "Sincronizando con servidor..."
		label_sync_status.show()
		progress_bar_sync.show()
	else:
		label_sync_status.hide()
		progress_bar_sync.hide()

func _update_ui() -> void:
	label_xp.text = "XP: %d" % _current_xp

	# Actualizar barra de sincronización si hay cambios pendientes
	if FirebaseSync.has_pending_sync():
		progress_bar_sync.value = FirebaseSync._pending_sync_buffer.size() * 20.0
	else:
		progress_bar_sync.value = 100.0

# ============================================================================
# AUTOLOAD: GameState.gd
# Archivo: godot/autoload/GameState.gd
# ============================================================================

extends Node

var current_scout_id: String = ""
var scout_progress: Dictionary = {}
var current_grupo_id: String = "127"

func get_xp_total() -> int:
	return int(scout_progress.get("xp_total", 0))

func get_chapters_completed() -> Array:
	return scout_progress.get("capitulos_completados", []) as Array

func get_rank() -> String:
	return scout_progress.get("rango", "Pietierno")

func get_validations() -> Dictionary:
	return scout_progress.get("validaciones", {}) as Dictionary

func add_xp(amount: int) -> void:
	scout_progress["xp_total"] = get_xp_total() + amount
	FirebaseSync.push_scout_data({"xp_total": scout_progress["xp_total"]})

func unlock_badge(badge_name: String) -> void:
	var badges = scout_progress.get("insignias_desbloqueadas", []) as Array
	if not badges.has(badge_name):
		badges.append(badge_name)
		scout_progress["insignias_desbloqueadas"] = badges
		FirebaseSync.push_scout_data({"insignias_desbloqueadas": badges})

# ============================================================================
# ESCENA: Quiz
# Archivo: godot/scenes/mecanicas/quiz.gd
# Fragmento a agregar
# ============================================================================

func _on_quiz_finished() -> void:
	var score = calculate_score()
	var xp_earned = int(score / 10)  # 100% = 10 XP, etc.

	# Notificar al libro sobre la finalización del quiz
	get_tree().root.get_child(0).call_deferred("_on_quiz_completed", chapter_id, score, xp_earned)

# ============================================================================
# EJEMPLO: Detectar cambio de dispositivo
# Cualquier escena puede verificar periódicamente si hay datos más nuevos
# ============================================================================

func check_for_remote_updates() -> void:
	"""
	Llamar periódicamente para verificar si el scout fue sincronizado en otro dispositivo.
	Útil si dejas la app abierta mientras cambias a otro dispositivo.
	"""
	var current_scout = FirebaseSync.get_current_scout_id()
	if current_scout.is_empty():
		return

	# Descargar progreso nuevamente
	FirebaseSync.get_scout_progress(GameState.current_grupo_id, current_scout)

	# La señal progress_loaded se emitirá si hay cambios
	FirebaseSync.progress_loaded.connect(_on_remote_update)

func _on_remote_update(new_data: Dictionary) -> void:
	"""Si el progreso cambió en otro dispositivo."""
	# Mostrar diálogo de sincronización
	var dialog = AcceptDialog.new()
	dialog.title = "Actualización remota detectada"
	dialog.dialog_text = "Tu progreso se sincronizó desde otro dispositivo. Recargando..."
	add_child(dialog)
	dialog.popup_centered_ratio(0.5)

	await dialog.confirmed
	get_tree().reload_current_scene()
