# Firestore Rules — Option B (Búsqueda local en Godot)

**Requerimiento:** Permite lectura pública de scouts (menos seguro, pero sin costo de Cloud Functions)

---

## Reglas a usar

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Super admins — solo lectura desde la app
    match /super_admins/{docId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // Perfil personal de cada jefe
    match /grupos/{uid} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == uid;
    }

    // Configuración compartida del grupo
    match /grupos_config/{grupoId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
        (request.auth.uid in resource.data.admins ||
         request.auth.uid == resource.data.adminUid);
      allow delete: if false;
    }

    // Solicitudes de acceso
    match /solicitudes_acceso/{docId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if false;
    }

    // Scouts — MODIFICADO: lectura pública para app Godot
    match /scouts/{docId} {
      allow read: if true;                    // ← Público (app Godot busca scouts)
      allow write: if request.auth != null;   // ← Privado (solo admins escriben)
    }

    // Progresión de scouts
    match /progresion_scouts/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // Progresiones (etapas por grupo)
    match /progresiones/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // Calendarios
    match /calendarios/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // Fichas generadas
    match /fichas/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // Libro Interactivo — Progreso del scout
    match /libro_interactivo_progreso/{document=**} {
      allow read: if true;                    // Lectura pública
      allow write: if request.auth == null;   // Escritura solo desde app Godot
      allow create: if request.resource.data.keys().hasAll(['grupoId', 'scoutId', 'nombre']);
      allow update: if true;
      allow delete: if false;
    }

  }
}
```

---

## Cambio clave

```diff
  match /scouts/{docId} {
-   allow read: if request.auth != null;
+   allow read: if true;                    // ← Ahora público
    allow write: if request.auth != null;
  }
```

---

## ⚠️ Implicaciones de Seguridad

### Datos expuestos públicamente

Cualquiera con acceso a Firestore puede leer:
- Nombres de scouts
- Patrullas
- Cualquier otro campo en la colección scouts

### Mitigación

- Los datos **expuestos son básicos** (nombre, patrulla)
- NO incluye: emails, teléfonos, direcciones, documentos
- Datos personales sensibles deben estar en colección privada separada
- Acceso es de **Firestore REST API solamente** (no web público)

### Alternativa más segura

Usar Cloud Function (Option A) que:
- Valida la búsqueda en servidor
- Retorna solo `scoutId`
- Protege datos personales
- Requiere plan Blaze ($)

---

## Deployment

1. Firebase Console → fichas-actividad-scout → Firestore → Rules
2. Reemplazar reglas con las de arriba
3. Click **Publish**
4. Esperar 30 segundos

---

## Testing

```bash
curl "https://firestore.googleapis.com/v1/projects/fichas-actividad-scout/databases/(default)/documents/scouts?key=AIzaSyBPFCRvhezdhz27OzPbZJijlOVKLnzKNo4"
```

Expected: Válido JSON con documentos de scouts

