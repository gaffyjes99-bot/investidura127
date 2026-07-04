extends Node

const ESCENAS := {
	"main":        "res://scenes/main.tscn",
	"onboarding":  "res://scenes/onboarding/onboarding.tscn",
	"mapa":        "res://scenes/mapa/mapa_senda.tscn",
	"capitulo":    "res://scenes/capitulo/capitulo.tscn",
	"perfil":      "res://scenes/perfil/perfil.tscn",
}

var _capitulo_activo: int = 0

func ir_a(nombre: String) -> void:
	assert(ESCENAS.has(nombre), "Escena desconocida: " + nombre)
	get_tree().change_scene_to_file(ESCENAS[nombre])

func ir_a_capitulo(num: int) -> void:
	_capitulo_activo = num
	get_tree().change_scene_to_file(ESCENAS["capitulo"])

func get_capitulo_activo() -> int:
	return _capitulo_activo
