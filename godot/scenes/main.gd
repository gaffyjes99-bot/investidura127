extends Control

func _ready() -> void:
	var hay_save := SaveManager.cargar()
	if hay_save and GameState.esta_configurado():
		SceneRouter.ir_a("mapa")
	else:
		SceneRouter.ir_a("onboarding")
