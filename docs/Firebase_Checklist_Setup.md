# Checklist de Configuración — Firebase Firestore + Godot

**Proyecto:** fichas-actividad-scout (Grupo 127)  
**Fase:** 7 — Persistencia de progreso

---

## 1. Credenciales Firebase ✓

- [ ] Acceder a https://console.firebase.google.com/
- [ ] Seleccionar proyecto **fichas-actividad-scout**
- [ ] Ir a **Configuración del proyecto** (⚙️)
- [ ] Copiar credenciales web:
  - [ ] `apiKey`: ___________________________________
  - [ ] `projectId`: ___________________________________
  - [ ] `authDomain`: ___________________________________

---

## 2. Actualizar godot/firebase_config.gd

- [ ] Abrir `godot/firebase_config.gd`
- [ ] Reemplazar `API_KEY = "AIzaSyD_placeholder_..."` con la clave real
- [ ] Reemplazar `AUTH_DOMAIN` si es diferente de `fichas-actividad-scout.firebaseapp.com`
- [ ] Verificar que `PROJECT_ID = "fichas-actividad-scout"` ✓
- [ ] Guardar archivo

```gdscript
# godot/firebase_config.gd — líneas a reemplazar

const API_KEY = "AIzaSyD_[YOUR_REAL_API_KEY]"
const AUTH_DOMAIN = "fichas-actividad-scout.firebaseapp.com"
```

---

## 3. Reglas de Firestore

- [ ] Ir a Firebase Console → Firestore Database → **Rules**
- [ ] Verificar modo actual:
  - [ ] **Modo de prueba?** → Acceso abierto ✓ (listo para usar)
  - [ ] **Modo de producción?** → Agregar estas reglas:

```
match /libro_interactivo_progreso/{document=**} {
  allow read: if true;
  allow write: if request.auth == null;
  allow create: if request.resource.data.keys().hasAll(['grupoId', 'scoutId', 'nombre']);
  allow update: if true;
}
```

- [ ] Publicar reglas (Deploy)

---

## 4. Configurar Godot project.godot

- [ ] Abrir `godot/project.godot`
- [ ] Buscar sección `[autoload]`
- [ ] Agregar entrada para FirebaseSync:

```
[autoload]
FirebaseSync="res://scripts/firebase_sync.gd"
```

- [ ] Guardar y recargar proyecto Godot

---

## 5. Crear estructura de carpetas

- [ ] Verificar que existe `godot/scripts/` (crear si no existe)
- [ ] Verificar que `firebase_sync.gd` está en `godot/scripts/`
- [ ] Verificar que `firebase_config.gd` está en `godot/`

```
godot/
├── firebase_config.gd          ✓ Creado
└── scripts/
    └── firebase_sync.gd        ✓ Creado
```

---

## 6. Integración en escenas Godot

### 6.1 Escena de OnBoarding/Login

- [ ] Abrir `godot/scenes/onboarding/onboarding.gd`
- [ ] Agregar conexión de señales en `_ready()`:

```gdscript
func _ready() -> void:
	FirebaseSync.scout_found.connect(_on_scout_found)
	FirebaseSync.scout_not_found.connect(_on_scout_not_found)
	# ... más señales (ver Firebase_Ejemplos_Integracion.gd)
```

- [ ] Agregar manejadores de señales (copiar de `Firebase_Ejemplos_Integracion.gd`)
- [ ] Probar login con nombre de scout real

### 6.2 Escena principal del libro

- [ ] Abrir `godot/scenes/libro/libro.gd` (o escena equivalente)
- [ ] Conectar señales de progreso en `_ready()`
- [ ] Agregar llamadas a `FirebaseSync.push_scout_data()` después de:
  - [ ] Completar capítulo
  - [ ] Completar quiz
  - [ ] Validar buena acción / campamento / etc.

### 6.3 Quiz

- [ ] Abrir `godot/scenes/mecanicas/quiz.gd`
- [ ] En función `_on_quiz_finished()`, agregar:

```gdscript
func _on_quiz_finished() -> void:
	var score = calculate_score()
	var xp_earned = int(score / 10)
	# Notificar al libro
	get_tree().root.get_child(0)._on_quiz_completed(chapter_id, score, xp_earned)
```

---

## 7. Pruebas iniciales

### 7.1 Test de búsqueda fuzzy

- [ ] Exportar proyecto Godot o ejecutar en editor
- [ ] Abrir escena de login
- [ ] Ingresa nombre de scout (ej: "Carlos López"):
  - [ ] ✓ Scout encontrado (1 coincidencia)
  - [ ] ✓ Múltiples coincidencias (si hay ambigüedad)
  - [ ] ✓ Scout no encontrado (con nombre aleatorio)

