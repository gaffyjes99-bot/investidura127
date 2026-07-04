extends Node

const ESCENAS := {
	"main":        "res://scenes/main.tscn",
	"onboarding":  "res://scenes/onboarding/onboarding.tscn",
	"mapa":        "res://scenes/mapa/mapa_senda.tscn",
	"capitulo":    "res://scenes/capitulo/capitulo.tscn",
	"perfil":      "res://scenes/perfil/perfil.tscn",
}

var _capitulo_activo: int = 0

func _ready() -> void:
	# AutoLoad se inicializa antes que la escena principal.
	# call_deferred garantiza que el engine está completamente listo.
	call_deferred("_ruta_inicial")

func _ruta_inicial() -> void:
	print("SceneRouter: _ruta_inicial")
	var hay_save := SaveManager.cargar()
	print("SceneRouter: hay_save=", hay_save)
	if hay_save and GameState.esta_configurado():
		ir_a("mapa")
	else:
		ir_a("onboarding")

func ir_a(nombre: String) -> void:
	print("SceneRouter: ir_a ", nombre)
	var err := get_tree().change_scene_to_file(ESCENAS[nombre])
	if err != OK:
		push_error("SceneRouter: no se pudo cargar " + ESCENAS[nombre] + " err=" + str(err))

func ir_a_capitulo(num: int) -> void:
	_capitulo_activo = num
	var err := get_tree().change_scene_to_file(ESCENAS["capitulo"])
	if err != OK:
		push_error("SceneRouter: no se pudo cargar capitulo err=" + str(err))

func get_capitulo_activo() -> int:
	return _capitulo_activo
