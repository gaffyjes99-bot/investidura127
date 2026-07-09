extends Node

const SAVE_KEY := "senda_pietierno_v1"

func guardar() -> void:
	var datos := {
		"nombre_scout": GameState.nombre_scout,
		"patrulla": GameState.patrulla,
		"scout_id": GameState.scout_id,
		"xp": GameState.xp,
		"rango": GameState.rango,
		"capitulos_completados": GameState.capitulos_completados,
		"insignias": GameState.insignias,
		"escenas_vistas": GameState.escenas_vistas,
	}
	var json := JSON.stringify(datos)
	if OS.has_feature("web"):
		JavaScriptBridge.eval("localStorage.setItem('%s', '%s')" % [SAVE_KEY, json.replace("'", "\\'")])
	else:
		var f := FileAccess.open("user://save.json", FileAccess.WRITE)
		if f:
			f.store_string(json)
			f.close()

	# Sincronizar con Firestore (si scout está autenticado)
	_sync_to_firestore()

func cargar() -> bool:
	var json_str: String = ""
	if OS.has_feature("web"):
		var raw = JavaScriptBridge.eval("localStorage.getItem('%s')" % SAVE_KEY)
		if raw == null or str(raw) == "null":
			return false
		json_str = str(raw)
	else:
		if not FileAccess.file_exists("user://save.json"):
			return false
		var f := FileAccess.open("user://save.json", FileAccess.READ)
		if not f:
			return false
		json_str = f.get_as_text()
		f.close()

	var datos = JSON.parse_string(json_str)
	if datos == null:
		return false

	GameState.nombre_scout = datos.get("nombre_scout", "")
	GameState.patrulla = datos.get("patrulla", "")
	GameState.scout_id = datos.get("scout_id", "")
	GameState.xp = datos.get("xp", 0)
	GameState.rango = datos.get("rango", "Pietierno")
	var caps: Array[int] = []
	for c in datos.get("capitulos_completados", []):
		caps.append(c as int)
	GameState.capitulos_completados = caps
	var insig: Array[int] = []
	for i in datos.get("insignias", []):
		insig.append(i as int)
	GameState.insignias = insig
	GameState.escenas_vistas = datos.get("escenas_vistas", {})

	# Puesta al dia: al volver via localStorage (sin re-login) sincroniza el
	# estado local completo a Firestore, para que el panel refleje el avance real.
	if not GameState.scout_id.is_empty():
		_sync_to_firestore()

	return true

func borrar() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("localStorage.removeItem('%s')" % SAVE_KEY)
	else:
		if FileAccess.file_exists("user://save.json"):
			DirAccess.remove_absolute("user://save.json")

func _sync_to_firestore() -> void:
	"""Sincroniza cambios locales a Firestore después de guardar."""
	# Solo sincronizar si el scout está autenticado (tiene scout_id)
	if GameState.scout_id.is_empty():
		return

	if not FirebaseSync:
		print("[SaveManager] FirebaseSync no disponible")
		return

	# Restaurar contexto del scout (necesario cuando se vuelve sin re-login)
	FirebaseSync.ensure_scout_context(GameState.scout_id)

	# Preparar datos para Firestore
	var updates = {
		"xp_total": GameState.xp,
		"rango": GameState.rango,
		"capitulos_completados": GameState.capitulos_completados,
		"insignias_desbloqueadas": GameState.insignias,
		"ultima_actualizacion": int(Time.get_unix_time_from_system())
	}

	# Enviar a Firestore
	FirebaseSync.push_scout_data(updates)
	print("[SaveManager] Progreso sincronizado con Firestore")
