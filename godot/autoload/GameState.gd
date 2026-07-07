extends Node

signal xp_changed(nuevo_xp: int)
signal rango_changed(nuevo_rango: String)
signal capitulo_completado(num: int)

const RANGOS := [
	{"nombre": "Pietierno",   "xp_min": 0},
	{"nombre": "Aspirante",   "xp_min": 200},
	{"nombre": "Rastreador",  "xp_min": 500},
	{"nombre": "Campista",    "xp_min": 900},
	{"nombre": "Explorador",  "xp_min": 1400},
	{"nombre": "Candidato",   "xp_min": 2000},
]

var nombre_scout: String = ""
var patrulla: String = ""         # Jaguares | Lobos | Mapaches | Pandas
var scout_id: String = ""         # ID del scout en Firestore (validado en login)
var xp: int = 0
var rango: String = "Pietierno"
var capitulos_completados: Array[int] = []
var insignias: Array[int] = []    # números de capítulo cuya insignia se desbloqueó
var escenas_vistas: Dictionary = {}  # "cap_escena" -> true

func dar_xp(cantidad: int) -> void:
	xp += cantidad
	emit_signal("xp_changed", xp)
	_actualizar_rango()

func _actualizar_rango() -> void:
	var nuevo := "Pietierno"
	for r in RANGOS:
		if xp >= r["xp_min"]:
			nuevo = r["nombre"]
	if nuevo != rango:
		rango = nuevo
		emit_signal("rango_changed", rango)

func marcar_escena_vista(capitulo: int, escena: int) -> bool:
	var clave := "%d_%d" % [capitulo, escena]
	if escenas_vistas.has(clave):
		return false
	escenas_vistas[clave] = true
	return true  # true = primera vez (dar XP)

func completar_capitulo(num: int) -> void:
	if num not in capitulos_completados:
		capitulos_completados.append(num)
		if num not in insignias:
			insignias.append(num)
		emit_signal("capitulo_completado", num)

func capitulo_desbloqueado(num: int) -> bool:
	if num == 1:
		return true
	return (num - 1) in capitulos_completados

func esta_configurado() -> bool:
	return nombre_scout != ""
