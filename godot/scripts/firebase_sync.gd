extends Node

# Firebase Sync — Firestore REST API via JavaScript fetch
signal scout_found(scout_id: String, name: String, patrol: String)
signal scout_not_found(error_message: String)
signal multiple_matches(matches: Array[Dictionary])
signal progress_loaded(data: Dictionary)
signal progress_synced(field: String)
signal sync_error(error_message: String)
signal sync_status_changed(syncing: bool)

var _current_scout_id: String = ""
var _current_grupo_id: String = FirebaseConfig.GRUPO_ID
var _local_progress: Dictionary = {}
var _pending_sync_buffer: Dictionary = {}
var _sync_in_progress: bool = false
var _last_sync_time: float = 0.0
var _sync_error_count: int = 0
var _sync_timer

func _ready() -> void:
	print("[FirebaseSync] Inicializando Firebase Sync (fetch API)...")
	_sync_timer = Timer.new()
	add_child(_sync_timer)
	_sync_timer.timeout.connect(_on_sync_timer_timeout)
	_sync_timer.wait_time = FirebaseConfig.SYNC_INTERVAL_SECONDS
	_sync_timer.start()
	print("[FirebaseSync] ✅ Ready")

# ============================================================================
# HTTP HELPER — Fetch API wrapper
# ============================================================================

func _fetch_async(method: String, url: String, body: String = "") -> Dictionary:
	"""Ejecuta fetch asincrónico y retorna respuesta."""
	var options = ""
	if method != "GET":
		options = ', {"method": "%s", "headers": {"Content-Type": "application/json"}, "body": \'%s\'}' % [method, body.replace("'", "\\'")]

	var js_code = """
	(async () => {
		try {
			console.log('[FirebaseSync JS] Fetch %s: %s', '%s'.substring(0, 80) + '...', '%s');
			const resp = await fetch('%s'%s);
			const text = await resp.text();
			window.lastFetchResult = {status: 'ok', code: resp.status, body: text};
			console.log('[FirebaseSync JS] ✅ Response %d, %d bytes', resp.status, text.length);
		} catch(e) {
			console.log('[FirebaseSync JS] ❌ Error: ' + e.message);
			window.lastFetchResult = {status: 'error', error: e.message};
		}
	})();
	""" % [method, url, body, url]

	JavaScriptBridge.eval(js_code)
	# Aumentar timeout de 0.8s a 3s para Firestore
	await get_tree().create_timer(3.0).timeout

	if not JavaScriptBridge.get_interface("window").has("lastFetchResult"):
		print("[FirebaseSync] ❌ Timeout esperando respuesta de fetch")
		return {"error": "Fetch timeout"}

	var result = JavaScriptBridge.get_interface("window").lastFetchResult
	print("[FirebaseSync] 📦 Resultado fetch: status=%s, code=%s" % [result.get("status"), result.get("code")])
	return result

# ============================================================================
# BÚSQUEDA FUZZY DE SCOUTS
# ============================================================================

func find_scout_in_firestore(nombre_input: String, patrulla: String) -> void:
	if nombre_input.is_empty() or patrulla.is_empty():
		print("[FirebaseSync] ❌ Nombre o patrulla vacíos")
		emit_signal("scout_not_found", "Nombre y patrulla requeridos")
		return

	var endpoint = FirebaseConfig.get_scouts_endpoint()
	print("[FirebaseSync] 🔍 Búsqueda: '%s' en '%s'" % [nombre_input, patrulla])

	var result = await _fetch_async("GET", endpoint)

	if result.has("error"):
		print("[FirebaseSync] ❌ Error fetch: %s" % result["error"])
		emit_signal("scout_not_found", "Error de conexión: %s" % result["error"])
		return

	if result.get("code", 0) >= 400:
		print("[FirebaseSync] ❌ HTTP %d" % result["code"])
		emit_signal("scout_not_found", "Error servidor: HTTP %d" % result["code"])
		return

	_process_find_scout_response(result.get("body", ""), nombre_input, patrulla)

func _process_find_scout_response(response_body: String, nombre_input: String, patrulla: String) -> void:
	print("[FirebaseSync] 📥 Procesando respuesta...")

	if response_body.is_empty():
		emit_signal("scout_not_found", "Respuesta vacía")
		return

	var json = JSON.new()
	if json.parse(response_body) != OK:
		emit_signal("scout_not_found", "JSON inválido")
		return

	var data = json.data
	if not data.has("documents"):
		emit_signal("scout_not_found", "No hay scouts")
		return

	var matches: Array[Dictionary] = []
	var documents = data["documents"] if data["documents"] is Array else []
	print("[FirebaseSync] 📊 Total scouts: %d" % documents.size())

	for doc in documents:
		if not doc.has("fields"):
			continue

		var fields = doc["fields"]
		var doc_patrulla = _get_field_value(fields, "patrulla", "")
		var doc_nombre = _get_field_value(fields, "nombre", "")

		if doc_patrulla.to_lower() != patrulla.to_lower():
			continue

		var similarity = _levenshtein_similarity(nombre_input.to_lower(), doc_nombre.to_lower())
		print("[FirebaseSync]   🔎 '%s' vs '%s' = %.0f%%" % [nombre_input, doc_nombre, similarity * 100])

		if similarity >= FirebaseConfig.MIN_SIMILARITY_THRESHOLD:
			matches.append({
				"scout_id": doc.get("name", "").split("/")[-1],
				"nombre": doc_nombre,
				"patrulla": doc_patrulla,
				"similarity": similarity
			})
			print("[FirebaseSync]   ✅ COINCIDENCIA")

	matches.sort_custom(func(a, b): return a["similarity"] > b["similarity"])

	if matches.is_empty():
		emit_signal("scout_not_found", "Scout no encontrado en '%s'" % patrulla)
	elif matches.size() == 1:
		var match = matches[0]
		_current_scout_id = match["scout_id"]
		print("[FirebaseSync] ✅ Scout: %s" % match["nombre"])
		emit_signal("scout_found", match["scout_id"], match["nombre"], match["patrulla"])
	else:
		print("[FirebaseSync] ⚠️ %d coincidencias" % matches.size())
		emit_signal("multiple_matches", matches)

