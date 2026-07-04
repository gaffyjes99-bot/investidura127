extends Control

signal evaluacion_terminada(aprobado: bool, porcentaje: float)

const MIN_APROBAR := 0.80
const XP_APROBAR := 30
const XP_PERFECTO_BONUS := 15

var _preguntas: Array = []
var _idx: int = 0
var _correctas: int = 0
var _respondida: bool = false

@onready var pregunta_label: RichTextLabel = $VBox/PreguntaLabel
@onready var opciones_vbox: VBoxContainer = $VBox/OpcionesVBox
@onready var feedback_label: Label = $VBox/FeedbackLabel
@onready var progreso_label: Label = $VBox/ProgresoLabel
@onready var boton_continuar: Button = $VBox/BotonContinuar

func _ready() -> void:
	boton_continuar.pressed.connect(_on_continuar)
	boton_continuar.visible = false
	feedback_label.visible = false

func setup(capitulo: int) -> void:
	var path := "res://capitulos/%02d/preguntas.json" % capitulo
	var f := FileAccess.open(path, FileAccess.READ)
	if f:
		var datos = JSON.parse_string(f.get_as_text())
		f.close()
		_preguntas = datos.get("preguntas", [])
	_preguntas.shuffle()
	if _preguntas.size() > 10:
		_preguntas = _preguntas.slice(0, 10)
	_mostrar_pregunta()

func _mostrar_pregunta() -> void:
	if _idx >= _preguntas.size():
		_terminar()
		return

	_respondida = false
	var p: Dictionary = _preguntas[_idx]
	pregunta_label.text = "[b]%d / %d[/b]\n\n%s" % [_idx + 1, _preguntas.size(), p["pregunta"]]
	progreso_label.text = "%d correctas de %d" % [_correctas, _idx]
	feedback_label.visible = false
	boton_continuar.visible = false

	# Limpiar opciones anteriores
	for hijo in opciones_vbox.get_children():
		hijo.queue_free()

	# Construir lista de opciones
	var opciones: Array[String] = []
	opciones.append(p["respuesta_correcta"])
	if p.get("distractores") and p["distractores"] != null:
		for d in str(p["distractores"]).split("|"):
			var dt := d.strip_edges()
			if dt != "":
				opciones.append(dt)
	opciones.shuffle()

	for opcion in opciones:
		var btn := Button.new()
		btn.text = opcion
		btn.custom_minimum_size = Vector2(0, 52)
		btn.add_theme_font_size_override("font_size", 18)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var correcta: String = p["respuesta_correcta"]
		btn.pressed.connect(func(): _responder(btn, opcion, correcta))
		opciones_vbox.add_child(btn)

func _responder(btn_pulsado: Button, elegida: String, correcta: String) -> void:
	if _respondida:
		return
	_respondida = true

	# Deshabilitar todos los botones
	for hijo in opciones_vbox.get_children():
		hijo.disabled = true

	if elegida == correcta:
		_correctas += 1
		btn_pulsado.modulate = Color(0.3, 1.0, 0.3, 1)
		feedback_label.text = "✅ ¡Correcto!"
		feedback_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.2, 1))
	else:
		btn_pulsado.modulate = Color(1.0, 0.3, 0.3, 1)
		# Resaltar la correcta
		for hijo in opciones_vbox.get_children():
			if hijo.text == correcta:
				hijo.modulate = Color(0.3, 1.0, 0.3, 1)
		feedback_label.text = "❌ La respuesta correcta era: %s" % correcta
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.3, 1))

	feedback_label.visible = true
	boton_continuar.visible = true
	boton_continuar.text = "Siguiente →" if _idx < _preguntas.size() - 1 else "Ver resultado"

func _on_continuar() -> void:
	_idx += 1
	_mostrar_pregunta()

func _terminar() -> void:
	var pct: float = float(_correctas) / float(_preguntas.size()) if _preguntas.size() > 0 else 0.0
	var aprobado := pct >= MIN_APROBAR

	for hijo in opciones_vbox.get_children():
		hijo.queue_free()

	if aprobado:
		GameState.dar_xp(XP_APROBAR)
		if _correctas == _preguntas.size():
			GameState.dar_xp(XP_PERFECTO_BONUS)
		progreso_label.text = "✅ Aprobado: %d / %d (%.0f%%)" % [_correctas, _preguntas.size(), pct * 100]
		feedback_label.text = "¡Excelente trabajo, %s!" % GameState.nombre_scout
		feedback_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3, 1))
		pregunta_label.text = "[b]¡Campamento completado![/b]\n\nObtuviste %d de %d respuestas correctas." % [_correctas, _preguntas.size()]
	else:
		progreso_label.text = "❌ %d / %d (%.0f%%) — Mínimo 80%%" % [_correctas, _preguntas.size(), pct * 100]
		feedback_label.text = "Puedes intentarlo de nuevo. ¡Tú puedes!"
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3, 1))
		pregunta_label.text = "[b]Resultado[/b]\n\nObtuviste %d de %d. Necesitas 80%% para avanzar." % [_correctas, _preguntas.size()]

	feedback_label.visible = true
	boton_continuar.visible = false
	emit_signal("evaluacion_terminada", aprobado, pct)
