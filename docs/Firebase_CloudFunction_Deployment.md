# Deployment: Cloud Function findScout

**Proyecto:** fichas-actividad-scout  
**Función:** Búsqueda segura de scouts con fuzzy matching  
**Ubicación:** `firebase/functions/findScout.js`

---

## ¿Por qué Cloud Function?

✅ **Seguridad:** Busca en DB privada (scouts), retorna solo `scout_id`  
✅ **Fuzzy matching:** Levenshtein 80% en servidor  
✅ **Sin exponerdatos:** App Godot NO accede directamente a `scouts`  
✅ **Escalable:** Google maneja la infraestructura  

---

## Prerequisites

- [ ] Firebase CLI instalado: https://firebase.google.com/docs/cli
- [ ] Acceso a proyecto fichas-actividad-scout en Firebase Console
- [ ] Node.js 18+ instalado

---

## Instalación & Deployment

### Step 1: Instalar Firebase CLI

```bash
npm install -g firebase-tools
```

### Step 2: Autenticar

```bash
firebase login
```

Se abrirá navegador → Autorizar Claude Code / tu cuenta

### Step 3: Ir al directorio de funciones

```bash
cd "C:\Users\gaffy\OneDrive\DocumentosJES\Singular_AI\Clientes\GS127\Tropa\Libro_Animado_investidura\firebase\functions"
```

### Step 4: Instalar dependencias

```bash
npm install
```

Expected output:
```
added 123 packages in 45s
```

### Step 5: Configurar proyecto Firebase

```bash
firebase init
```

Seleccionar:
- ✓ Functions
- ✓ Existing project → **fichas-actividad-scout**
- ✓ JavaScript
- ✓ Instalar dependencias? → Yes

### Step 6: Deploy

```bash
firebase deploy --only functions
```

Expected output:
```
✔ Deploy complete!
Function URL: https://us-central1-fichas-actividad-scout.cloudfunctions.net/findScout
```

---

## Testing Local (Emulator)

### Opción A: Emulator local

```bash
firebase emulators:start --only functions
```

En otra terminal:
```bash
curl -X POST http://localhost:5001/fichas-actividad-scout/us-central1/findScout \
  -H "Content-Type: application/json" \
  -d '{"nombre": "Carlos López", "patrulla": "Jaguares"}'
```

### Opción B: Cloud Function en vivo

```bash
curl -X POST https://us-central1-fichas-actividad-scout.cloudfunctions.net/findScout \
  -H "Content-Type: application/json" \
  -d '{"nombre": "Carlos López", "patrulla": "Jaguares"}'
```

Expected response (éxito):
```json
{
  "scoutId": "scout123",
  "nombre": "Carlos López",
  "patrulla": "Jaguares",
  "similarity": 1.0
}
```

Expected response (error):
```json
{
  "error": "Scout no encontrado...",
  "code": "SCOUT_NOT_FOUND"
}
```

---

## Actualizar después de cambios

Si editas `findScout.js`:

```bash
firebase deploy --only functions
```

Solo redeploy (rápido, ~30s)

---

## Logs

Ver logs de la función:

```bash
firebase functions:log
```

O en Firebase Console:
- https://console.firebase.google.com/project/fichas-actividad-scout
- → Functions
- → findScout
- → Logs

---

## Troubleshooting

### Error: "Cannot find module 'firebase-admin'"

```bash
cd firebase/functions
npm install
```

### Error: "Project not configured"

```bash
firebase use fichas-actividad-scout
firebase deploy --only functions
```

### Error: "Permission denied"

- Verificar que el usuario tiene acceso al proyecto en Firebase Console
- Correr: `firebase login` nuevamente

### Function returns 500 error

- Ver logs: `firebase functions:log`
- Verificar que la colección `scouts` tiene datos
- Comprobar nombre/patrulla exactos

---

## Verificar que está deployado

```bash
firebase functions:list
```

Output debe incluir:
```
Function Name: findScout
...
Status: ACTIVE
Trigger: HTTP(S)
```

---

## URL de la función

```
https://us-central1-fichas-actividad-scout.cloudfunctions.net/findScout
```

Esta URL es llamada por `firebase_sync.gd` en Godot automáticamente.

---

## Rollback (si hay problemas)

```bash
firebase functions:delete findScout
```

Revertir a búsqueda directa en `firebase_sync.gd`:
- Cambiar `find_scout_in_firestore()` para leer directamente de scouts
- Nota: Requeriría actualizar reglas Firestore para permitir lectura pública

---

## Próximos pasos

1. ✅ Deploy Cloud Function
2. ✅ Verificar URL funciona con curl
3. ✅ Actualizar reglas Firestore (si es necesario)
4. ✅ Testear login en Godot
5. ✅ Re-run verificación

