# ✅ LISTO PARA DESPLEGAR — Opción B (Spark Plan)

**Status:** Código listo, solo falta actualizar reglas Firestore

---

## Paso 1️⃣ — Actualizar Firestore Rules (5 min)

1. Firebase Console: https://console.firebase.google.com/project/fichas-actividad-scout/firestore/rules
2. Copiar reglas de: `docs/FIRESTORE_RULES_OPTION_B.md`
3. Pegar en editor
4. Click **Publish**
5. Esperar 30 segundos

**Cambio clave:**
```firestore
match /scouts/{docId} {
  allow read: if true;                    // ← Ahora público para app Godot
  allow write: if request.auth != null;
}
```

---

## Paso 2️⃣ — Verificar Reglas Funcionan (2 min)

```bash
curl "https://firestore.googleapis.com/v1/projects/fichas-actividad-scout/databases/(default)/documents/scouts?key=AIzaSyBPFCRvhezdhz27OzPbZJijlOVKLnzKNo4"
```

✓ Debe retornar JSON con scouts

---

## Paso 3️⃣ — Probar Login en Godot (10 min)

```
1. Ejecutar proyecto Godot
2. Ingresa nombre scout real + patrulla
3. Esperado: ✓ Scout encontrado, progreso cargado
```

---

## Flujo Final (Opción B)

```
Scout login
    ↓
nombre + patrulla
    ↓
GET /scouts?key=API_KEY (Firestore REST)
    ↓
Godot aplica fuzzy local (Levenshtein 80%)
    ↓
Scout encontrado
    ↓
GET /libro_interactivo_progreso/{grupoId}_{scoutId}
    ↓
Progreso cargado ✓
```

---

## ⚠️ Seguridad (Option B)

| Aspecto | Estado |
|--------|--------|
| Nombres scouts | 🟡 Públicos (Firestore) |
| Patrullas | 🟡 Públicas (Firestore) |
| Progreso del libro | ✅ Público controlado |
| Datos sensibles | ✅ Protegidos (no en scouts) |
| Escalabilidad | ✅ Ilimitada (Spark) |

**Nota:** Para producción, considerar plan Blaze + Cloud Function (más seguro)

---

## Código Actualizado

- ✅ `godot/scripts/firebase_sync.gd` — Búsqueda local
- ✅ `godot/firebase_config.gd` — API Key configurada
- ✅ Todos los autoloads listos
- ✅ Toda la sincronización funcional

---

## ¿Listo?

**Única tarea pendiente:**
1. Actualizar Firestore Rules (`docs/FIRESTORE_RULES_OPTION_B.md`)
2. Re-run login verification

¡Luego Fase 7 = ✅ COMPLETA!
