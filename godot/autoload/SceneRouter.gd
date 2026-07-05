extends Node

const ESCENAS := {
	"main":       "res://scenes/main.tscn",
	"onboarding": "res://scenes/onboarding/onboarding.tscn",
	"mapa":       "res://scenes/mapa/mapa_senda.tscn",
	"capitulo":   "res://scenes/capitulo/capitulo.tscn",
	"perfil":     "res://scenes/perfil/perfil.tscn",
}

const PATRULLAS := ["Jaguares", "Lobos", "Mapaches", "Pandas"]

const CAP_SPRITES := {
	1:  "res://assets/sprites/bp_young_talking_v1.png",
	2:  "res://assets/sprites/bp_young_v1.png",
	3:  "res://assets/sprites/scout_boy_talking_v1.png",
	4:  "res://assets/sprites/scout_girl_v1.png",
	5:  "res://assets/sprites/akela_talking_v1.png",
	6:  "res://assets/sprites/scout_boy_v1.png",
	7:  "res://assets/sprites/scout_girl_celebrate_v1.png",
	8:  "res://assets/sprites/baloo_talking_v1.png",
	9:  "res://assets/sprites/kaa_v1.png",
	10: "res://assets/sprites/wontolla_talking_v1.png",
	11: "res://assets/sprites/jacala_v1.png",
	12: "res://assets/sprites/kotick_celebrate_v1.png",
}

const CAPITULOS := [
	{"num": 1,  "nombre": "El Origen del Fuego"},
	{"num": 2,  "nombre": "El Codigo del Explorador"},
	{"num": 3,  "nombre": "Mi Palabra de Honor"},
	{"num": 4,  "nombre": "Las Raices"},
	{"num": 5,  "nombre": "Los Simbolos"},
	{"num": 6,  "nombre": "El Uniforme"},
	{"num": 7,  "nombre": "La Buena Accion"},
	{"num": 8,  "nombre": "El Lenguaje de la Tropa"},
	{"num": 9,  "nombre": "Formaciones y Bordon"},
	{"num": 10, "nombre": "Mi Tropa, Mi Familia"},
	{"num": 11, "nombre": "La Prueba del Campista"},
	{"num": 12, "nombre": "La Gran Ceremonia"},
]

var _capitulo_activo: int = 0
var _scene_retry: int = 0

# refs onboarding
var _patrulla_idx: int = -1
var _ob_ni:   LineEdit = null
var _ob_bi:   Button   = null
var _ob_el:   Label    = null
var _ob_btns: Array    = []

# refs mapa
var _mp_xp_lbl:    Label = null
var _mp_rango_lbl: Label = null

# ── arranque ────────────────────────────────────────────────────────────────

func _ready() -> void:
	call_deferred("_ruta_inicial")

func _ruta_inicial() -> void:
	print("SceneRouter: _ruta_inicial")
	var hay_save := SaveManager.cargar()
	print("SceneRouter: hay_save=", hay_save)
	if hay_save and GameState.esta_configurado():
		_ir_a("mapa")
	else:
		_ir_a("onboarding")

# ── navegación ───────────────────────────────────────────────────────────────

func _ir_a(nombre: String) -> void:
	print("SceneRouter: _ir_a ", nombre)
	var err := get_tree().change_scene_to_file(ESCENAS[nombre])
	if err != OK:
		push_error("SceneRouter: no se pudo cargar " + nombre + " err=" + str(err))
		return
	_scene_retry = 0
	# process_frame = UNA vez por frame (evita loop infinito dentro del mismo flush)
	get_tree().process_frame.connect(_on_scene_ready.bind(nombre), CONNECT_ONE_SHOT)

func _on_scene_ready(nombre: String) -> void:
	# current_scene puede ser null en web — fallback: último hijo de root
	var s: Node = get_tree().current_scene
	if s == null:
		var root := get_tree().root
		if root.get_child_count() > 0:
			s = root.get_child(root.get_child_count() - 1)
	print("SceneRouter: _on_scene_ready retry=", _scene_retry,
		  " s=", s, " path=", s.scene_file_path if s else "null")
	# Reintentar si todavía no es la escena esperada (máx 60 frames)
	if s == null or s.scene_file_path != ESCENAS[nombre]:
		_scene_retry += 1
		if _scene_retry > 60:
			push_error("SceneRouter: timeout esperando escena " + nombre)
			return
		get_tree().process_frame.connect(_on_scene_ready.bind(nombre), CONNECT_ONE_SHOT)
		return
	_scene_retry = 0
	print("SceneRouter: escena lista: ", nombre)
	match nombre:
		"onboarding": _init_onboarding(s)
		"mapa":       _init_mapa(s)
		"capitulo":   _init_capitulo(s)
		"perfil":     _init_perfil(s)
		_: pass

