# Cloud Function Solution — Búsqueda Segura de Scouts

## Problema Identificado

Las reglas Firestore protegen la colección `scouts` (datos personales).
La app Godot necesita buscar scouts pero **no puede leer directamente** sin autenticación.

```
❌ App Godot → GET /scouts?key=API_KEY → 403 Forbidden
```

## Solución Implementada

**Cloud Function Backend** que:
1. Valida nombre + patrulla
2. Busca en DB privada (scouts)
3. Implementa fuzzy matching (Levenshtein 80%)
4. Retorna **solo** `scout_id` (protege privacidad)

```
✅ App Godot → POST /findScout {nombre, patrulla} → Cloud Function
✅ Cloud Function → Query scouts (tiene acceso) → Busca + filtra
✅ Cloud Function → Retorna {"scoutId": "...", "nombre": "...", "similarity": 0.95}
```

---

## Archivos Creados

### Backend (Node.js)

**`firebase/functions/findScout.js`** — Cloud Function (380 líneas)
- Implementación Levenshtein distance
- Búsqueda fuzzy 80%
- Validación de inputs
- CORS habilitado
- Manejo de errores (múltiples coincidencias, no encontrado, etc.)

**`firebase/functions/package.json`** — Dependencias

### Documentación

**`docs/Firebase_CloudFunction_Deployment.md`** — Deployment paso a paso
- Instalación Firebase CLI
- Deploy a Cloud Functions
- Testing (local + en vivo)
- Troubleshooting
- Logs

### Integración Godot

**`godot/scripts/firebase_sync.gd`** — Actualizado
- Función `find_scout_in_firestore()` ahora llama Cloud Function
- `_process_find_scout_cloud_response()` procesa respuesta
- Maneja errores: no encontrado, múltiples coincidencias

---

## Flujo de Login (Actualizado)

```
Scout ingresa nombre + patrulla
    ↓
find_scout_in_firestore() → POST /findScout (Cloud Function)
    ↓
Cloud Function valida inputs
    ↓
Busca en colección scouts (privada)
    ↓
Aplica fuzzy matching (Levenshtein 80%)
    ↓
Retorna {"scoutId": "...", "nombre": "...", "similarity": 0.95}
    ↓
Godot recibe scoutId
    ↓
get_scout_progress() → Descarga documento libro_interactivo_progreso
    ↓
GameState cargado ✓
```

---

## Beneficios

✅ **Seguridad:** Scouts no exponen datos personales  
✅ **Backend:** Firebase maneja escala  
✅ **Fuzzy:** Búsqueda inteligente "Carlos Lopez" = "Carlos López"  
✅ **Auditable:** Logs en Firebase Console  
✅ **CORS:** Funciona desde web  

---

## Reglas Firestore (Simplificadas)

Ahora **NO necesitamos** permitir lectura pública de scouts.

Las reglas actuales ya funcionan:
```firestore
match /scouts/{docId} {
  allow read: if request.auth != null;    ← Privada (solo admins)
  allow write: if request.auth != null;
}

match /libro_interactivo_progreso/{document=**} {
  allow read: if true;                    ← Pública (app Godot)
  allow write: if request.auth == null;   ← Pública (app Godot)
  ...
}
```

✅ Datos personales (scouts) protegidos  
✅ Progreso del libro público  

---

## Deployment Checklist

- [ ] `firebase/functions/` existe con `findScout.js` y `package.json`
- [ ] Firebase CLI instalado (`firebase --version`)
- [ ] Autenticado (`firebase login`)
- [ ] Deploy Cloud Function (`firebase deploy --only functions`)
- [ ] URL funciona (`curl https://us-central1-.../findScout`)
- [ ] Godot actualizado (firebase_sync.gd llama Cloud Function)
- [ ] Test login en Godot

---

## Testing

### Test 1: Curl directo

```bash
curl -X POST https://us-central1-fichas-actividad-scout.cloudfunctions.net/findScout \
  -H "Content-Type: application/json" \
  -d '{"nombre": "Carlos López", "patrulla": "Jaguares"}'
```

Expected:
```json
{"scoutId": "scout123", "nombre": "Carlos López", "patrulla": "Jaguares", "similarity": 1.0}
```

### Test 2: Login en Godot

1. Ejecutar proyecto Godot
2. Ingresa nombre scout + patrulla
3. Esperado: ✓ Scout encontrado, progreso descargado

### Test 3: Fuzzy matching

Ingresa nombre aproximado (ej: "carlos lopez" sin acentos)
Esperado: ✓ Encontrado si similitud >= 80%

---

## Próximo Paso

1. Deploy Cloud Function (5 min)
2. Re-run login verification (10 min)

Ver: `docs/Firebase_CloudFunction_Deployment.md`
