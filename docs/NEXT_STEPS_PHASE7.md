# Próximos Pasos — Fase 7 (Después del Cloud Function)

**Status:** Cloud Function implementado, listo para deployment  
**Bloqueador anterior:** Reglas Firestore (✅ RESUELTO)

---

## 🚀 Steps Inmediatos (30 min)

### 1️⃣ Deploy Cloud Function (10 min)

Ver: `docs/Firebase_CloudFunction_Deployment.md`

```bash
# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Authenticate
firebase login

# 3. Go to functions directory
cd firebase/functions

# 4. Install dependencies
npm install

# 5. Initialize Firebase (if not done)
firebase init

# 6. Deploy
firebase deploy --only functions
```

**Expected output:**
```
✔ Deploy complete!
Function URL: https://us-central1-fichas-actividad-scout.cloudfunctions.net/findScout
```

---

### 2️⃣ Verify Cloud Function Works (5 min)

```bash
curl -X POST https://us-central1-fichas-actividad-scout.cloudfunctions.net/findScout \
  -H "Content-Type: application/json" \
  -d '{"nombre": "Carlos López", "patrulla": "Jaguares"}'
```

**Expected response:**
```json
{
  "scoutId": "scout123",
  "nombre": "Carlos López",
  "patrulla": "Jaguares",
  "similarity": 1.0
}
```

If error 404/500 → Check logs: `firebase functions:log`

---

### 3️⃣ Test Login Flow in Godot (15 min)

```
1. Run Godot project (web export preferred)
2. Onboarding screen:
   - Ingresa nombre scout real (ej: "Carlos López")
   - Select patrulla (Jaguares, Lobos, Mapaches, Pandas)
   - Click "Iniciar"

Expected flow:
   ✓ Cloud Function busca scout
   ✓ "✓ Scout encontrado"
   ✓ "Cargando progreso..."
   ✓ Cambia a mapa scene
   ✓ Muestra progreso del scout (XP, rango, capítulos)
```

**If errors:**

| Error | Cause | Fix |
|-------|-------|-----|
| Cloud Function 404 | URL incorrecta o no deployada | `firebase deploy --only functions` |
| Cloud Function 403 | CORS bloqueado | Check findScout.js CORS headers |
| "Scout no encontrado" | Nombre no está en DB scouts | Verificar nombre exacto en Firebase Console |
| "Multiple matches" | Múltiples scouts similares | Usar nombre más específico |
| "Cannot reach server" | Red offline | Verificar conexión a internet |

---

## ✅ Verification Test (después de deploying)

Run full login verification:

```bash
claude code /verify firebase login flow
```

Should now PASS (previamente estaba BLOCKED por seguridad).

Expected steps:
1. ✅ Ingresar nombre scout
2. ✅ Cloud Function busca
3. ✅ Progreso descargado desde Firestore
4. ✅ GameState cargado
5. ✅ Offline buffering funciona
6. ✅ Multi-device sync funciona

---

## 📋 Firestore Rules (Sin cambios necesarios)

Las reglas actuales ya funcionan:

```firestore
match /scouts/{docId} {
  allow read: if request.auth != null;    // Privada (Cloud Function tiene acceso)
  allow write: if request.auth != null;
}

match /libro_interactivo_progreso/{document=**} {
  allow read: if true;                    // Pública para app Godot
  allow write: if request.auth == null;   // Pública para app Godot
}
```

✅ No requiere cambios  
✅ Datos personales protegidos  
✅ App Godot puede leer/escribir progreso  

---

## 🔄 Architecture (Updated)

```
Scout Login
    ↓
nombre + patrulla
    ↓
POST /findScout (Cloud Function)
    ↓
Cloud Function:
  - Valida inputs
  - Query scouts collection (privada)
  - Fuzzy match (80% Levenshtein)
  - Retorna {"scoutId": "...", "nombre": "...", "similarity": 0.95}
    ↓
Godot recibe scoutId
    ↓
GET /libro_interactivo_progreso/127_{scoutId}
    ↓
Firestore retorna progreso (público)
    ↓
GameState cargado
    ↓
Cambiar a mapa ✓
```

---

## 📊 Próximas Fases

### Fase 8: Panel web del dirigente
- Ver tabla de scouts + progreso
- Validar buenas acciones / campamentos
- Generar códigos de validación

### Fase 9: Notificaciones
- Scout logra nuevo rango
- Insignia desbloqueada
- Validación pendiente

---

## 📚 Documentación Clave

| Documento | Propósito |
|-----------|-----------|
| `Firebase_CloudFunction_Deployment.md` | Deployment paso a paso |
| `CLOUD_FUNCTION_SUMMARY.md` | Resumen técnico |
| `Firebase_Status_Fase7.md` | Status completo + testing |
| `FIREBASE_README.md` | Quick start |

---

## Checklist Deployment

- [ ] Firebase CLI instalado
- [ ] `firebase login` ejecutado
- [ ] `firebase deploy --only functions` completado
- [ ] Cloud Function URL verificada con curl
- [ ] Godot proyecto actualizado (firebase_sync.gd)
- [ ] Test login en Godot PASS
- [ ] Múltiples patrullas testeadas
- [ ] Fuzzy matching testeado (ej: "carlos lopez" vs "Carlos López")
- [ ] Offline buffering testeado
- [ ] Multi-device sync testeado

---

## 🎯 Success Criteria

**Fase 7 Complete when:**

1. ✅ Scout login funciona con fuzzy search
2. ✅ Progreso descargado de Firestore en primer login
3. ✅ Quiz completado sincroniza XP
4. ✅ Capítulo completado sincroniza
5. ✅ Offline buffering + reconexión funciona
6. ✅ Multi-device: mismo scout en diferente dispositivo descarga su progreso
7. ✅ Web export funcional con todas las características

---

## Tiempo Estimado

- Cloud Function deploy: **5-10 min**
- Testing: **15-20 min**
- Full verification: **10-15 min**

**Total: ~40 min a Fase 7 completa**

---

## Support

Problemas?
- Check: `firebase functions:log`
- Check: `docs/Firebase_CloudFunction_Deployment.md` (troubleshooting section)
- Check: `docs/Firebase_Status_Fase7.md` (debugging)

---

**Ready? Go to Step 1: Deploy Cloud Function** ✅