# ============================================================================
# PROGRESO DEL SCOUT
# ============================================================================

func get_scout_progress(grupo_id: String, scout_id: String) -> void:
	_current_scout_id = scout_id
	_current_grupo_id = grupo_id

	var doc_id = "%s_%s" % [grupo_id, scout_id]
	var endpoint = FirebaseConfig.get_progreso_endpoint(doc_id)

	print("[FirebaseSync] 📥 Cargando progreso: %s" % scout_id)

	var result = await _fetch_async("GET", endpoint)

	if result.has("error") or result.get("code", 0) >= 400:
		print("[FirebaseSync] 📝 Creando documento nuevo")
		_create_default_progress(scout_id, grupo_id)
		return

	var json = JSON.new()
	if json.parse(result.get("body", "")) != OK:
		_create_default_progress(scout_id, grupo_id)
		return

	_local_progress = json.data
	print("[FirebaseSync] ✅ Progreso cargado")
	emit_signal("progress_loaded", _local_progress)

func _create_default_progress(scout_id: String, grupo_id: String) -> void:
	var doc_id = "%s_%s" % [grupo_id, scout_id]
	var endpoint = "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/%s/%s?key=%s" % [
		FirebaseConfig.PROJECT_ID,
		FirebaseConfig.FIRESTORE_PROGRESO_COLLECTION,
		doc_id,
		FirebaseConfig.API_KEY
	]

	var default_data = FirebaseConfig.get_default_progress_data(scout_id, "", "")
	var json_body = JSON.stringify(default_data)

	print("[FirebaseSync] 📝 Creando progreso nuevo")
	var result = await _fetch_async("POST", endpoint, json_body)

	if result.has("error"):
		print("[FirebaseSync] ❌ Error crear: %s" % result["error"])
		return

	var json = JSON.new()
	if json.parse(result.get("body", "")) == OK:
		_local_progress = json.data
		emit_signal("progress_loaded", _local_progress)

# ============================================================================
# SINCRONIZACIÓN
# ============================================================================

func push_scout_data(updates: Dictionary) -> void:
	if _current_scout_id.is_empty():
		emit_signal("sync_error", "Scout no identificado")
		return

	for key in updates.keys():
		_pending_sync_buffer[key] = updates[key]
		_local_progress[key] = updates[key]

	_try_sync()

func _try_sync() -> void:
	if _pending_sync_buffer.is_empty() or _sync_in_progress:
		return

	_sync_in_progress = true
	emit_signal("sync_status_changed", true)

	var doc_id = "%s_%s" % [_current_grupo_id, _current_scout_id]
	var endpoint = FirebaseConfig.get_progreso_endpoint(doc_id)

	var firestore_updates = {"fields": {}}
	for key in _pending_sync_buffer.keys():
		firestore_updates["fields"][key] = _convert_to_firestore_format(_pending_sync_buffer[key])

	var json_body = JSON.stringify(firestore_updates)
	var result = await _fetch_async("PATCH", endpoint, json_body)

	if not result.has("error") and result.get("code", 0) < 400:
		_pending_sync_buffer.clear()
		print("[FirebaseSync] ✅ Sincronizado")
	else:
		_sync_error_count += 1
		print("[FirebaseSync] ⚠️ Sync fallido")

	_sync_in_progress = false
	emit_signal("sync_status_changed", false)

func _on_sync_timer_timeout() -> void:
	if not _pending_sync_buffer.is_empty():
		_try_sync()

# ============================================================================
# UTILIDADES
# ============================================================================

func _levenshtein_similarity(s1: String, s2: String) -> float:
	var distance = _levenshtein_distance(s1, s2)
	var max_len = maxf(float(s1.length()), float(s2.length()))
	if max_len == 0:
		return 1.0
	return 1.0 - (float(distance) / max_len)

func _levenshtein_distance(s1: String, s2: String) -> int:
	var len1 = s1.length()
	var len2 = s2.length()
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
				dp[i][j] = 1 + mini(dp[i - 1][j], mini(dp[i][j - 1], dp[i - 1][j - 1]))

	return dp[len1][len2]

func _get_field_value(fields: Dictionary, field_name: String, default = null):
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

func get_current_scout_id() -> String:
	return _current_scout_id

func get_local_progress() -> Dictionary:
	return _local_progress.duplicate(true)

func is_syncing() -> bool:
	return _sync_in_progress or not _pending_sync_buffer.is_empty()

func has_pending_sync() -> bool:
	return not _pending_sync_buffer.is_empty()
