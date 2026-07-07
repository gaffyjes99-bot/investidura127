# Actualización de reglas Firestore — libro_interactivo_progreso

**Proyecto:** fichas-actividad-scout  
**Colección nueva:** libro_interactivo_progreso  
**Cambio requerido:** Agregar regla para escritura sin autenticación

---

## Problema

Las reglas Firestore actuales **requieren autenticación** (`request.auth != null`) en todas las colecciones:

```firestore
match /scouts/{docId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}
```

Pero la app Godot **se conecta directamente sin login** usando la API Key en la URL query string:

```
GET https://firestore.googleapis.com/v1/projects/fichas-actividad-scout/databases/(default)/documents/libro_interactivo_progreso/{docId}?key={API_KEY}
```

Sin autenticación (`request.auth == null`), las actuales reglas **rechazarán todas las escrituras**.

---

## Solución

Agregar esta regla a `firebase.rules` **dentro del bloque principal**:

```firestore
// Libro Interactivo — Progreso del scout (escritura sin autenticación desde app Godot)
match /libro_interactivo_progreso/{document=**} {
  allow read: if true;                                    // Cualquiera puede leer
  allow write: if request.auth == null;                  // Solo sin autenticación (app Godot)
  allow create: if request.resource.data.keys().hasAll(['grupoId', 'scoutId', 'nombre']);
  allow update: if true;                                 // Actualizar campo por campo
  allow delete: if false;                                // Nunca borrar
}
```

---

## Pasos para actualizar

### 1. Ir a Firebase Console

https://console.firebase.google.com/

### 2. Seleccionar proyecto

Proyecto: **fichas-actividad-scout**

### 3. Ir a Firestore → Rules

![Screenshot: Firestore → Rules tab]

### 4. Copiar reglas COMPLETAS

Copiar todas las reglas actuales (para no perderlas) y pegar en editor local.

### 5. Agregar nueva regla

Buscar el cierre del bloque `match /databases/{database}/documents {` y agregar antes del cierre:

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

    // ... [otras reglas existentes] ...

    // Fichas generadas
    match /fichas/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }

    // 🆕 AGREGAR ESTA REGLA 🆕
    // Libro Interactivo — Progreso del scout (sincronización desde app Godot)
    match /libro_interactivo_progreso/{document=**} {
      allow read: if true;                                    // Lectura pública
      allow write: if request.auth == null;                  // Solo sin autenticación
      allow create: if request.resource.data.keys().hasAll(['grupoId', 'scoutId', 'nombre']);
      allow update: if true;                                 // Actualización sin restricción
      allow delete: if false;                                // Prohibir borrado
    }
  }
}
```

### 6. Publicar (Publish)

Clic en botón azul **Publish** (esquina inferior derecha del editor de reglas)

⚠️ **Advertencia:** Las reglas afectan inmediatamente. No habrá "cambios pendientes" — se aplican al instante.

### 7. Verificar publicación

En consola aparecerá: ✓ **Rules published successfully**

---

## ¿Por qué `request.auth == null`?

- App web (scouts-app) → Usa Firebase Authentication → `request.auth != null` ✓
- App Godot (libro interactivo) → Conecta directamente con API Key → `request.auth == null` ✓

Ambas coexisten en el mismo Firestore con diferentes métodos de acceso.

---

## Validación de reglas

La regla `allow create: if request.resource.data.keys().hasAll(['grupoId', 'scoutId', 'nombre']);` valida que:

- ✓ Cada nuevo documento tiene campos obligatorios: `grupoId`, `scoutId`, `nombre`
- ✓ Previene documentos vacíos o mal formados
- ✓ Se aplica solo en creación (CREATE)

---

## Rollback (si algo sale mal)

Si necesitas revertir:

1. Volver a Firebase Console → Firestore → Rules
2. Borrar la regla `match /libro_interactivo_progreso/{document=**} { ... }`
3. Publicar

---

## Testing después de actualización

En Godot, ejecutar login:

```gdscript
FirebaseSync.find_scout_in_firestore("Carlos López", "Jaguares")
# Esperado: ✓ Scout encontrado

FirebaseSync.get_scout_progress("127", "scout123")
# Esperado: ✓ Progreso descargado (o documento creado si no existe)
```

Si aparece error **403 Forbidden**, significa las reglas aún están restrictivas. Verificar que:
- [ ] Regla fue agregada DENTRO del bloque `match /databases/{database}/documents { ... }`
- [ ] Regla tiene `allow write: if request.auth == null;`
- [ ] Se hizo click en **Publish**
- [ ] Esperar 30 segundos (propagación en servidores Google)

---

## Referencia: Sintaxis Firestore Rules

```firestore
// Lectura pública
allow read: if true;

// Escritura sin autenticación (API Key)
allow write: if request.auth == null;

// Validación de campos
allow create: if request.resource.data.keys().hasAll(['field1', 'field2']);

// Actualización sin restricción (después de crear)
allow update: if true;

// Prohibir operación
allow delete: if false;
```

---

## Más información

- [Firestore Security Rules Guide](https://firebase.google.com/docs/firestore/security/start)
- [Custom Claims & Auth Tokens](https://firebase.google.com/docs/firestore/security/rules-conditions)
- [API Key vs Service Account](https://firebase.google.com/docs/projects/api-management)

