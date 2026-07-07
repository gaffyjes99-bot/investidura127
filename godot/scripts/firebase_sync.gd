extends Node

# ============================================================================
# Firebase Sync — Persistencia de progreso en Firestore REST API
# Proyecto: fichas-actividad-scout (Grupo 127)
# ============================================================================

class_name FirebaseSync

signal scout_found(scout_id: String, name: String, patrol: String)
signal scout_not_found(error_message: String)
signal multiple_matches(matches: Array[Dictionary])
signal progress_loaded(data: Dictionary)
signal progress_synced(field: String)
signal sync_error(error_message: String)
signal sync_status_changed(syncing: bool)

# Estado local del scout
var _current_scout_id: String = ""
var _current_grupo_id: String = FirebaseConfig.GRUPO_ID
var _local_progress: Dictionary = {}
var _pending_sync_buffer: Dictionary = {}  # Cambios pendientes
var _sync_in_progress: bool = false
var _last_sync_time: float = 0.0
var _sync_error_count: int = 0

# HttpRequest nodes
var _http_get: HttpRequest
var _http_patch: HttpRequest
var _http_post: HttpRequest

# Timers
var _sync_timer: Timer

func _ready() -> void:
	_http_get = HttpRequest.new()
	add_child(_http_get)
	_http_get.request_completed.connect(_on_http_request_completed.bind(_http_get))

	_http_patch = HttpRequest.new()
	add_child(_http_patch)
	_http_patch.request_completed.connect(_on_http_request_completed.bind(_http_patch))

	_http_post = HttpRequest.new()
	add_child(_http_post)
	_http_post.request_completed.connect(_on_http_request_completed.bind(_http_post))

	# Timer para sincronización periódica
	_sync_timer = Timer.new()
	add_child(_sync_timer)
	_sync_timer.timeout.connect(_on_sync_timer_timeout)
	_sync_timer.wait_time = FirebaseConfig.SYNC_INTERVAL_SECONDS
	_sync_timer.start()

# ============================================================================
# BÚSQUEDA FUZZY DE SCOUTS — Levenshtein distance 80% similitud mínima
# ============================================================================

func find_scout_in_firestore(nombre_input: String, patrulla: String) -> void:
	"""
	Busca scout usando Cloud Function (backend seguro).
	La búsqueda fuzzy se hace en servidor, protegiendo datos personales.
	Emite: scout_found, scout_not_found, multiple_matches
	"""
	if nombre_input.is_empty() or patrulla.is_empty():
		emit_signal("scout_not_found", "Nombre y patrulla requeridos")
		return

	# Endpoint del Cloud Function
	var cloud_function_url = "https://us-central1-fichas-actividad-scout.cloudfunctions.net/findScout"

	# Preparar body con nombre y patrulla
	var body = JSON.stringify({
		"nombre": nombre_input.strip_edges(),
		"patrulla": patrulla
	})

	var headers = PackedStringArray(["Content-Type: application/json"])

	_http_post.request(
		cloud_function_url,
		headers,
		HttpClient.METHOD_POST,
		body
	)
	_http_post.set_meta("operation", "find_scout_cloud")

func _process_find_scout_cloud_response(response_body: String) -> void:
	"""Procesa respuesta del Cloud Function findScout."""
	if response_body.is_empty():
		emit_signal("scout_not_found", "Error: respuesta vacía del servidor")
		return

	var json = JSON.new()
	if json.parse(response_body) != OK:
		emit_signal("scout_not_found", "Error: respuesta JSON inválida")
		return

	var data = json.data

	# Verificar si hay error
	if data.has("error"):
		var error_code = data.get("code", "UNKNOWN")
		var error_msg = data.get("error", "Error desconocido")

		match error_code:
			"MULTIPLE_MATCHES":
				# Múltiples coincidencias
				var matches = data.get("matches", []) as Array
				emit_signal("multiple_matches", matches)
			_:
				# Otros errores (SCOUT_NOT_FOUND, PATRULLA_NOT_FOUND, etc.)
				emit_signal("scout_not_found", error_msg)
		return

	# Éxito: scout encontrado
	_current_scout_id = data.get("scoutId", "")
	var nombre = data.get("nombre", "")
	var patrulla = data.get("patrulla", "")

	emit_signal("scout_found", _current_scout_id, nombre, patrulla)

