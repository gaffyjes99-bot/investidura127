extends Control

const MECANICA_QUIZ := "res://scenes/mecanicas/quiz.tscn"

var _num: int = 0
var _info: Dictionary = {}
var _escena_actual: int = 0  # 0=narracion, 1=animacion, 2=juego, 3=evaluacion

@onready var titulo_label: Label = $Header/TituloLabel
@onready var progreso_label: Label = $Header/ProgresoLabel
@onready var contenido_area: Control = $ContenidoArea
@onready var boton_siguiente: Button = $Footer/BotonSiguiente
@onready var boton_mapa: Button = $Footer/BotonMapa
@onready var narracion_panel: Control = $ContenidoArea/NarracionPanel
@onready var personaje_label: Label = $ContenidoArea/NarracionPanel/PersonajeLabel
@onready var dialogo_label: RichTextLabel = $ContenidoArea/NarracionPanel/DialogoLabel

func _ready() -> void:
	_num = SceneRouter.get_capitulo_activo()
	_cargar_info()
	boton_siguiente.pressed.connect(_on_siguiente)
	boton_mapa.pressed.connect(func(): SceneRouter.ir_a("mapa"))
	_mostrar_escena(0)

func _cargar_info() -> void:
	var f := FileAccess.open("res://capitulos/%02d/escenas.json" % _num, FileAccess.READ)
	if f:
		_info = JSON.parse_string(f.get_as_text())
		f.close()
	else:
		# Fallback: datos inline para Cap.1 si el archivo no carga
		_info = {"capitulo": _num, "nombre": "Capítulo %d" % _num, "escenas": []}

	titulo_label.text = "%s — %s" % [_num, _info.get("nombre", "")]

func _nombre_carpeta(n: int) -> String:
	var nombres := {
		1: "el_origen_del_fuego", 2: "el_codigo_del_explorador",
		3: "mi_palabra_de_honor",  4: "las_raices",
		5: "los_simbolos_de_la_hermandad", 6: "el_uniforme_del_aventurero",
		7: "la_buena_accion",      8: "el_lenguaje_de_la_tropa",
		9: "formaciones_y_bordon", 10: "mi_tropa_mi_familia",
		11: "la_prueba_del_campista", 12: "la_gran_ceremonia"
	}
	return nombres.get(n, "")

func _mostrar_escena(idx: int) -> void:
	_escena_actual = idx
	var escenas: Array = _info.get("escenas", [])
	progreso_label.text = "Escena %d / %d" % [idx + 1, escenas.size()]

	# Ocultar todos los paneles
	for hijo in contenido_area.get_children():
		hijo.visible = false

	if idx >= escenas.size():
		_capitulo_terminado()
		return

	var escena: Dictionary = escenas[idx]
	var tipo: String = escena.get("tipo", "")

	# Dar XP por primera vez
	var es_primera := GameState.marcar_escena_vista(_num, idx)
	if es_primera:
		GameState.dar_xp(escena.get("xp", 5))
		SaveManager.guardar()

	match tipo:
		"narracion":
			_mostrar_narracion(escena)
		"animacion":
			_mostrar_narracion(escena)  # placeholder: misma UI hasta tener animaciones
		"juego":
			_mostrar_narracion(escena)  # placeholder
		"evaluacion":
			_iniciar_evaluacion()
		_:
			_mostrar_narracion(escena)

func _mostrar_narracion(escena: Dictionary) -> void:
	narracion_panel.visible = true
	var narrador: String = _info.get("narrador", "Narrador")
	personaje_label.text = narrador
	var contenido: String = escena.get("dialogo_muestra", escena.get("contenido", ""))
	dialogo_label.text = contenido
	boton_siguiente.text = "Siguiente →"
	boton_siguiente.disabled = false

func _iniciar_evaluacion() -> void:
	# Cargar la escena de quiz como hijo dinámico
	var quiz_scene := load(MECANICA_QUIZ) as PackedScene
	if quiz_scene == null:
		_mostrar_narracion({"dialogo_muestra": "Evaluación no disponible aún."})
		return

	var quiz := quiz_scene.instantiate()
	contenido_area.add_child(quiz)
	quiz.setup(_num)
	quiz.evaluacion_terminada.connect(_on_evaluacion_terminada)
	boton_siguiente.disabled = true

func _on_evaluacion_terminada(aprobado: bool, porcentaje: float) -> void:
	if aprobado:
		GameState.completar_capitulo(_num)
		SaveManager.guardar()
		boton_siguiente.text = "¡Capítulo completado! →"
	else:
		boton_siguiente.text = "Reintentar evaluación"
	boton_siguiente.disabled = false

func _capitulo_terminado() -> void:
	boton_siguiente.text = "Volver al Mapa"
	boton_siguiente.pressed.disconnect(_on_siguiente)
	boton_siguiente.pressed.connect(func(): SceneRouter.ir_a("mapa"))

func _on_siguiente() -> void:
	_mostrar_escena(_escena_actual + 1)