# API pública (para llamadas futuras desde otros AutoLoads)
func ir_a(nombre: String) -> void:
	_ir_a(nombre)

func ir_a_capitulo(num: int) -> void:
	_capitulo_activo = num
	_ir_a("capitulo")

func get_capitulo_activo() -> int:
	return _capitulo_activo

# ── onboarding ───────────────────────────────────────────────────────────────

func _init_onboarding(s: Node) -> void:
	print("SceneRouter: _init_onboarding s=", s)
	if s == null:
		push_error("SceneRouter: escena nula en onboarding")
		return
	_ob_ni   = s.get_node("VBox/NombreInput") as LineEdit
	_ob_bi   = s.get_node("VBox/BotonIniciar") as Button
	_ob_el   = s.get_node("VBox/ErrorLabel")   as Label
	_ob_btns = [
		s.get_node("VBox/PatrullasGrid/BtnJaguares"),
		s.get_node("VBox/PatrullasGrid/BtnLobos"),
		s.get_node("VBox/PatrullasGrid/BtnMapaches"),
		s.get_node("VBox/PatrullasGrid/BtnPandas"),
	]
	_patrulla_idx = -1
	_ob_el.visible = false
	_ob_bi.disabled = true

	_ob_ni.text_changed.connect(_ob_on_nombre)
	for i in _ob_btns.size():
		(_ob_btns[i] as Button).pressed.connect(_ob_sel.bind(i))
	_ob_bi.pressed.connect(_ob_iniciar)
	print("SceneRouter: onboarding listo")

func _ob_on_nombre(_t: String) -> void:
	if _ob_ni == null:
		return
	_ob_bi.disabled = _ob_ni.text.strip_edges().length() < 2 or _patrulla_idx < 0

func _ob_sel(idx: int) -> void:
	print("SceneRouter: patrulla=", idx)
	_patrulla_idx = idx
	for j in _ob_btns.size():
		(_ob_btns[j] as Button).modulate = Color(0.3, 1.0, 0.4) if j == idx else Color(1.0, 1.0, 1.0)
	_ob_bi.disabled = _ob_ni.text.strip_edges().length() < 2

# ── mapa ─────────────────────────────────────────────────────────────────────

func _init_mapa(s: Node) -> void:
	print("SceneRouter: _init_mapa s=", s)
	var nombre_lbl := s.get_node("Header/NombreLabel") as Label
	_mp_xp_lbl    = s.get_node("Header/XpLabel")      as Label
	_mp_rango_lbl = s.get_node("Header/RangoLabel")   as Label
	var perfil_btn := s.get_node("Header/PerfilBoton") as Button
	var grid       := s.get_node("ScrollContainer/Grid") as GridContainer

	nombre_lbl.text    = "%s - Patrulla %s" % [GameState.nombre_scout, GameState.patrulla]
	_mp_xp_lbl.text    = "%d XP" % GameState.xp
	_mp_rango_lbl.text = GameState.rango

	perfil_btn.pressed.connect(func(): _ir_a("perfil"))

	for cap in CAPITULOS:
		var num: int  = cap["num"] as int
		var btn       := Button.new()
		btn.custom_minimum_size = Vector2(180, 120)
		btn.add_theme_font_size_override("font_size", 16)
		var desbloqueado := GameState.capitulo_desbloqueado(num)
		var completado: bool = num in GameState.capitulos_completados
		btn.text     = "Cap.%d\n%s" % [num, cap["nombre"]]
		btn.disabled = not desbloqueado
		if completado:
			btn.modulate = Color(0.6, 1.0, 0.6, 1)
		elif not desbloqueado:
			btn.modulate = Color(0.4, 0.4, 0.4, 1)
		btn.pressed.connect(ir_a_capitulo.bind(num))
		grid.add_child(btn)

	if not GameState.xp_changed.is_connected(_mp_on_xp):
		GameState.xp_changed.connect(_mp_on_xp)
	print("SceneRouter: mapa listo")