# ============================================================================
# DESCARGA/CREA PROGRESO DEL SCOUT
# ============================================================================

func get_scout_progress(grupo_id: String, scout_id: String) -> void:
	"""
	Descarga progreso del scout desde Firestore.
	Si no existe (primer acceso), crea documento con valores por defecto.
	"""
	_current_scout_id = scout_id
	_current_grupo_id = grupo_id

	var doc_id = "%s_%s" % [grupo_id, scout_id]
	var endpoint = FirebaseConfig.get_progreso_endpoint(doc_id)

	_http_get.request(
		endpoint,
		PackedStringArray(),
		HttpClient.METHOD_GET
	)
	_http_get.set_meta("operation", "get_progress")
	_http_get.set_meta("scout_id", scout_id)
	_http_get.set_meta("grupo_id", grupo_id)

func _process_get_progress_response(response_body: String, scout_id: String, grupo_id: String) -> void:
	"""Procesa respuesta de progreso. Si no existe, crea documento."""
	if response_body.is_empty():
		# Probablemente no existe el documento
		_create_default_progress(scout_id, grupo_id)
		return

	var json = JSON.new()
	if json.parse(response_body) != OK:
		_create_default_progress(scout_id, grupo_id)
		return

	var data = json.data

	# Verificar si es error 404 (not found)
	if data.has("error"):
		if data["error"].get("code", 0) == 404:
			_create_default_progress(scout_id, grupo_id)
		else:
			emit_signal("sync_error", "Error al descargar progreso: %s" % data["error"].get("message", ""))
		return

	# Éxito — cargar datos en memoria
	_local_progress = data
	emit_signal("progress_loaded", _local_progress)

func _create_default_progress(scout_id: String, grupo_id: String) -> void:
	"""Crea documento nuevo en Firestore con valores por defecto."""
	# Necesitamos nombre y patrulla — asumir que ya fueron capturados en UI
	# Para esta implementación, usamos valores mínimos (se actualizarán después)
	var doc_id = "%s_%s" % [grupo_id, scout_id]
	var endpoint = "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/%s?key=%s" % [
		FirebaseConfig.PROJECT_ID,
		"%s/%s" % [FirebaseConfig.FIRESTORE_PROGRESO_COLLECTION, doc_id],
		FirebaseConfig.API_KEY
	]

	var default_data = FirebaseConfig.get_default_progress_data(scout_id, "", "")

	var headers = PackedStringArray([
		"Content-Type: application/json"
	])

	var json_body = JSON.stringify(default_data)
	_http_post.request(
		endpoint,
		headers,
		HttpClient.METHOD_POST,
		json_body
	)
	_http_post.set_meta("operation", "create_progress")
	_http_post.set_meta("scout_id", scout_id)

# ============================================================================
# SINCRONIZACIÓN DE CAMBIOS A FIRESTORE
# ============================================================================

func push_scout_data(updates: Dictionary) -> void:
	"""
	Registra cambios locales y los agrega al buffer de sincronización.
	Intenta sincronizar inmediatamente si hay conexión.
	Si no, se sincronizará periódicamente (cada 5 segundos).
	"""
	if _current_scout_id.is_empty():
		emit_signal("sync_error", "Scout no identificado")
		return

	# Actualizar buffer local
	for key in updates.keys():
		_pending_sync_buffer[key] = updates[key]
		# Actualizar también en _local_progress
		_local_progress[key] = updates[key]

	# Intentar sincronizar
	_try_sync()

