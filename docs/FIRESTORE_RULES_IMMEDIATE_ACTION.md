# ⚠️ IMMEDIATE ACTION — Update Firestore Rules

## Status
Login test BLOCKED — cannot proceed without updating security rules

## Root Cause
```
Error 403: Missing or insufficient permissions
→ Current rules require authentication (request.auth != null)
→ Godot app connects without authentication (using API Key)
→ All reads/writes are rejected
```

## Solution (5 minutes)

### Step 1: Open Firebase Console

Go to: https://console.firebase.google.com/

### Step 2: Select Project

Select **fichas-actividad-scout** project

### Step 3: Open Firestore Rules

Click: **Firestore Database** → **Rules** tab

### Step 4: Copy Current Rules

Copy all the rules (to keep them for reference):

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ... all existing rules ...
  }
}
```

Save somewhere (Ctrl+A → Ctrl+C)

### Step 5: Add New Rule

Before the closing `}` of `match /databases/{database}/documents`, paste:

```firestore
    // Libro Interactivo — Progreso del scout (app Godot sin autenticación)
    match /libro_interactivo_progreso/{document=**} {
      allow read: if true;                                    // Lectura pública
      allow write: if request.auth == null;                  // Solo sin auth (app Godot)
      allow create: if request.resource.data.keys().hasAll(['grupoId', 'scoutId', 'nombre']);
      allow update: if true;
      allow delete: if false;
    }
```

### Step 6: Publish

Click blue **Publish** button (bottom right)

Expected message: ✅ **Rules published successfully**

### Step 7: Wait

Wait 30 seconds for propagation across Google servers

### Step 8: Verify

Test with curl:
```bash
curl "https://firestore.googleapis.com/v1/projects/fichas-actividad-scout/databases/(default)/documents/scouts?key=AIzaSyBPFCRvhezdhz27OzPbZJijlOVKLnzKNo4"
```

Expected: ✓ Valid JSON response (not 403 error)

---

## After Rules Are Updated

1. ✅ Rules published
2. ✅ Verified with curl
3. → Run: `claude code /verify firebase login flow`
4. → Full end-to-end test will run

---

## Reference

- Full guide: `docs/Firebase_Firestore_Rules_Update.md`
- Quick start: `docs/FIREBASE_README.md`
- Status: `docs/Firebase_Status_Fase7.md`

---

## Troubleshooting

**Error: "Invalid rule"**
- Check syntax (braces, semicolons)
- Ensure rule is INSIDE the main `match /databases/{database}/documents { ... }` block
- Not outside it

**Error: "403 PERMISSION_DENIED" after publishing**
- Rules take 30-60 seconds to propagate
- Clear browser cache (Ctrl+Shift+Del)
- Try again in 1 minute

**"Publish" button is grayed out**
- Click in the editor area first to activate it
- Then click Publish

---

## Once Rules Are Published

Reply with: ✅ Rules published and verified

Then we can run the full login test.
