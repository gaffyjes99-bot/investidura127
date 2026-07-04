extends Node

const SAVE_KEY := "senda_pietierno_v1"

func guardar() -> void:
	var datos := {
		"nombre_scout": GameState.nombre_scout,
		"patrulla": GameState.patrulla,
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
	GameState.xp = datos.get("xp", 0)
	GameState.rango = datos.get("rango", "Pietierno")
	GameState.capitulos_completados = datos.get("capitulos_completados", [])
	GameState.insignias = datos.get("insignias", [])
	GameState.escenas_vistas = datos.get("escenas_vistas", {})
	return true

func borrar() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("localStorage.removeItem('%s')" % SAVE_KEY)
	else:
		if FileAccess.file_exists("user://save.json"):
			DirAccess.remove_absolute("user://save.json")
