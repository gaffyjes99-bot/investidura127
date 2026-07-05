extends Control

const PATRULLAS := ["Jaguares", "Lobos", "Mapaches", "Pandas"]

@onready var nombre_input:  LineEdit = $VBox/NombreInput
@onready var boton_iniciar: Button   = $VBox/BotonIniciar
@onready var error_label:   Label    = $VBox/ErrorLabel
@onready var btn_jaguares:  Button   = $VBox/PatrullasGrid/BtnJaguares
@onready var btn_lobos:     Button   = $VBox/PatrullasGrid/BtnLobos
@onready var btn_mapaches:  Button   = $VBox/PatrullasGrid/BtnMapaches
@onready var btn_pandas:    Button   = $VBox/PatrullasGrid/BtnPandas

var _patrulla_idx: int = -1

func _ready() -> void:
	print("onboarding _ready START")
	print("btn_jaguares=", btn_jaguares, " btn_lobos=", btn_lobos)
	btn_jaguares.pressed.connect(func(): _sel(0))
	btn_lobos.pressed.connect(func(): _sel(1))
	btn_mapaches.pressed.connect(func(): _sel(2))
	btn_pandas.pressed.connect(func(): _sel(3))
	boton_iniciar.pressed.connect(_on_iniciar)
	nombre_input.text_changed.connect(_on_nombre_cambiado)
	error_label.visible = false
	print("onboarding _ready DONE")

func _on_nombre_cambiado(_t: String) -> void:
	_check()

func _sel(idx: int) -> void:
	print("patrulla idx=", idx)
	_patrulla_idx = idx
	btn_jaguares.modulate = Color(0.3, 1.0, 0.4) if idx == 0 else Color(1, 1, 1)
	btn_lobos.modulate    = Color(0.3, 1.0, 0.4) if idx == 1 else Color(1, 1, 1)
	btn_mapaches.modulate = Color(0.3, 1.0, 0.4) if idx == 2 else Color(1, 1, 1)
	btn_pandas.modulate   = Color(0.3, 1.0, 0.4) if idx == 3 else Color(1, 1, 1)
	_check()

func _check() -> void:
	var ok := nombre_input.text.strip_edges().length() >= 2 and _patrulla_idx >= 0
	boton_iniciar.disabled = not ok

func _on_iniciar() -> void:
	var nombre := nombre_input.text.strip_edges()
	if nombre.length() < 2 or _patrulla_idx < 0:
		error_label.text = "Completa nombre y patrulla"
		error_label.visible = true
		return
	GameState.nombre_scout = nombre
	GameState.patrulla = PATRULLAS[_patrulla_idx]
	SaveManager.guardar()
	SceneRouter.ir_a("mapa")
