extends Node

# ============================================================================
# Configuración Firebase — Firestore REST API
# Proyecto: fichas-actividad-scout (Grupo 127)
# ============================================================================

# Credenciales — OBTENER DE: https://console.firebase.google.com/
# Proyecto > Configuración del proyecto > Tu app > Credenciales web
class_name FirebaseConfig

# TODO: Reemplazar con valores reales del proyecto fichas-actividad-scout
const API_KEY = "AIzaSyBPFCRvhezdhz27OzPbZJijlOVKLnzKNo4"
const PROJECT_ID = "fichas-actividad-scout"
const AUTH_DOMAIN = "fichas-actividad-scout.firebaseapp.com"

const GRUPO_ID = "127"

# Firestore REST API endpoints
const FIRESTORE_API_BASE = "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents"
const FIRESTORE_PROGRESO_COLLECTION = "libro_interactivo_progreso"

# Nombres de colecciones existentes (para búsqueda de scouts)
const SCOUTS_COLLECTION = "scouts"

# Configuración de sincronización
const SYNC_INTERVAL_SECONDS = 5.0  # Reintentar cada 5 segundos
const SYNC_TIMEOUT_SHOW_UI_SECONDS = 10.0  # Mostrar "sincronizando..." después de 10s

# Búsqueda fuzzy
const MIN_SIMILARITY_THRESHOLD = 0.80  # 80% de similitud mínima

static func get_progreso_endpoint(doc_id: String) -> String:
	return FIRESTORE_API_BASE % PROJECT_ID + "/%s/%s?key=%s" % [
		FIRESTORE_PROGRESO_COLLECTION,
		doc_id,
		API_KEY
	]

static func get_scouts_endpoint() -> String:
	return FIRESTORE_API_BASE % PROJECT_ID + "/%s?key=%s" % [
		SCOUTS_COLLECTION,
		API_KEY
	]

# Estructura por defecto para un nuevo documento de progreso
static func get_default_progress_data(scout_id: String, nombre: String, patrulla: String) -> Dictionary:
	var now_ms = int(Time.get_ticks_msec())
	return {
		"fields": {
			"grupoId": {"stringValue": GRUPO_ID},
			"scoutId": {"stringValue": scout_id},
			"nombre": {"stringValue": nombre},
			"patrulla": {"stringValue": patrulla},
			"creado_en": {"timestampValue": _ms_to_iso8601(now_ms)},
			"ultima_actualizacion": {"timestampValue": _ms_to_iso8601(now_ms)},
			"rango": {"stringValue": "Pietierno"},
			"xp_total": {"integerValue": "0"},
			"capitulos_completados": {"arrayValue": {"values": []}},
			"capitulos_detalle": {"mapValue": {"fields": {}}},
			"validaciones": {"mapValue": {"fields": {
				"buenas_acciones": {"integerValue": "0"},
				"noches_campamento": {"integerValue": "0"},
				"meses_participacion": {"integerValue": "0"},
				"comportamiento_hogar": {"mapValue": {"fields": {
					"aprobado": {"booleanValue": false},
					"codigo_validacion": {"nullValue": {}},
					"fecha_validacion": {"nullValue": {}},
					"aprobado_por": {"nullValue": {}}
				}}},
				"rendimiento_academico": {"mapValue": {"fields": {
					"aprobado": {"booleanValue": false},
					"codigo_validacion": {"nullValue": {}},
					"fecha_validacion": {"nullValue": {}},
					"aprobado_por": {"nullValue": {}}
				}}}
			}}},
			"insignias_desbloqueadas": {"arrayValue": {"values": []}},
			"morral_coleccionables": {"arrayValue": {"values": []}}
		}
	}

static func _ms_to_iso8601(ms: int) -> String:
	var seconds = ms / 1000
	var remaining_ms = ms % 1000
	var dt = Time.get_datetime_dict_from_system()

	# Simple conversion (nota: en producción usar librería más robusta)
	var year = dt["year"]
	var month = dt["month"]
	var day = dt["day"]
	var hour = dt["hour"]
	var minute = dt["minute"]
	var second = dt["second"]

	return "%04d-%02d-%02dT%02d:%02d:%02d.%03dZ" % [year, month, day, hour, minute, second, remaining_ms]