### 7.2 Test de descarga de progreso

- [ ] Scout ingresa login correctamente
- [ ] Verificar en Firestore Console:
  - [ ] ✓ Documento existe en colección `libro_interactivo_progreso`
  - [ ] ✓ ID del documento es `127_[scoutId]`
  - [ ] ✓ Campos iniciales están presentes

### 7.3 Test de sincronización

- [ ] Scout completa un capítulo o quiz
- [ ] Verificar en Firestore Console:
  - [ ] ✓ `xp_total` se actualiza
  - [ ] ✓ `ultima_actualizacion` se actualiza
  - [ ] ✓ `capitulos_completados` se agrega

### 7.4 Test offline

- [ ] Desactivar conexión de internet (DevTools → Network off)
- [ ] Scout intenta completar actividad
- [ ] Verificar:
  - [ ] ✓ Icono "Sincronizando..." aparece
  - [ ] ✓ App sigue funcionando offline
  - [ ] ✓ Cambios se guardan en buffer local
- [ ] Restaurar conexión de internet
- [ ] Verificar:
  - [ ] ✓ Cambios se sincronizan automáticamente

### 7.5 Test cambio de dispositivo

- [ ] Scout completa actividades en Dispositivo A
- [ ] Abrir app en Dispositivo B
- [ ] Scout ingresa mismo nombre + patrulla
- [ ] Verificar:
  - [ ] ✓ Scout encontrado
  - [ ] ✓ Progreso descargado (XP, capítulos completados, etc.)
  - [ ] ✓ Datos de Dispositivo A aparecen en Dispositivo B

---

## 8. Logging y debugging

- [ ] Habilitar Output en Godot (Debug → Monitor)
- [ ] Ejecutar app y verificar mensajes:

```
[FirebaseSync] Cambios sincronizados a Firestore: ...
✓ Scout encontrado: ...
✓ Progreso cargado para scout
```

- [ ] En navegador (web export):
  - [ ] Abrir DevTools (F12)
  - [ ] Ir a Network tab
  - [ ] Filtrar por `firestore.googleapis.com`
  - [ ] Verificar requests GET/PATCH exitosos (status 200)

---

## 9. Optimizaciones (opcional)

- [ ] Ajustar `SYNC_INTERVAL_SECONDS` si es necesario:
  - Aumentar a 10-15s para reduce load
  - Mantener en 5s para sync casi-real-time

- [ ] Agregar animación de "sincronizando" en UI

- [ ] Configurar notificaciones push para validaciones (Fase 9)

---

## 10. Documentación

- [ ] ✓ Leer `Firebase_Especificacion_Tecnica.md` (especificación)
- [ ] ✓ Leer `Firebase_Integracion_Godot.md` (guía de integración)
- [ ] ✓ Revisar `Firebase_Ejemplos_Integracion.gd` (código ejemplo)
- [ ] ✓ Seguir este checklist (setup)

---

## 11. Problemas comunes

| Problema | Solución |
|----------|----------|
| "Scout no encontrado" | Verificar nombre exacto en colección `scouts`. Mín. 80% similitud (Levenshtein). |
| "Error 404" | Primer acceso? Normal — documento se crea automáticamente. |
| "Cambios no se sincronizan" | Verificar API Key en firebase_config.gd. Verificar reglas Firestore. |
| "Request blocked" | CORS? Firebase REST API no requiere CORS. Verificar URL endpoint. |
| "Performance lento" | Reducir SYNC_INTERVAL_SECONDS. Revisar conexión de internet. |

---

## 12. Contacto y soporte

- **Especificación técnica:** `Firebase_Especificacion_Tecnica.md`
- **Guía de integración:** `Firebase_Integracion_Godot.md`
- **Código ejemplo:** `Firebase_Ejemplos_Integracion.gd`
- **API Keys:** Revisar en https://console.firebase.google.com/

---

## Checklist final ✓

- [ ] API Key actualizada en firebase_config.gd
- [ ] Proyecto Godot recargado
- [ ] Reglas Firestore configuradas
- [ ] Escena login integrando FirebaseSync
- [ ] Escena libro integrando sincronización
- [ ] Quiz sincronizando datos
- [ ] Tests manuales pasados (búsqueda, descarga, sync, offline, multi-device)
- [ ] Logs verificados
- [ ] Documentación leída

**Status:** _______________  
**Fecha:** _______________  
**Equipo:** _______________

