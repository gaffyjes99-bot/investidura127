# Firestore Rules — Paso 2: FINAL

Aplica estas reglas DESPUÉS de que el script de migración termine sin errores.
Cierra `scouts` al público y congela `scouts_busqueda` (solo lectura).

---

## Reglas a pegar en Firebase Console

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /super_admins/{docId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    match /grupos/{uid} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == uid;
    }

    match /grupos_config/{grupoId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
        (request.auth.uid in resource.data.admins ||
         request.auth.uid == resource.data.adminUid);
      allow delete: if false;
    }

    match /solicitudes_acceso/{docId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if false;
    }

    // scouts — PRIVADA: cédulas, teléfonos, datos médicos protegidos
    match /scouts/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // scouts_busqueda — solo nombre/patrulla/grupoId/idScout, lectura pública
    match /scouts_busqueda/{docId} {
      allow read: if true;
      allow write: if false;
    }

    match /progresion_scouts/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    match /progresiones/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    match /calendarios/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    match /fichas/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    match /libro_interactivo_progreso/{document=**} {
      allow read: if true;
      allow write: if true;
    }
  }
}
```

---

## Qué cambia vs. antes

| Colección | Antes | Después |
|-----------|-------|---------|
| `scouts` | ✅ lectura pública (datos sensibles expuestos) | 🔒 solo autenticados |
| `scouts_busqueda` | no existía | ✅ lectura pública (solo nombre/patrulla) |

---

## Verificar que quedó bien

```bash
# Debe devolver documentos (scouts_busqueda es pública)
curl "https://firestore.googleapis.com/v1/projects/fichas-actividad-scout/databases/(default)/documents/scouts_busqueda?key=AIzaSyBPFCRvhezdhz27OzPbZJijlOVKLnzKNo4"

# Debe dar error 403 (scouts ahora es privada)
curl "https://firestore.googleapis.com/v1/projects/fichas-actividad-scout/databases/(default)/documents/scouts?key=AIzaSyBPFCRvhezdhz27OzPbZJijlOVKLnzKNo4"
```
