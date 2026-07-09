extends Node

const ESCENAS := {
	"main":       "res://scenes/main.tscn",
	"onboarding": "res://scenes/onboarding/onboarding.tscn",
	"mapa":       "res://scenes/mapa/mapa_senda.tscn",
	"capitulo":   "res://scenes/capitulo/capitulo.tscn",
	"perfil":     "res://scenes/perfil/perfil.tscn",
}

const PATRULLAS := ["Jaguares", "Lobos", "Mapaches", "Pandas"]

# Paleta oficial — docs/Fase3_Guia_de_Estilo.md
const COL_VERDE     := Color("#2E7D32")  # verde bosque (primario)
const COL_VERDE_OSC := Color("#1B4A1F")
const COL_CAFE      := Color("#6D4C33")  # café tierra
const COL_FOGATA    := Color("#F2A93B")  # amarillo fogata (logros/XP)
const COL_ROJO      := Color("#C0392B")  # rojo pañoleta
const COL_CREMA     := Color("#F4EDE0")  # crema hueso
const COL_CAFE_OSC  := Color("#3B2A1E")  # texto sobre fondos claros

const CAP_SPRITES := {
	1:  "res://assets/sprites/bp_young_talking_v1.png",   # Baden Powell (joven)
	2:  "res://assets/sprites/akela_talking_v1.png",      # Akela
	3:  "res://assets/sprites/bp_young_talking_v1.png",   # Baden Powell
	4:  "res://assets/sprites/baloo_talking_v1.png",      # Baloo
	5:  "res://assets/sprites/jacala_talking_v1.png",     # Jacala
	6:  "res://assets/sprites/wontolla_talking_v1.png",   # Wontolla
	7:  "res://assets/sprites/kaa_talking_v1.png",        # Kaa
	8:  "res://assets/sprites/kotick_talking_v1.png",     # Kotick
	9:  "res://assets/sprites/bp_young_talking_v1.png",   # Baden Powell
	10: "res://assets/sprites/akela_talking_v1.png",      # Akela
	11: "res://assets/sprites/bp_young_talking_v1.png",   # Baden Powell
	12: "res://assets/sprites/bp_young_celebrate_v1.png", # Baden Powell (cierre)
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
	if _es_movil():
		# Escala global: todo el contenido 30% mas grande en celular/tablet
		get_window().content_scale_factor = 1.4
	_construir_tema()
	_crear_marca_version()
	call_deferred("_ruta_inicial")

func _es_movil() -> bool:
	return DisplayServer.is_touchscreen_available() \
		or OS.has_feature("web_android") or OS.has_feature("web_ios") \
		or OS.has_feature("android") or OS.has_feature("ios")

# Marca discreta con version y modo (M=movil, D=desktop) para diagnosticar cache
func _crear_marca_version() -> void:
	var capa := CanvasLayer.new()
	capa.layer = 100
	var lbl := Label.new()
	var ver := str(ProjectSettings.get_setting("application/config/version", "?"))
	lbl.text = "v%s-%s" % [ver, "M" if _es_movil() else "D"]
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
	lbl.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	lbl.offset_left = -110.0
	lbl.offset_top = -24.0
	lbl.offset_right = -8.0
	lbl.offset_bottom = -6.0
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(capa)
	capa.add_child(lbl)

# ── tema visual global ───────────────────────────────────────────────────────

func _construir_tema() -> void:
	var tema := Theme.new()
	var fuente := load("res://assets/fonts/Baloo2-Regular.ttf") as FontFile
	if fuente:
		tema.default_font = fuente
	# En pantallas tactiles (celular/tablet) la letra sube de tamano para lectura comoda
	var es_tactil := _es_movil()
	tema.default_font_size = 21 if es_tactil else 18
	tema.set_font_size("normal_font_size", "RichTextLabel", 28 if es_tactil else 20)

	var b_normal := StyleBoxFlat.new()
	b_normal.bg_color = COL_VERDE
	b_normal.set_corner_radius_all(14)
	b_normal.content_margin_left = 14
	b_normal.content_margin_right = 14
	b_normal.content_margin_top = 8
	b_normal.content_margin_bottom = 8
	b_normal.border_width_bottom = 4
	b_normal.border_color = COL_VERDE_OSC
	var b_hover: StyleBoxFlat = b_normal.duplicate()
	b_hover.bg_color = COL_VERDE.lightened(0.12)
	var b_pressed: StyleBoxFlat = b_normal.duplicate()
	b_pressed.bg_color = COL_VERDE_OSC
	b_pressed.border_width_bottom = 0
	var b_disabled: StyleBoxFlat = b_normal.duplicate()
	b_disabled.bg_color = Color(0.22, 0.28, 0.23)
	b_disabled.border_color = Color(0.15, 0.19, 0.16)
	var b_focus := StyleBoxFlat.new()
	b_focus.draw_center = false
	b_focus.border_color = COL_FOGATA
	b_focus.set_border_width_all(2)
	b_focus.set_corner_radius_all(14)
	tema.set_stylebox("normal",   "Button", b_normal)
	tema.set_stylebox("hover",    "Button", b_hover)
	tema.set_stylebox("pressed",  "Button", b_pressed)
	tema.set_stylebox("disabled", "Button", b_disabled)
	tema.set_stylebox("focus",    "Button", b_focus)
	tema.set_color("font_color",          "Button", COL_CREMA)
	tema.set_color("font_hover_color",    "Button", Color.WHITE)
	tema.set_color("font_pressed_color",  "Button", COL_CREMA)
	tema.set_color("font_disabled_color", "Button", Color(0.75, 0.73, 0.68, 0.6))

	var le := StyleBoxFlat.new()
	le.bg_color = COL_CREMA
	le.set_corner_radius_all(12)
	le.set_content_margin_all(10)
	tema.set_stylebox("normal", "LineEdit", le)
	var le_focus: StyleBoxFlat = le.duplicate()
	le_focus.set_border_width_all(3)
	le_focus.border_color = COL_FOGATA
	tema.set_stylebox("focus", "LineEdit", le_focus)
	tema.set_color("font_color",             "LineEdit", COL_CAFE_OSC)
	tema.set_color("caret_color",            "LineEdit", COL_CAFE_OSC)
	tema.set_color("font_placeholder_color", "LineEdit", Color(COL_CAFE_OSC, 0.45))

	tema.set_color("font_color",    "Label",         COL_CREMA)
	tema.set_color("default_color", "RichTextLabel", COL_CREMA)

	get_tree().root.theme = tema

# Estilo puntual para un botón (tarjetas de quiz, feedback verde/rojo, etc.)
func _boton_estilo(btn: Button, bg: Color, fg: Color, borde: Color = Color.TRANSPARENT) -> void:
	var base := StyleBoxFlat.new()
	base.bg_color = bg
	base.set_corner_radius_all(12)
	base.content_margin_left = 14
	base.content_margin_right = 14
	base.content_margin_top = 8
	base.content_margin_bottom = 8
	if borde.a > 0.0:
		base.set_border_width_all(3)
		base.border_color = borde
	var hover: StyleBoxFlat = base.duplicate()
	hover.bg_color = bg.lightened(0.08)
	var pressed: StyleBoxFlat = base.duplicate()
	pressed.bg_color = bg.darkened(0.08)
	btn.add_theme_stylebox_override("normal",   base)
	btn.add_theme_stylebox_override("hover",    hover)
	btn.add_theme_stylebox_override("pressed",  pressed)
	btn.add_theme_stylebox_override("disabled", base.duplicate())
	btn.add_theme_color_override("font_color",          fg)
	btn.add_theme_color_override("font_hover_color",    fg)
	btn.add_theme_color_override("font_pressed_color",  fg)
	btn.add_theme_color_override("font_disabled_color", fg)

# Pop de aparición (insignias, sprites) — pivote centrado tras el layout
func _animar_pop(ctrl: Control) -> void:
	ctrl.call_deferred("set_pivot_offset", ctrl.size / 2.0)
	ctrl.scale = Vector2(0.2, 0.2)
	ctrl.modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(ctrl, "scale", Vector2.ONE, 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(ctrl, "modulate:a", 1.0, 0.3)

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
	# Fade-in de la escena completa
	if s is CanvasItem:
		(s as CanvasItem).modulate.a = 0.0
		create_tween().tween_property(s, "modulate:a", 1.0, 0.3)

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
		var b := _ob_btns[i] as Button
		b.pressed.connect(_ob_sel.bind(i))
		# Escudo de la patrulla como icono del botón
		var escudo_tex := load("res://assets/shields/shield_%s_v1.png" % PATRULLAS[i]) as Texture2D
		if escudo_tex:
			b.icon = escudo_tex
			b.add_theme_constant_override("icon_max_width", 40)
		_boton_estilo(b, COL_CREMA, COL_CAFE_OSC)
	# Nota: El botón es manejado por onboarding.gd para validar con Firebase
	# No conectar aquí para evitar conflictos con la validación de scout

	# Scouts de bienvenida en las esquinas inferiores
	for datos in [["scout_boy_v1", true], ["scout_girl_v1", false]]:
		var tex := load("res://assets/sprites/%s.png" % datos[0]) as Texture2D
		if tex == null:
			continue
		var tr := TextureRect.new()
		tr.texture = tex
		tr.expand_mode = 3
		tr.stretch_mode = 6
		if datos[1]:
			tr.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
			tr.offset_left = 16.0
			tr.offset_right = 166.0
		else:
			tr.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
			tr.offset_left = -166.0
			tr.offset_right = -16.0
		tr.offset_top = -206.0
		tr.offset_bottom = -16.0
		s.add_child(tr)
		_animar_pop(tr)
	print("SceneRouter: onboarding listo")

func _ob_on_nombre(_t: String) -> void:
	if _ob_ni == null:
		return
	_ob_bi.disabled = _ob_ni.text.strip_edges().length() < 2 or _patrulla_idx < 0

func _ob_sel(idx: int) -> void:
	print("SceneRouter: patrulla=", idx)
	_patrulla_idx = idx
	for j in _ob_btns.size():
		var b := _ob_btns[j] as Button
		if j == idx:
			_boton_estilo(b, COL_FOGATA, COL_CAFE_OSC)
		else:
			_boton_estilo(b, COL_CREMA, COL_CAFE_OSC)
	_ob_bi.disabled = _ob_ni.text.strip_edges().length() < 2

# ── mapa ─────────────────────────────────────────────────────────────────────

func _init_mapa(s: Node) -> void:
	print("SceneRouter: _init_mapa s=", s)
	# Fondo ilustrado + velo oscuro para mantener legible la senda
	var fondo_tex := load("res://assets/backgrounds/Fondo_Mapa_Senda1.png") as Texture2D
	if fondo_tex:
		var fondo := TextureRect.new()
		fondo.texture = fondo_tex
		fondo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		fondo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
		s.add_child(fondo)
		s.move_child(fondo, 1)
		var velo := ColorRect.new()
		velo.color = Color(0.04, 0.10, 0.06, 0.55)
		velo.set_anchors_preset(Control.PRESET_FULL_RECT)
		s.add_child(velo)
		s.move_child(velo, 2)
	var nombre_lbl := s.get_node("Header/NombreLabel") as Label
	_mp_xp_lbl    = s.get_node("Header/XpLabel")      as Label
	_mp_rango_lbl = s.get_node("Header/RangoLabel")   as Label
	var perfil_btn := s.get_node("Header/PerfilBoton") as Button
	var scroll     := s.get_node("ScrollContainer") as ScrollContainer
	var senda      := s.get_node("ScrollContainer/Senda") as Control

	nombre_lbl.text    = "%s - Patrulla %s" % [GameState.nombre_scout, GameState.patrulla]
	_mp_xp_lbl.text    = "%d XP" % GameState.xp
	_mp_rango_lbl.text = GameState.rango

	perfil_btn.pressed.connect(func(): _ir_a("perfil"))

	# Escudo de patrulla en el header
	var header := s.get_node("Header") as HBoxContainer
	var shield_tex := load("res://assets/shields/shield_%s_v1.png" % GameState.patrulla) as Texture2D
	if shield_tex:
		var escudo := TextureRect.new()
		escudo.texture = shield_tex
		escudo.custom_minimum_size = Vector2(52, 52)
		escudo.expand_mode = 3
		escudo.stretch_mode = 6
		header.add_child(escudo)
		header.move_child(escudo, 0)

	# ── Senda serpenteante ──
	var ancho: float = get_tree().root.get_visible_rect().size.x - 24.0
	var btn_w := 220.0
	var btn_h := 90.0
	var paso_y := 128.0
	var x_frac := [0.16, 0.5, 0.84, 0.5]

	var centros: Array[Vector2] = []
	for i in CAPITULOS.size():
		var cx: float = clamp(x_frac[i % 4] * ancho, btn_w / 2.0 + 10.0, ancho - btn_w / 2.0 - 10.0)
		centros.append(Vector2(cx, 70.0 + i * paso_y))
	senda.custom_minimum_size = Vector2(0, centros[centros.size() - 1].y + btn_h)

	# Camino de tierra que conecta los capítulos
	var linea := Line2D.new()
	linea.width = 10.0
	linea.default_color = Color(COL_CAFE, 0.9)
	linea.joint_mode = Line2D.LINE_JOINT_ROUND
	linea.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linea.end_cap_mode = Line2D.LINE_CAP_ROUND
	for c in centros:
		linea.add_point(c)
	senda.add_child(linea)

	var y_actual := 0.0
	for i in CAPITULOS.size():
		var cap: Dictionary = CAPITULOS[i]
		var num: int = cap["num"] as int
		var desbloqueado := GameState.capitulo_desbloqueado(num)
		var completado: bool = num in GameState.capitulos_completados
		var actual := desbloqueado and not completado

		var card_num := "%02d" % num
		var card_tex := load("res://assets/images/tarjetas_capitulos/cap_%s_%s.png" % [card_num, "desbloqueada" if desbloqueado else "bloqueada"]) as Texture2D
		var btn := TextureButton.new()
		btn.custom_minimum_size = Vector2(btn_w, btn_h)
		btn.size = Vector2(btn_w, btn_h)
		btn.position = centros[i] - Vector2(btn_w, btn_h) / 2.0
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_SCALE
		if card_tex:
			btn.texture_normal = card_tex
		if desbloqueado:
			btn.pressed.connect(ir_a_capitulo.bind(num))
		else:
			btn.pressed.connect(func(): _mp_toast(s, "Completa el capítulo anterior para desbloquear este"))
		if actual:
			y_actual = centros[i].y
		senda.add_child(btn)

		if actual:
			# Pulso del capítulo actual
			btn.pivot_offset = Vector2(btn_w, btn_h) / 2.0
			var tw := btn.create_tween().set_loops()
			tw.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tw.tween_property(btn, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		if completado:
			# Insignia ganada sobre la esquina del nodo
			var badge_tex := load("res://assets/badges/badge_cap%d_v1.png" % num) as Texture2D
			if badge_tex:
				var tr := TextureRect.new()
				tr.texture = badge_tex
				tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				tr.custom_minimum_size = Vector2(46, 46)
				tr.position = btn.position + Vector2(btn_w - 32.0, -16.0)
				senda.add_child(tr)
				tr.size = Vector2(46, 46)
				if num == _ultimo_cap_completado:
					_animar_pop(tr)
					_ultimo_cap_completado = 0

	# Centrar el scroll en el capítulo actual
	if y_actual > 0.0:
		scroll.set_deferred("scroll_vertical", int(max(0.0, y_actual - 220.0)))

	if not GameState.xp_changed.is_connected(_mp_on_xp):
		GameState.xp_changed.connect(_mp_on_xp)
	print("SceneRouter: mapa listo")

func _mp_toast(s: Node, mensaje: String) -> void:
	var toast := s.get_node_or_null("ToastBloqueado") as Label
	if toast == null:
		toast = Label.new()
		toast.name = "ToastBloqueado"
		toast.add_theme_font_size_override("font_size", 16)
		toast.add_theme_color_override("font_color", Color(1.0, 0.9, 0.7))
		toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		toast.anchor_left = 0.0
		toast.anchor_right = 1.0
		toast.anchor_top = 1.0
		toast.anchor_bottom = 1.0
		toast.offset_left = 20.0
		toast.offset_right = -20.0
		toast.offset_top = -80.0
		toast.offset_bottom = -16.0
		s.add_child(toast)
	toast.text = mensaje
	toast.modulate = Color(1, 1, 1, 1)
	var tw := toast.create_tween()
	tw.tween_interval(2.0)
	tw.tween_property(toast, "modulate:a", 0.0, 0.5)

func _mp_on_xp(nuevo_xp: int) -> void:
	if _mp_xp_lbl:
		_mp_xp_lbl.text = "%d XP" % nuevo_xp
		# Destello dorado al ganar XP
		_mp_xp_lbl.modulate = Color(1.6, 1.35, 0.6)
		create_tween().tween_property(_mp_xp_lbl, "modulate", Color.WHITE, 0.7)
	if _mp_rango_lbl: _mp_rango_lbl.text = GameState.rango

# ─────────────────────────────────────────────────────────────────────────────

# ── capitulo ─────────────────────────────────────────────────────────────────

var _cap_s: Node = null
var _cap_escenas: Array = []
var _cap_preguntas: Array = []
var _cap_escena_idx: int = 0
var _cap_quiz_idx: int = 0
var _cap_correctas: int = 0
var _cap_estado: int = 0  # 0=jugando, 1=aprobado, 2=reprobado, 3=examen aprobado (pend. ceremonia)
var _tw_texto: Tween = null

# examen final integrador (cap 12)
var _examen_final: bool = false
var _ceremonia_vinetas: Array = []
var _en_ceremonia: bool = false

# validacion por codigo (caps 11-12)
var _codigo_tipo: String = ""

# mini-juego (escena tipo "juego" con datos estructurados)
var _jg_escena: Dictionary = {}
var _jg_decision_idx: int = 0
var _jg_bio_idx: int = 0

# Pop de insignia: se setea al completar capítulo, se consume en _init_mapa
var _ultimo_cap_completado: int = 0

# Ken Burns animation mode
var _anim_vinetas: Array = []
var _anim_vineta_idx: int = 0
var _anim_tw: Tween = null
var _anim_icono_tw: Tween = null

# Texto con efecto máquina de escribir
func _texto_typewriter(lbl: RichTextLabel, texto: String) -> void:
	if _tw_texto and _tw_texto.is_valid():
		_tw_texto.kill()
	lbl.text = texto
	lbl.visible_ratio = 0.0
	var dur: float = clamp(texto.length() * 0.018, 0.4, 2.2)
	_tw_texto = create_tween()
	_tw_texto.tween_property(lbl, "visible_ratio", 1.0, dur)

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

func _cargar_banco_examen(n: int) -> Array:
	# Junta las preguntas de los 12 capitulos y devuelve n al azar (nuevas cada intento)
	var banco: Array = []
	for cap in range(1, 13):
		var f := FileAccess.open("res://capitulos/%02d/preguntas.json" % cap, FileAccess.READ)
		if f == null:
			continue
		var d = JSON.parse_string(f.get_as_text())
		f.close()
		if typeof(d) != TYPE_DICTIONARY:
			continue
		for q in d.get("preguntas", []):
			if q.get("distractores", null) != null:
				banco.append(q)
	banco.shuffle()
	if n > 0 and banco.size() > n:
		banco = banco.slice(0, n)
	return banco

func _cap_mostrar_escena(idx: int) -> void:
	_cap_escena_idx = idx
	_anim_vinetas = []  # limpiar estado de animación al cambiar escena
	var s := _cap_s
	var titulo_lbl   := s.get_node("Header/TituloLabel") as Label
	var progreso_lbl := s.get_node("Header/ProgresoLabel") as Label
	var narr_panel   := s.get_node("ContenidoArea/NarracionPanel") as Control
	var quiz_panel   := s.get_node("ContenidoArea/QuizPanel") as Control
	var btn_sig      := s.get_node("Footer/BotonSiguiente") as Button
	var juego_panel  := s.get_node("ContenidoArea/JuegoPanel") as Control
	var anim_panel   := s.get_node_or_null("ContenidoArea/AnimacionPanel") as Control
	var codigo_panel := s.get_node_or_null("ContenidoArea/CodigoPanel") as Control
	var lamina_panel := s.get_node_or_null("ContenidoArea/LaminaPanel") as Control

	titulo_lbl.text = "Cap.%d — %s" % [_capitulo_activo, CAPITULOS[_capitulo_activo - 1]["nombre"]]
	progreso_lbl.text = "Escena %d / %d" % [idx + 1, _cap_escenas.size()]
	narr_panel.visible = false
	quiz_panel.visible = false
	juego_panel.visible = false
	if anim_panel:
		anim_panel.visible = false
	if codigo_panel:
		codigo_panel.visible = false
	if lamina_panel:
		lamina_panel.visible = false

	if idx >= _cap_escenas.size():
		return

	var escena: Dictionary = _cap_escenas[idx]
	var tipo: String = escena.get("tipo", "")

	if tipo == "lamina":
		_cap_estado = 0
		btn_sig.text = ""
		btn_sig.visible = true
		_mostrar_lamina(escena)
	elif tipo == "codigo":
		_cap_estado = 0
		btn_sig.text = ""
		btn_sig.visible = true
		_mostrar_codigo(escena)
	elif tipo == "evaluacion":
		btn_sig.visible = false
		_cap_quiz_idx = 0
		_cap_correctas = 0
		_examen_final = escena.get("examen_final", false)
		_ceremonia_vinetas = escena.get("ceremonia", [])
		if _examen_final:
			# Examen integrador: N preguntas al azar de los 12 capitulos, nuevas cada intento
			var n_preg: int = escena.get("num_preguntas", 20) as int
			_cap_preguntas = _cargar_banco_examen(n_preg)
		quiz_panel.visible = true
		_cap_mostrar_pregunta()
	elif tipo == "juego" and escena.has("decisiones"):
		# Mini-juego interactivo: decisiones + completar biografía
		btn_sig.visible = false
		juego_panel.visible = true
		_jg_iniciar(escena)
	elif tipo == "animacion" and escena.get("tecnica", "") == "ken_burns" and anim_panel != null:
		btn_sig.visible = false
		anim_panel.visible = true
		_anim_iniciar(escena)
	else:
		btn_sig.text = ""
		btn_sig.visible = true
		narr_panel.visible = true
		var personaje_lbl := s.get_node("ContenidoArea/NarracionPanel/PersonajeLabel") as Label
		var dialogo_lbl   := s.get_node("ContenidoArea/NarracionPanel/ContentRow/DialogoLabel") as RichTextLabel
		var imagen_rect   := s.get_node("ContenidoArea/NarracionPanel/ContentRow/ImagenRect") as TextureRect
		var texto := ""
		match tipo:
			"narracion":
				personaje_lbl.text = "Historia"
				texto = escena.get("dialogo_muestra", escena.get("contenido", ""))
				# Material de estudio ampliado (base: Bitácora)
				var estudio: String = escena.get("texto_estudio", "")
				if estudio != "":
					texto += "\n\n" + estudio
			"animacion":
				personaje_lbl.text = "Secuencia"
				texto = escena.get("contenido", "")
			"juego":
				personaje_lbl.text = "Actividad"
				texto = escena.get("contenido", "")
		# Personaliza el texto con el nombre del scout (ej. oracion de patrulla)
		texto = texto.replace("{nombre}", GameState.nombre_scout)
		_texto_typewriter(dialogo_lbl, texto)
		# Mostrar sprite del capítulo en narracion y animacion
		imagen_rect.scale = Vector2.ONE
		if tipo in ["narracion", "animacion"] and CAP_SPRITES.has(_capitulo_activo):
			var tex := load(CAP_SPRITES[_capitulo_activo]) as Texture2D
			if tex:
				imagen_rect.texture = tex
				imagen_rect.visible = true
				imagen_rect.modulate.a = 0.0
				create_tween().tween_property(imagen_rect, "modulate:a", 1.0, 0.4)
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
	# Intercept Ken Burns animation viñeta navigation
	if _anim_vinetas.size() > 0:
		_anim_vineta_idx += 1
		if _anim_vineta_idx < _anim_vinetas.size():
			_anim_mostrar_vineta()
		else:
			_anim_terminar()
		return
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
		3:
			_cap_estado = 0
			_lanzar_ceremonia()
		_:
			_cap_mostrar_escena(_cap_escena_idx + 1)

func _lanzar_ceremonia() -> void:
	var s := _cap_s
	(s.get_node("ContenidoArea/NarracionPanel") as Control).visible = false
	(s.get_node("ContenidoArea/QuizPanel") as Control).visible = false
	var anim_panel := s.get_node_or_null("ContenidoArea/AnimacionPanel") as Control
	if anim_panel == null or _ceremonia_vinetas.is_empty():
		_ir_a("mapa")
		return
	anim_panel.visible = true
	_en_ceremonia = true
	_anim_vinetas = _ceremonia_vinetas
	_anim_vineta_idx = 0
	_anim_mostrar_vineta()

func _ceremonia_final() -> void:
	var s := _cap_s
	var anim_panel := s.get_node_or_null("ContenidoArea/AnimacionPanel") as Control
	if anim_panel:
		anim_panel.visible = false
	var narr_panel    := s.get_node("ContenidoArea/NarracionPanel") as Control
	var btn_sig       := s.get_node("Footer/BotonSiguiente") as Button
	var personaje_lbl := s.get_node("ContenidoArea/NarracionPanel/PersonajeLabel") as Label
	var dialogo_lbl   := s.get_node("ContenidoArea/NarracionPanel/ContentRow/DialogoLabel") as RichTextLabel
	var imagen_rect   := s.get_node("ContenidoArea/NarracionPanel/ContentRow/ImagenRect") as TextureRect
	narr_panel.visible = true
	personaje_lbl.text = "¡Investidura!"
	_texto_typewriter(dialogo_lbl, "[b]%s[/b], ya eres [color=#F2A93B]candidato a la investidura[/color].\n\nLo que sigue lo vives ante tu Tropa. ¡Bienvenido a la hermandad mundial! ¡Siempre Listo!" % GameState.nombre_scout)
	var badge_tex := load("res://assets/badges/badge_cap12_v1.png") as Texture2D
	if badge_tex and imagen_rect:
		imagen_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		imagen_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		imagen_rect.texture = badge_tex
		imagen_rect.visible = true
		_animar_pop(imagen_rect)
	btn_sig.text = "Volver al Mapa"
	btn_sig.visible = true
	_cap_estado = 1

# ── Ken Burns: secuencia de viñetas con paneo/zoom ──────────────────────────

func _anim_iniciar(escena: Dictionary) -> void:
	_anim_vinetas = escena.get("vinetas", [])
	_anim_vineta_idx = 0
	if _anim_vinetas.is_empty():
		_cap_mostrar_escena(_cap_escena_idx + 1)
		return
	_anim_mostrar_vineta()

func _anim_mostrar_vineta() -> void:
	var vineta: Dictionary = _anim_vinetas[_anim_vineta_idx]
	var s := _cap_s
	var anim_panel  := s.get_node("ContenidoArea/AnimacionPanel") as Control
	var fondo       := anim_panel.get_node("FondoKenBurns")  as TextureRect
	var titulo_lbl  := anim_panel.get_node("InfoBox/TituloVineta") as Label
	var desc_lbl    := anim_panel.get_node("InfoBox/DescVineta")   as RichTextLabel
	var contador_lbl := anim_panel.get_node("ContadorVineta")      as Label
	var icono_lbl   := anim_panel.get_node("IconoVineta")          as Label
	var btn_sig     := s.get_node("Footer/BotonSiguiente")         as Button

	# Texto
	titulo_lbl.text = vineta.get("titulo", "")
	_texto_typewriter(desc_lbl, vineta.get("descripcion", ""))
	icono_lbl.text = vineta.get("icono", "")

	# Contador de puntos (●/○)
	var n := _anim_vinetas.size()
	var puntos := ""
	for i in n:
		puntos += ("● " if i == _anim_vineta_idx else "○ ")
	contador_lbl.text = puntos.strip_edges()

	# Sprite como ilustración de fondo
	if CAP_SPRITES.has(_capitulo_activo):
		var tex := load(CAP_SPRITES[_capitulo_activo]) as Texture2D
		if tex:
			fondo.texture = tex

	# Tinte diferente por viñeta para distinguirlas visualmente
	var tintes: Dictionary = {
		"warm":   Color(1.0,  0.97, 0.85),
		"cool":   Color(0.88, 0.93, 1.0),
		"fire":   Color(1.0,  0.88, 0.78),
		"nature": Color(0.88, 1.0,  0.88),
	}
	var tinte: Color = tintes.get(vineta.get("tinte", "warm"), Color.WHITE)
	fondo.modulate = tinte
	fondo.modulate.a = 0.0
	fondo.scale = Vector2.ONE
	fondo.position = Vector2.ZERO

	if _anim_tw and _anim_tw.is_valid():
		_anim_tw.kill()
	if _anim_icono_tw and _anim_icono_tw.is_valid():
		_anim_icono_tw.kill()

	var es_ultima: bool = (_anim_vineta_idx >= _anim_vinetas.size() - 1)
	btn_sig.text = ""
	btn_sig.visible = true

	# Defer para que el layout compute el tamaño antes de animar
	call_deferred("_anim_start_kb", vineta.get("movimiento", "zoom_in"))

func _anim_start_kb(movimiento: String) -> void:
	if _cap_s == null or not is_instance_valid(_cap_s):
		return
	var anim_panel := _cap_s.get_node_or_null("ContenidoArea/AnimacionPanel") as Control
	if anim_panel == null:
		return
	var fondo     := anim_panel.get_node("FondoKenBurns") as TextureRect
	var icono_lbl := anim_panel.get_node("IconoVineta")   as Label

	fondo.pivot_offset = fondo.size / 2.0

	_anim_tw = create_tween().set_parallel(true)
	_anim_tw.tween_property(fondo, "modulate:a", 1.0, 0.5)

	match movimiento:
		"zoom_in":
			fondo.scale = Vector2.ONE
			fondo.position = Vector2.ZERO
			_anim_tw.tween_property(fondo, "scale", Vector2(1.18, 1.18), 4.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		"pan_horizontal":
			fondo.scale = Vector2(1.06, 1.06)
			fondo.position = Vector2(-20, 0)
			_anim_tw.tween_property(fondo, "position", Vector2(20, 0), 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		"zoom_horizonte":
			fondo.scale = Vector2.ONE
			fondo.position = Vector2.ZERO
			_anim_tw.tween_property(fondo, "scale",    Vector2(1.14, 1.14), 4.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			_anim_tw.tween_property(fondo, "position", Vector2(0, -14),     4.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		"zoom_out":
			fondo.scale = Vector2(1.18, 1.18)
			fondo.position = Vector2.ZERO
			_anim_tw.tween_property(fondo, "scale", Vector2.ONE, 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_:
			fondo.scale = Vector2.ONE

	# Elemento aislado: icono que pulsa en loop
	_anim_icono_tw = icono_lbl.create_tween().set_loops()
	_anim_icono_tw.tween_property(icono_lbl, "modulate:a", 0.45, 0.9)
	_anim_icono_tw.tween_property(icono_lbl, "modulate:a", 1.0,  0.9)

func _anim_terminar() -> void:
	if _anim_tw and _anim_tw.is_valid():
		_anim_tw.kill()
	if _anim_icono_tw and _anim_icono_tw.is_valid():
		_anim_icono_tw.kill()
	_anim_vinetas = []
	_anim_vineta_idx = 0
	if _en_ceremonia:
		_en_ceremonia = false
		_ceremonia_final()
		return
	# XP por ver la animación completa
	var primera_vez := GameState.marcar_escena_vista(_capitulo_activo, _cap_escena_idx)
	if primera_vez:
		var xp: int = _cap_escenas[_cap_escena_idx].get("xp", 0) as int
		if xp > 0:
			GameState.dar_xp(xp)
	_cap_mostrar_escena(_cap_escena_idx + 1)

# ── mini-juego: decisiones "¿Qué haría B.P.?" + completar biografía ─────────

func _jg_nodos() -> Dictionary:
	return {
		"titulo":   _cap_s.get_node("ContenidoArea/JuegoPanel/JuegoTitulo") as Label,
		"texto":    _cap_s.get_node("ContenidoArea/JuegoPanel/JuegoTexto") as RichTextLabel,
		"opciones": _cap_s.get_node("ContenidoArea/JuegoPanel/JuegoOpciones") as VBoxContainer,
		"banco":    _cap_s.get_node("ContenidoArea/JuegoPanel/JuegoBanco") as HFlowContainer,
		"retro":    _cap_s.get_node("ContenidoArea/JuegoPanel/JuegoRetro") as Label,
	}

func _jg_limpiar(n: Dictionary) -> void:
	var op_node := n["opciones"] as Node
	for c in op_node.get_children():
		op_node.remove_child(c)
		c.queue_free()
	var banco_node := n["banco"] as Node
	for c in banco_node.get_children():
		banco_node.remove_child(c)
		c.queue_free()
	(n["retro"] as Label).visible = false

func _jg_iniciar(escena: Dictionary) -> void:
	_jg_escena = escena
	_jg_decision_idx = 0
	_jg_bio_idx = 0
	_jg_mostrar_decision()

func _jg_mostrar_decision() -> void:
	var decisiones: Array = _jg_escena.get("decisiones", [])
	if _jg_decision_idx >= decisiones.size():
		_jg_mostrar_biografia()
		return
	var n := _jg_nodos()
	_jg_limpiar(n)
	(n["titulo"] as Label).text = "%s (%d/%d)" % [str(_jg_escena.get("titulo_decision", "¿Qué harías?")), _jg_decision_idx + 1, decisiones.size()]
	_texto_typewriter(n["texto"] as RichTextLabel, str(decisiones[_jg_decision_idx].get("situacion", "")))
	for op in decisiones[_jg_decision_idx].get("opciones", []):
		var btn := Button.new()
		btn.text = str(op.get("texto", ""))
		btn.custom_minimum_size = Vector2(0, 56)
		btn.add_theme_font_size_override("font_size", 18)
		_boton_estilo(btn, COL_CREMA, COL_CAFE_OSC)
		btn.pressed.connect(_jg_responder.bind(op, btn))
		(n["opciones"] as Node).add_child(btn)

func _jg_responder(op: Dictionary, btn: Button) -> void:
	var n := _jg_nodos()
	var retro := n["retro"] as Label
	retro.text = str(op.get("retro", ""))
	retro.visible = true
	if op.get("correcta", false):
		_boton_estilo(btn, COL_VERDE, COL_CREMA)
		retro.add_theme_color_override("font_color", Color(0.55, 0.95, 0.55))
		for c in (n["opciones"] as Node).get_children():
			(c as Button).disabled = true
		# XP por decisión (Fase2: +10 c/u, solo la primera vez)
		if GameState.marcar_escena_vista(_capitulo_activo, 100 + _jg_decision_idx):
			GameState.dar_xp(10)
		_jg_decision_idx += 1
		get_tree().create_timer(1.8).timeout.connect(_jg_mostrar_decision, CONNECT_ONE_SHOT)
	else:
		# Incorrecta: retro + permite reintentar con la otra opción
		_boton_estilo(btn, COL_ROJO, COL_CREMA)
		btn.disabled = true
		retro.add_theme_color_override("font_color", Color(1.0, 0.55, 0.5))

func _jg_mostrar_biografia() -> void:
	var bio: Dictionary = _jg_escena.get("biografia", {})
	if bio.is_empty():
		_jg_terminar()
		return
	var n := _jg_nodos()
	_jg_limpiar(n)
	(n["titulo"] as Label).text = str(bio.get("titulo", "Completa las frases clave"))
	_jg_bio_idx = 0
	_jg_render_biografia(n)
	var palabras: Array = []
	for r in bio.get("respuestas", []):
		palabras.append(str(r))
	for d in bio.get("distractores", []):
		palabras.append(str(d))
	palabras.shuffle()
	for p in palabras:
		var btn := Button.new()
		btn.text = str(p)
		btn.custom_minimum_size = Vector2(0, 48)
		btn.add_theme_font_size_override("font_size", 17)
		_boton_estilo(btn, COL_CREMA, COL_CAFE_OSC)
		btn.pressed.connect(_jg_palabra.bind(str(p), btn))
		(n["banco"] as Node).add_child(btn)

func _jg_render_biografia(n: Dictionary) -> void:
	if _tw_texto and _tw_texto.is_valid():
		_tw_texto.kill()
	(n["texto"] as RichTextLabel).visible_ratio = 1.0
	var bio: Dictionary = _jg_escena.get("biografia", {})
	var texto: String = str(bio.get("plantilla", ""))
	var respuestas: Array = bio.get("respuestas", [])
	for i in respuestas.size():
		var marca := "[%d]" % (i + 1)
		if i < _jg_bio_idx:
			texto = texto.replace(marca, "[color=#F2A93B][b]%s[/b][/color]" % str(respuestas[i]))
		elif i == _jg_bio_idx:
			texto = texto.replace(marca, "[color=#F2A93B][b]______[/b][/color]")
		else:
			texto = texto.replace(marca, "______")
	(n["texto"] as RichTextLabel).text = texto

func _jg_palabra(palabra: String, btn: Button) -> void:
	var bio: Dictionary = _jg_escena.get("biografia", {})
	var respuestas: Array = bio.get("respuestas", [])
	var n := _jg_nodos()
	var retro := n["retro"] as Label
	if _jg_bio_idx < respuestas.size() and palabra == str(respuestas[_jg_bio_idx]):
		_jg_bio_idx += 1
		btn.visible = false
		retro.visible = false
		_jg_render_biografia(n)
		if _jg_bio_idx >= respuestas.size():
			# Biografía completada (Fase2: +20, solo la primera vez)
			if GameState.marcar_escena_vista(_capitulo_activo, 200):
				GameState.dar_xp(20)
			retro.text = "¡Biografía completada! +20 XP"
			retro.add_theme_color_override("font_color", COL_FOGATA)
			retro.visible = true
			_jg_terminar()
	else:
		retro.text = "Ese dato no va en el espacio resaltado. ¡Intenta con otro!"
		retro.add_theme_color_override("font_color", Color(1.0, 0.55, 0.5))
		retro.visible = true
		_boton_estilo(btn, COL_ROJO, COL_CREMA)
		get_tree().create_timer(0.6).timeout.connect(_jg_reset_palabra.bind(btn), CONNECT_ONE_SHOT)

func _jg_reset_palabra(btn: Button) -> void:
	if is_instance_valid(btn):
		_boton_estilo(btn, COL_CREMA, COL_CAFE_OSC)

func _jg_terminar() -> void:
	var btn_sig := _cap_s.get_node("Footer/BotonSiguiente") as Button
	btn_sig.text = ""
	btn_sig.visible = true

# ── lamina: imagen grande con titulo y pie (ej. diagrama del uniforme) ──────

func _mostrar_lamina(escena: Dictionary) -> void:
	var s := _cap_s
	var panel := s.get_node_or_null("ContenidoArea/LaminaPanel") as Control
	if panel == null:
		_cap_mostrar_escena(_cap_escena_idx + 1)
		return
	panel.visible = true
	var titulo := panel.get_node("LaminaTitulo") as Label
	var img := panel.get_node("LaminaImagen") as TextureRect
	var caption := panel.get_node("LaminaCaption") as RichTextLabel
	titulo.text = str(escena.get("titulo", ""))
	titulo.visible = titulo.text != ""
	caption.text = str(escena.get("descripcion", ""))
	caption.visible = caption.text != ""
	var tex: Texture2D = null
	var ruta := str(escena.get("imagen", ""))
	if ruta != "":
		tex = load(ruta) as Texture2D
	if tex:
		img.texture = tex
		img.visible = true
		img.modulate.a = 0.0
		create_tween().tween_property(img, "modulate:a", 1.0, 0.4)
	else:
		img.visible = false
	if GameState.marcar_escena_vista(_capitulo_activo, _cap_escena_idx):
		var xp: int = escena.get("xp", 0) as int
		if xp > 0:
			GameState.dar_xp(xp)

# ── validacion por codigo (caps 11-12) ─────────────────────────────────────

func _mostrar_codigo(escena: Dictionary) -> void:
	var s := _cap_s
	var panel := s.get_node_or_null("ContenidoArea/CodigoPanel") as Control
	if panel == null:
		# Escena de codigo sin panel (export viejo): no bloquear, avanzar
		_cap_mostrar_escena(_cap_escena_idx + 1)
		return
	panel.visible = true
	_codigo_tipo = str(escena.get("validacion", ""))
	var titulo := panel.get_node("Titulo") as Label
	var instr := panel.get_node("Instruccion") as RichTextLabel
	var input := panel.get_node("CodigoInput") as LineEdit
	var btn := panel.get_node("BotonValidar") as Button
	var estado := panel.get_node("EstadoLabel") as Label

	titulo.text = str(escena.get("titulo", "Validación"))
	instr.text = str(escena.get("instruccion", ""))
	input.text = ""
	input.editable = true
	btn.disabled = false
	btn.text = "Validar código"
	estado.visible = false
	estado.remove_theme_color_override("font_color")

	if not btn.pressed.is_connected(_on_validar_codigo):
		btn.pressed.connect(_on_validar_codigo)

	# XP por llegar a la escena (una vez)
	if GameState.marcar_escena_vista(_capitulo_activo, _cap_escena_idx):
		var xp: int = escena.get("xp", 0) as int
		if xp > 0:
			GameState.dar_xp(xp)

	FirebaseSync.ensure_scout_context(GameState.scout_id)
	_codigo_check_estado(_codigo_tipo)

func _codigo_check_estado(tipo: String) -> void:
	var res = await FirebaseSync.obtener_validacion(tipo)
	if not is_instance_valid(_cap_s):
		return
	var panel := _cap_s.get_node_or_null("ContenidoArea/CodigoPanel") as Control
	if panel == null or not panel.visible or _codigo_tipo != tipo:
		return
	var estado := panel.get_node("EstadoLabel") as Label
	if not res.get("ok", false):
		return  # sin conexion: dejar que el scout intente igual
	if res.get("aprobado", false):
		_codigo_bloquear_ok(panel, "Ya validado por tu dirigente ✓")
	elif not res.get("existe", false):
		estado.add_theme_color_override("font_color", Color(0.85, 0.85, 0.6))
		estado.text = "Aún no hay código. Pídeselo a tu dirigente cuando aprueben tu requisito; puedes continuar y volver luego."
		estado.visible = true

func _on_validar_codigo() -> void:
	var panel := _cap_s.get_node_or_null("ContenidoArea/CodigoPanel") as Control
	if panel == null:
		return
	var input := panel.get_node("CodigoInput") as LineEdit
	var btn := panel.get_node("BotonValidar") as Button
	var estado := panel.get_node("EstadoLabel") as Label
	var codigo := input.text.strip_edges()
	if codigo.is_empty():
		estado.remove_theme_color_override("font_color")
		estado.add_theme_color_override("font_color", Color(1.0, 0.6, 0.4))
		estado.text = "Escribe el código que te dio tu dirigente."
		estado.visible = true
		return
	btn.disabled = true
	btn.text = "Validando..."
	estado.visible = false
	FirebaseSync.ensure_scout_context(GameState.scout_id)
	var res = await FirebaseSync.verificar_codigo(_codigo_tipo, codigo)
	if not is_instance_valid(panel) or not panel.visible:
		return
	if res.get("ok", false):
		_codigo_bloquear_ok(panel, "¡Validado! Requisito aprobado ✓")
		SaveManager.guardar()
	else:
		btn.disabled = false
		btn.text = "Validar código"
		estado.remove_theme_color_override("font_color")
		estado.add_theme_color_override("font_color", Color(1.0, 0.55, 0.5))
		match str(res.get("error", "")):
			"no_coincide": estado.text = "El código no coincide. Verifícalo con tu dirigente."
			"sin_codigo":  estado.text = "Aún no hay código generado. Pídeselo a tu dirigente."
			"no_scout":    estado.text = "Conéctate a internet e inicia sesión para validar."
			_:             estado.text = "No se pudo validar. Revisa tu conexión e intenta de nuevo."
		estado.visible = true

func _codigo_bloquear_ok(panel: Control, msg: String) -> void:
	var input := panel.get_node("CodigoInput") as LineEdit
	var btn := panel.get_node("BotonValidar") as Button
	var estado := panel.get_node("EstadoLabel") as Label
	input.editable = false
	btn.disabled = true
	btn.text = "Validado ✓"
	estado.remove_theme_color_override("font_color")
	estado.add_theme_color_override("font_color", Color(0.55, 0.95, 0.55))
	estado.text = msg
	estado.visible = true

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
	var _dist = q.get("distractores", [])
	if _dist is Array:
		for d in _dist:
			var dt := str(d).strip_edges()
			if dt.length() > 0:
				opciones.append(dt)
	else:
		for d in str(_dist).split("|"):
			var dt := d.strip_edges()
			if dt.length() > 0:
				opciones.append(dt)
	opciones.shuffle()

	for opcion in opciones:
		var btn := Button.new()
		btn.text = str(opcion)
		btn.custom_minimum_size = Vector2(0, 52)
		btn.add_theme_font_size_override("font_size", 18)
		_boton_estilo(btn, COL_CREMA, COL_CAFE_OSC)
		btn.pressed.connect(_cap_responder.bind(str(opcion), correcta, resultado_lbl, opciones_box, btn))
		opciones_box.add_child(btn)

func _cap_responder(opcion: String, correcta: String, resultado_lbl: Label, opciones_box: VBoxContainer, btn: Button) -> void:
	for child in opciones_box.get_children():
		var c := child as Button
		c.disabled = true
		if c.text == correcta:
			_boton_estilo(c, COL_VERDE, COL_CREMA)
	if opcion == correcta:
		_cap_correctas += 1
		resultado_lbl.text = "¡Correcto!"
		resultado_lbl.add_theme_color_override("font_color", Color(0.55, 0.95, 0.55))
	else:
		_boton_estilo(btn, COL_ROJO, COL_CREMA)
		resultado_lbl.text = "Incorrecto. Era: " + correcta
		resultado_lbl.add_theme_color_override("font_color", Color(1.0, 0.55, 0.5))
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
	var dialogo_lbl   := s.get_node("ContenidoArea/NarracionPanel/ContentRow/DialogoLabel") as RichTextLabel
	var imagen_rect   := s.get_node("ContenidoArea/NarracionPanel/ContentRow/ImagenRect") as TextureRect

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
		_ultimo_cap_completado = _capitulo_activo
		GameState.dar_xp(xp_ganado)
		SaveManager.guardar()
		personaje_lbl.text = "¡Capítulo completado!"
		var badge_tex := load("res://assets/badges/badge_cap%d_v1.png" % _capitulo_activo) as Texture2D
		if badge_tex and imagen_rect:
			imagen_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			imagen_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			imagen_rect.texture = badge_tex
			imagen_rect.visible = true
			_animar_pop(imagen_rect)
		if _examen_final and _ceremonia_vinetas.size() > 0:
			_cap_estado = 3  # aprobado; pendiente ver la Gran Ceremonia
			btn_sig.text = "Ver la Gran Ceremonia"
			_texto_typewriter(dialogo_lbl, "[b]%d/%d correctas (%.0f%%)[/b]\n\n¡Aprobaste el Examen Final! Ganaste [color=#F2A93B]%d XP[/color].\n\nPresiona para vivir tu Gran Ceremonia." % [_cap_correctas, total, pct, xp_ganado])
		else:
			btn_sig.text = "Volver al Mapa"
			_texto_typewriter(dialogo_lbl, "[b]%d/%d correctas (%.0f%%)[/b]\n\nHas completado el capítulo y ganado [color=#F2A93B]%d XP[/color]. ¡Ganaste la insignia del capítulo!" % [_cap_correctas, total, pct, xp_ganado])
	else:
		_cap_estado = 2
		btn_sig.text = "Reintentar"
		personaje_lbl.text = "Sigue intentando"
		_texto_typewriter(dialogo_lbl, "[b]%d/%d correctas (%.0f%%)[/b]\n\nNecesitas al menos %.0f%%. Puedes intentarlo de nuevo." % [_cap_correctas, total, pct, min_pct])

# ── perfil ───────────────────────────────────────────────────────────────────

var _pf_borrar_confirmando: bool = false

func _init_perfil(s: Node) -> void:
	(s.get_node("VBox/NombreLabel")    as Label).text = "Scout: %s" % GameState.nombre_scout
	(s.get_node("VBox/PatrullaLabel")  as Label).text = "Patrulla: %s" % GameState.patrulla
	(s.get_node("VBox/RangoLabel")     as Label).text = "Rango: %s" % GameState.rango
	(s.get_node("VBox/XpLabel")        as Label).text = "XP total: %d" % GameState.xp
	(s.get_node("VBox/InsigniasLabel") as Label).text = "Capitulos completados: %d / 12" % GameState.capitulos_completados.size()

	# Grid de insignias ganadas
	var vbox := s.get_node("VBox") as VBoxContainer
	if GameState.capitulos_completados.size() > 0:
		var grid_ins := GridContainer.new()
		grid_ins.columns = 6
		grid_ins.add_theme_constant_override("h_separation", 8)
		grid_ins.add_theme_constant_override("v_separation", 8)
		for num in GameState.capitulos_completados:
			var n := num as int
			var badge_tex := load("res://assets/badges/badge_cap%d_v1.png" % n) as Texture2D
			if badge_tex:
				var tr := TextureRect.new()
				tr.texture = badge_tex
				tr.custom_minimum_size = Vector2(60, 60)
				tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tr.stretch_mode = 6
				tr.tooltip_text = "Cap.%d" % n
				grid_ins.add_child(tr)
				_animar_pop(tr)
		vbox.add_child(grid_ins)
		vbox.move_child(grid_ins, vbox.get_children().find(s.get_node("VBox/InsigniasLabel")) + 1)

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
