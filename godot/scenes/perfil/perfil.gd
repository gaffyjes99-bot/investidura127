extends Control

@onready var nombre_label: Label = $VBox/NombreLabel
@onready var patrulla_label: Label = $VBox/PatrullaLabel
@onready var rango_label: Label = $VBox/RangoLabel
@onready var xp_label: Label = $VBox/XpLabel
@onready var insignias_label: Label = $VBox/InsigniasLabel
@onready var boton_mapa: Button = $VBox/BotonMapa
@onready var boton_borrar: Button = $VBox/BotonBorrar

func _ready() -> void:
	nombre_label.text = "Scout: %s" % GameState.nombre_scout
	patrulla_label.text = "Patrulla: %s" % GameState.patrulla
	rango_label.text = "Rango: %s" % GameState.rango
	xp_label.text = "XP total: %d" % GameState.xp
	insignias_label.text = "Insignias: %d / 12" % GameState.insignias.size()
	boton_mapa.pressed.connect(func(): SceneRouter.ir_a("mapa"))
	boton_borrar.pressed.connect(_on_borrar)

func _on_borrar() -> void:
	SaveManager.borrar()
	GameState.nombre_scout = ""
	GameState.patrulla = ""
	GameState.xp = 0
	GameState.rango = "Pietierno"
	GameState.capitulos_completados = []
	GameState.insignias = []
	GameState.escenas_vistas = {}
	SceneRouter.ir_a("onboarding")