func _mp_on_xp(nuevo_xp: int) -> void:
	if _mp_xp_lbl:    _mp_xp_lbl.text    = "%d XP" % nuevo_xp
	if _mp_rango_lbl: _mp_rango_lbl.text = GameState.rango

# ─────────────────────────────────────────────────────────────────────────────

# ── capitulo ─────────────────────────────────────────────────────────────────

var _cap_s: Node = null
var _cap_escenas: Array = []
var _cap_preguntas: Array = []
var _cap_escena_idx: int = 0
var _cap_quiz_idx: int = 0
var _cap_correctas: int = 0
var _cap_estado: int = 0  # 0=jugando, 1=aprobado, 2=reprobado

func _init_capitulo(s: Node) -> void:
	_cap_s = s
	_cap_escena_idx = 0
	_cap_quiz_idx = 0
	_cap_correctas = 0
	_cap_estado = 0

	var num_str := "%02d" % _capitulo_activo
	var f1 := FileAccess.open("res://capitulos/%s/escenas.json" % num_str, FileAccess.READ)
	if f1 == null:
		push_error("SceneRouter: no se encontro capitulos/%s/escenas.json" % num_str)
		return
	var d1 = JSON.parse_string(f1.get_as_text())
	f1.close()
	_cap_escenas = d1.get("escenas", [])

	var f2 := FileAccess.open("res://capitulos/%s/preguntas.json" % num_str, FileAccess.READ)
	if f2 == null:
		push_error("SceneRouter: no se encontro capitulos/%s/preguntas.json" % num_str)
		return
	var d2 = JSON.parse_string(f2.get_as_text())
	f2.close()
	_cap_preguntas = []
	for q in d2.get("preguntas", []):
		if q.get("distractores", null) != null:
			_cap_preguntas.append(q)

	(s.get_node("Footer/BotonMapa") as Button).pressed.connect(func(): _ir_a("mapa"))
	(s.get_node("Footer/BotonSiguiente") as Button).pressed.connect(_cap_siguiente)

	_cap_mostrar_escena(0)
	print("SceneRouter: capitulo listo cap=", _capitulo_activo, " preguntas=", _cap_preguntas.size())

func _cap_mostrar_escena(idx: int) -> void:
	_cap_escena_idx = idx
	var s := _cap_s
	var titulo_lbl   := s.get_node("Header/TituloLabel") as Label
	var progreso_lbl := s.get_node("Header/ProgresoLabel") as Label
	var narr_panel   := s.get_node("ContenidoArea/NarracionPanel") as Control
	var quiz_panel   := s.get_node("ContenidoArea/QuizPanel") as Control
	var btn_sig      := s.get_node("Footer/BotonSiguiente") as Button

	titulo_lbl.text = "Cap.%d — %s" % [_capitulo_activo, CAPITULOS[_capitulo_activo - 1]["nombre"]]
	progreso_lbl.text = "Escena %d / %d" % [idx + 1, _cap_escenas.size()]
	narr_panel.visible = false
	quiz_panel.visible = false

	if idx >= _cap_escenas.size():
		return

	var escena: Dictionary = _cap_escenas[idx]
	var tipo: String = escena.get("tipo", "")

	if tipo == "evaluacion":
		btn_sig.visible = false
		_cap_quiz_idx = 0
		_cap_correctas = 0
		quiz_panel.visible = true
		_cap_mostrar_pregunta()
	else:
		btn_sig.text = "Siguiente ->"
		btn_sig.visible = true
		narr_panel.visible = true
		var personaje_lbl := s.get_node("ContenidoArea/NarracionPanel/PersonajeLabel") as Label
		var dialogo_lbl   := s.get_node("ContenidoArea/NarracionPanel/ContentRow/DialogoLabel") as RichTextLabel
		var imagen_rect   := s.get_node("ContenidoArea/NarracionPanel/ContentRow/ImagenRect") as TextureRect
		match tipo:
			"narracion":
				personaje_lbl.text = "Historia"
				dialogo_lbl.text = escena.get("dialogo_muestra", escena.get("contenido", ""))
			"animacion":
				personaje_lbl.text = "Secuencia"
				dialogo_lbl.text = escena.get("contenido", "")
			"juego":
				personaje_lbl.text = "Actividad"
				dialogo_lbl.text = escena.get("contenido", "")
		# Mostrar sprite del capítulo en narracion y animacion
		if tipo in ["narracion", "animacion"] and CAP_SPRITES.has(_capitulo_activo):
			var tex := load(CAP_SPRITES[_capitulo_activo]) as Texture2D
			if tex:
				imagen_rect.texture = tex
				imagen_rect.visible = true
			else:
				imagen_rect.visible = false
		else:
			imagen_rect.visible = false
		var primera_vez := GameState.marcar_escena_vista(_capitulo_activo, idx)
		if primera_vez:
			var xp: int = escena.get("xp", 0) as int
			if xp > 0:
				GameState.dar_xp(xp)