func _try_sync() -> void:
	"""Intenta sincronizar cambios pendientes a Firestore."""
	if _pending_sync_buffer.is_empty():
		return

	if _sync_in_progress:
		return  # Ya hay sincronización en progreso

	emit_signal("sync_status_changed", true)
	_sync_in_progress = true
	_last_sync_time = Time.get_ticks_msec() / 1000.0

	var doc_id = "%s_%s" % [_current_grupo_id, _current_scout_id]
	var endpoint = FirebaseConfig.get_progreso_endpoint(doc_id)

	# Convertir cambios locales a formato Firestore
	var firestore_updates = {"fields": {}}
	for key in _pending_sync_buffer.keys():
		firestore_updates["fields"][key] = _convert_to_firestore_format(_pending_sync_buffer[key])

	var headers = PackedStringArray([
		"Content-Type: application/json"
	])

	var json_body = JSON.stringify(firestore_updates)
	_http_patch.request(
		endpoint,
		headers,
		HttpClient.METHOD_PATCH,
		json_body
	)
	_http_patch.set_meta("operation", "sync_progress")
	_http_patch.set_meta("update_keys", _pending_sync_buffer.keys())

# ============================================================================
# MANEJADORES DE RESPUESTAS HTTP
# ============================================================================

func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_node: HttpRequest) -> void:
	var response_body = body.get_string_from_utf8()
	var operation = http_node.get_meta("operation", "")

	if result != HTTPRequest.RESULT_SUCCESS:
		_handle_http_error(result, operation)
		return

	if response_code >= 400:
		_handle_http_error_code(response_code, response_body, operation)
		return

	# Resetear contador de errores en éxito
	_sync_error_count = 0

	# Procesar según operación
	match operation:
		"find_scout_cloud":
			_process_find_scout_cloud_response(response_body)
		"get_progress":
			var scout_id = http_node.get_meta("scout_id", "")
			var grupo_id = http_node.get_meta("grupo_id", "")
			_process_get_progress_response(response_body, scout_id, grupo_id)
		"sync_progress":
			_process_sync_response(response_body, http_node.get_meta("update_keys", []))
		"create_progress":
			_process_create_progress_response(response_body, http_node.get_meta("scout_id", ""))

	_sync_in_progress = false
	emit_signal("sync_status_changed", false)

func _handle_http_error(result: int, operation: String) -> void:
	_sync_error_count += 1
	var error_msg = "Error de conexión: %d (operación: %s)" % [result, operation]
	emit_signal("sync_error", error_msg)
	emit_signal("sync_status_changed", false)
	_sync_in_progress = false

func _handle_http_error_code(response_code: int, response_body: String, operation: String) -> void:
	_sync_error_count += 1
	var error_msg = "Servidor respondió: %d" % response_code

	if not response_body.is_empty():
		var json = JSON.new()
		if json.parse(response_body) == OK:
			var data = json.data
			if data.has("error"):
				error_msg = data["error"].get("message", error_msg)

	emit_signal("sync_error", error_msg)
	emit_signal("sync_status_changed", false)
	_sync_in_progress = false

func _process_sync_response(response_body: String, update_keys: Array) -> void:
	"""Procesa respuesta de sincronización PATCH."""
	# Si llegamos aquí, la sincronización fue exitosa
	_pending_sync_buffer.clear()

	for key in update_keys:
		emit_signal("progress_synced", key)

	# Log de sincronización exitosa
	print("[FirebaseSync] Cambios sincronizados a Firestore: %s" % ", ".join(update_keys as Array[String]))

func _process_create_progress_response(response_body: String, scout_id: String) -> void:
	"""Procesa respuesta de creación de documento."""
	if response_body.is_empty():
		emit_signal("sync_error", "Error al crear documento de progreso")
		return

	var json = JSON.new()
	if json.parse(response_body) != OK:
		emit_signal("sync_error", "Respuesta JSON inválida al crear progreso")
		return

	_local_progress = json.data
	emit_signal("progress_loaded", _local_progress)
	print("[FirebaseSync] Documento de progreso creado para scout: %s" % scout_id)

