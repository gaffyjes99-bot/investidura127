extends Control

signal scout_selected(scout_id: String, name: String, patrol: String)
signal canceled

@onready var scouts_list: VBoxContainer = $DialogPanel/VBox/ScrollContainer/ScoutsList
@onready var cancel_btn: Button = $DialogPanel/VBox/ButtonsPanel/CancelBtn

var _current_matches: Array[Dictionary] = []

func _ready() -> void:
	cancel_btn.pressed.connect(_on_cancel)

func show_matches(matches: Array[Dictionary]) -> void:
	"""Muestra lista de scouts para que el usuario seleccione uno."""
	_current_matches = matches

	# Limpiar lista anterior
	for child in scouts_list.get_children():
		child.queue_free()

	# Crear botón para cada coincidencia
	for match in matches:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 56)

		var text = "%s (%s) — %d%% similitud" % [
			match["nombre"],
			match["patrulla"],
			int(match["similarity"] * 100)
		]
		btn.text = text
		btn.theme_override_font_sizes["font_size"] = 14

		# Conectar señal con el índice del scout
		var index = scouts_list.get_child_count()
		btn.pressed.connect(func(): _on_scout_selected(index))

		scouts_list.add_child(btn)

	# Mostrar diálogo
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP

func _on_scout_selected(index: int) -> void:
	"""Maneja la selección de un scout."""
	if index >= 0 and index < _current_matches.size():
		var match = _current_matches[index]
		scout_selected.emit(match["scout_id"], match["nombre"], match["patrulla"])
		hide()

func _on_cancel() -> void:
	"""Cancela la selección."""
	canceled.emit()
	hide()

func _input(event: InputEvent) -> void:
	"""Cierra el diálogo al presionar ESC."""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_on_cancel()
			get_tree().root.set_input_as_handled()