func _cap_siguiente() -> void:
	match _cap_estado:
		1:
			_cap_estado = 0
			_ir_a("mapa")
		2:
			_cap_estado = 0
			for i in _cap_escenas.size():
				if _cap_escenas[i].get("tipo", "") == "evaluacion":
					_cap_mostrar_escena(i)
					return
		_:
			_cap_mostrar_escena(_cap_escena_idx + 1)

func _cap_mostrar_pregunta() -> void:
	if _cap_quiz_idx >= _cap_preguntas.size():
		_cap_quiz_fin()
		return

	var s := _cap_s
	var pregunta_lbl := s.get_node("ContenidoArea/QuizPanel/PreguntaLabel") as RichTextLabel
	var opciones_box := s.get_node("ContenidoArea/QuizPanel/OpcionesBox") as VBoxContainer
	var resultado_lbl := s.get_node("ContenidoArea/QuizPanel/ResultadoLabel") as Label
	var progreso_lbl  := s.get_node("Header/ProgresoLabel") as Label

	var q: Dictionary = _cap_preguntas[_cap_quiz_idx]
	progreso_lbl.text = "Pregunta %d / %d" % [_cap_quiz_idx + 1, _cap_preguntas.size()]
	pregunta_lbl.text = "[b]%s[/b]" % q.get("pregunta", "")
	resultado_lbl.visible = false

	for child in opciones_box.get_children():
		child.queue_free()

	var opciones: Array = []
	var correcta: String = str(q.get("respuesta_correcta", ""))
	opciones.append(correcta)
	for d in str(q.get("distractores", "")).split("|"):
		var dt := d.strip_edges()
		if dt.length() > 0:
			opciones.append(dt)
	opciones.shuffle()

	for opcion in opciones:
		var btn := Button.new()
		btn.text = str(opcion)
		btn.custom_minimum_size = Vector2(0, 52)
		btn.add_theme_font_size_override("font_size", 18)
		btn.pressed.connect(_cap_responder.bind(str(opcion), correcta, resultado_lbl, opciones_box))
		opciones_box.add_child(btn)

func _cap_responder(opcion: String, correcta: String, resultado_lbl: Label, opciones_box: VBoxContainer) -> void:
	for child in opciones_box.get_children():
		(child as Button).disabled = true
	if opcion == correcta:
		_cap_correctas += 1
		resultado_lbl.text = "Correcto!"
		resultado_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	else:
		resultado_lbl.text = "Incorrecto. Era: " + correcta
		resultado_lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	resultado_lbl.visible = true
	get_tree().create_timer(1.5).timeout.connect(_cap_avanzar_quiz, CONNECT_ONE_SHOT)

func _cap_avanzar_quiz() -> void:
	_cap_quiz_idx += 1
	_cap_mostrar_pregunta()