# ============================================================================
# SINCRONIZACIÓN PERIÓDICA (Timer)
# ============================================================================

func _on_sync_timer_timeout() -> void:
	"""Se ejecuta cada 5 segundos para intentar sincronizar cambios pendientes."""
	if _pending_sync_buffer.is_empty():
		return

	_try_sync()

	# Mostrar feedback visual si hay cambios >10 segundos sin sincronizar
	if not _sync_in_progress and not _pending_sync_buffer.is_empty():
		var time_since_last_sync = Time.get_ticks_msec() / 1000.0 - _last_sync_time
		if time_since_last_sync > FirebaseConfig.SYNC_TIMEOUT_SHOW_UI_SECONDS:
			emit_signal("sync_status_changed", true)

# ============================================================================
# UTILIDADES — Levenshtein distance y conversión de datos
# ============================================================================

func _levenshtein_similarity(s1: String, s2: String) -> float:
	"""Calcula similitud (0-1) entre dos strings usando distancia Levenshtein."""
	var distance = _levenshtein_distance(s1, s2)
	var max_len = maxf(float(s1.length()), float(s2.length()))

	if max_len == 0:
		return 1.0

	return 1.0 - (float(distance) / max_len)

func _levenshtein_distance(s1: String, s2: String) -> int:
	"""Calcula distancia Levenshtein entre dos strings."""
	var len1 = s1.length()
	var len2 = s2.length()

	# Matrix DP
	var dp = []
	for i in range(len1 + 1):
		dp.append([])
		for j in range(len2 + 1):
			dp[i].append(0)

	for i in range(len1 + 1):
		dp[i][0] = i
	for j in range(len2 + 1):
		dp[0][j] = j

	for i in range(1, len1 + 1):
		for j in range(1, len2 + 1):
			if s1[i - 1] == s2[j - 1]:
				dp[i][j] = dp[i - 1][j - 1]
			else:
				dp[i][j] = 1 + mini(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1])

	return dp[len1][len2]

func _extract_doc_id(doc: Dictionary) -> String:
	"""Extrae ID del documento desde la ruta."""
	if doc.has("name"):
		var parts = doc["name"].split("/")
		if parts.size() > 0:
			return parts[parts.size() - 1]
	return ""

func _get_field_value(fields: Dictionary, field_name: String, default = null):
	"""Extrae valor de un campo Firestore."""
	if not fields.has(field_name):
		return default

	var field = fields[field_name]

	if field.has("stringValue"):
		return field["stringValue"]
	elif field.has("integerValue"):
		return int(field["integerValue"])
	elif field.has("booleanValue"):
		return field["booleanValue"]
	elif field.has("arrayValue"):
		return field["arrayValue"].get("values", [])
	elif field.has("mapValue"):
		return field["mapValue"].get("fields", {})

	return default

func _convert_to_firestore_format(value) -> Dictionary:
	"""Convierte valor local a formato Firestore."""
	if value is String:
		return {"stringValue": value}
	elif value is int:
		return {"integerValue": str(value)}
	elif value is bool:
		return {"booleanValue": value}
	elif value is Array:
		return {"arrayValue": {"values": value}}
	elif value is Dictionary:
		var firestore_fields = {}
		for k in value.keys():
			firestore_fields[k] = _convert_to_firestore_format(value[k])
		return {"mapValue": {"fields": firestore_fields}}
	else:
		return {"nullValue": {}}

# ============================================================================
# GETTERS PARA ACCESO AL ESTADO LOCAL
# ============================================================================

func get_current_scout_id() -> String:
	return _current_scout_id

func get_local_progress() -> Dictionary:
	return _local_progress.duplicate(true)

func is_syncing() -> bool:
	return _sync_in_progress or not _pending_sync_buffer.is_empty()

func has_pending_sync() -> bool:
	return not _pending_sync_buffer.is_empty()
