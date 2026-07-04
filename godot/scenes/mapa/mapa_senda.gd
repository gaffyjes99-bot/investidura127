extends Control

const CAPITULOS := [
	{"num": 1,  "nombre": "El Origen del Fuego",        "emoji": "🔥"},
	{"num": 2,  "nombre": "El Código del Explorador",   "emoji": "⚖️"},
	{"num": 3,  "nombre": "Mi Palabra de Honor",        "emoji": "🤝"},
	{"num": 4,  "nombre": "Las Raíces",                 "emoji": "🌳"},
	{"num": 5,  "nombre": "Los Símbolos",               "emoji": "⚜️"},
	{"num": 6,  "nombre": "El Uniforme",                "emoji": "🎽"},
	{"num": 7,  "nombre": "La Buena Acción",            "emoji": "💚"},
	{"num": 8,  "nombre": "El Lenguaje de la Tropa",    "emoji": "📯"},
	{"num": 9,  "nombre": "Formaciones y Bordón",       "emoji": "🥾"},
	{"num": 10, "nombre": "Mi Tropa, Mi Familia",       "emoji": "🐾"},
	{"num": 11, "nombre": "La Prueba del Campista",     "emoji": "⛺"},
	{"num": 12, "nombre": "La Gran Ceremonia",          "emoji": "🏅"},
]

@onready var nombre_label: Label = $Header/NombreLabel
@onready var xp_label: Label = $Header/XpLabel
@onready var rango_label: Label = $Header/RangoLabel
@onready var grid: GridContainer = $ScrollContainer/Grid
@onready var perfil_boton: Button = $Header/PerfilBoton

func _ready() -> void:
	_actualizar_header()
	_poblar_grid()
	GameState.xp_changed.connect(_on_xp_changed)
	perfil_boton.pressed.connect(func(): SceneRouter.ir_a("perfil"))

func _actualizar_header() -> void:
	nombre_label.text = "%s • Patrulla %s" % [GameState.nombre_scout, GameState.patrulla]
	xp_label.text = "⭐ %d XP" % GameState.xp
	rango_label.text = GameState.rango

func _on_xp_changed(nuevo_xp: int) -> void:
	xp_label.text = "⭐ %d XP" % nuevo_xp
	rango_label.text = GameState.rango

func _poblar_grid() -> void:
	for cap in CAPITULOS:
		var boton := Button.new()
		boton.custom_minimum_size = Vector2(180, 120)
		var desbloqueado := GameState.capitulo_desbloqueado(cap["num"])
		var completado := cap["num"] in GameState.capitulos_completados
		boton.text = "%s\n%s\n%s" % [cap["emoji"], cap["num"], cap["nombre"]]
		boton.disabled = not desbloqueado
		if completado:
			boton.modulate = Color(0.6, 1.0, 0.6, 1)
		elif not desbloqueado:
			boton.modulate = Color(0.4, 0.4, 0.4, 1)
		var num := cap["num"]
		boton.pressed.connect(func(): _ir_a_capitulo(num))
		grid.add_child(boton)

func _ir_a_capitulo(num: int) -> void:
	SceneRouter.ir_a_capitulo(num)
