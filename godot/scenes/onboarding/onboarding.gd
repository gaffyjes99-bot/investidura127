extends Control

const PATRULLAS := ["Jaguares", "Lobos", "Mapaches", "Pandas"]

@onready var nombre_input: LineEdit = $VBox/NombreInput
@onready var patrulla_option: OptionButton = $VBox/PatrullaOption
@onready var boton_iniciar: Button = $VBox/BotonIniciar
@onready var error_label: Label = $VBox/ErrorLabel

func _ready() -> void:
	for p in PATRULLAS:
		patrulla_option.add_item(p)
	boton_iniciar.pressed.connect(_on_iniciar)
	nombre_input.text_changed.connect(_on_nombre_cambiado)
	error_label.visible = false

func _on_nombre_cambiado(texto: String) -> void:
	boton_iniciar.disabled = texto.strip_edges().length() < 2

func _on_iniciar() -> void:
	var nombre := nombre_input.text.strip_edges()
	if nombre.length() < 2:
		error_label.text = "Escribe tu nombre scout (mínimo 2 letras)"
		error_label.visible = true
		return

	GameState.nombre_scout = nombre
	GameState.patrulla = PATRULLAS[patrulla_option.selected]
	SaveManager.guardar()
	SceneRouter.ir_a("mapa")
