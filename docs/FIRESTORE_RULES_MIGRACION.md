# Firestore Rules — Paso 1: MIGRACIÓN

Aplica estas reglas ANTES de ejecutar el script de migración.
Permiten escritura temporal a `scouts_busqueda` para poblarla.

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

    // scouts — sigue público temporalmente para que el script lea
    match /scouts/{docId} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    // scouts_busqueda — escritura abierta SOLO durante la migración
    match /scouts_busqueda/{docId} {
      allow read: if true;
      allow write: if true;
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

## Pasos

1. Firebase Console → **fichas-actividad-scout** → Firestore → **Rules**
2. Reemplazar todo con las reglas de arriba
3. Click **Publish** → esperar 30 segundos
4. Ejecutar el script:
   ```
   python docs/migrar_scouts_busqueda.py
   ```
5. Cuando el script diga "Sin errores ✅" → aplicar `FIRESTORE_RULES_FINAL.md`