func _cap_quiz_fin() -> void:
	var s := _cap_s
	var quiz_panel    := s.get_node("ContenidoArea/QuizPanel") as Control
	var narr_panel    := s.get_node("ContenidoArea/NarracionPanel") as Control
	var btn_sig       := s.get_node("Footer/BotonSiguiente") as Button
	var progreso_lbl  := s.get_node("Header/ProgresoLabel") as Label
	var personaje_lbl := s.get_node("ContenidoArea/NarracionPanel/PersonajeLabel") as Label
	var dialogo_lbl   := s.get_node("ContenidoArea/NarracionPanel/DialogoLabel") as RichTextLabel

	quiz_panel.visible = false
	narr_panel.visible = true
	btn_sig.visible = true
	progreso_lbl.text = "Resultado final"

	var total := _cap_preguntas.size()
	var pct: float = float(_cap_correctas) / float(total) * 100.0

	var escena_eval: Dictionary = {}
	for esc in _cap_escenas:
		if esc.get("tipo", "") == "evaluacion":
			escena_eval = esc
			break
	var xp_base: int   = escena_eval.get("xp", 30) as int
	var xp_bonus: int  = escena_eval.get("xp_perfecto_bonus", 15) as int
	var min_pct: float = escena_eval.get("minimo_aprobar_pct", 80.0) as float

	if pct >= min_pct:
		_cap_estado = 1
		var xp_ganado := xp_base + (xp_bonus if pct >= 100.0 else 0)
		GameState.completar_capitulo(_capitulo_activo)
		GameState.dar_xp(xp_ganado)
		SaveManager.guardar()
		btn_sig.text = "Volver al Mapa"
		personaje_lbl.text = "Capitulo completado!"
		dialogo_lbl.text = "[b]%d/%d correctas (%.0f%%)[/b]\n\nHas completado el capitulo y ganado [color=yellow]%d XP[/color]!" % [_cap_correctas, total, pct, xp_ganado]
	else:
		_cap_estado = 2
		btn_sig.text = "Reintentar"
		personaje_lbl.text = "Sigue intentando"
		dialogo_lbl.text = "[b]%d/%d correctas (%.0f%%)[/b]\n\nNecesitas al menos %.0f%%. Puedes intentarlo de nuevo." % [_cap_correctas, total, pct, min_pct]

# ── perfil ───────────────────────────────────────────────────────────────────

var _pf_borrar_confirmando: bool = false

func _init_perfil(s: Node) -> void:
	(s.get_node("VBox/NombreLabel")    as Label).text = "Scout: %s" % GameState.nombre_scout
	(s.get_node("VBox/PatrullaLabel")  as Label).text = "Patrulla: %s" % GameState.patrulla
	(s.get_node("VBox/RangoLabel")     as Label).text = "Rango: %s" % GameState.rango
	(s.get_node("VBox/XpLabel")        as Label).text = "XP total: %d" % GameState.xp
	(s.get_node("VBox/InsigniasLabel") as Label).text = "Capitulos completados: %d / 12" % GameState.capitulos_completados.size()

	# Lista de capítulos completados
	var vbox := s.get_node("VBox") as VBoxContainer
	if GameState.capitulos_completados.size() > 0:
		var detalle := RichTextLabel.new()
		detalle.bbcode_enabled = true
		detalle.fit_content = true
		detalle.add_theme_font_size_override("normal_font_size", 16)
		var lineas := "[color=aaffaa]"
		for num in GameState.capitulos_completados:
			var idx: int = (num as int) - 1
			if idx >= 0 and idx < CAPITULOS.size():
				lineas += "  Cap.%d — %s\n" % [num, CAPITULOS[idx]["nombre"]]
		lineas += "[/color]"
		detalle.text = lineas
		vbox.add_child(detalle)
		vbox.move_child(detalle, vbox.get_children().find(s.get_node("VBox/InsigniasLabel")) + 1)

	_pf_borrar_confirmando = false
	var btn_mapa   := s.get_node("VBox/BotonMapa")   as Button
	var btn_borrar := s.get_node("VBox/BotonBorrar") as Button
	btn_mapa.text = "<- Volver al Mapa"
	btn_mapa.pressed.connect(func(): _ir_a("mapa"))
	btn_borrar.pressed.connect(_pf_borrar.bind(btn_borrar))
	print("SceneRouter: perfil listo")

func _pf_borrar(btn: Button) -> void:
	if not _pf_borrar_confirmando:
		_pf_borrar_confirmando = true
		btn.text = "Presiona de nuevo para confirmar"
		btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	else:
		SaveManager.borrar()
		GameState.nombre_scout = ""
		GameState.patrulla     = ""
		GameState.xp           = 0
		GameState.rango        = "Pietierno"
		GameState.capitulos_completados.clear()
		GameState.insignias.clear()
		GameState.escenas_vistas.clear()
		_ir_a("onboarding")

# ─────────────────────────────────────────────────────────────────────────────

func _ob_iniciar() -> void:
	var nombre := _ob_ni.text.strip_edges()
	if nombre.length() < 2 or _patrulla_idx < 0:
		_ob_el.text = "Completa nombre y patrulla"
		_ob_el.visible = true
		return
	GameState.nombre_scout = nombre
	GameState.patrulla = PATRULLAS[_patrulla_idx]
	SaveManager.guardar()
	_ir_a("mapa")
