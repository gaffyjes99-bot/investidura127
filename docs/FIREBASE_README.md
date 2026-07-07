# Firebase Firestore — Guía Rápida Fase 7

## Estado actual

✅ **Implementado:** Motor de sincronización Firestore completo  
✅ **Integrado:** Login, quiz, capítulos sincronizando automáticamente  
✅ **API Key:** Ya configurada en `godot/firebase_config.gd`  
❌ **Bloqueador:** Reglas Firestore aún restrictivas

---

## 1️⃣ URGENTE — Actualizar reglas Firestore (5 min)

**Por qué:** Las reglas actuales rechazan escrituras sin autenticación. Godot se conecta sin login.

**Qué hacer:**
1. Ir a https://console.firebase.google.com/ → fichas-actividad-scout
2. Firestore → Rules
3. Copiar-pegar regla nueva (ver abajo)
4. Click "Publish"

**Regla a agregar:**

```firestore
// Libro Interactivo — Progreso del scout
match /libro_interactivo_progreso/{document=**} {
  allow read: if true;
  allow write: if request.auth == null;
  allow create: if request.resource.data.keys().hasAll(['grupoId', 'scoutId', 'nombre']);
  allow update: if true;
  allow delete: if false;
}
```

📖 Documentación completa: `docs/Firebase_Firestore_Rules_Update.md`

---

## 2️⃣ Verificar datos previos (5 min)

**Colección scouts:** Necesita datos reales con campos:
- `nombre` (string) — Nombre completo del scout
- `patrulla` (string) — "Jaguares" | "Lobos" | "Mapaches" | "Pandas"

**Ejemplo documento:**
```json
{
  "nombre": "Carlos López",
  "patrulla": "Jaguares",
  "rango": "Aspirante",
  "...otros_campos": "..."
}
```

📖 Verificar en: Firebase Console → Firestore → scouts collection

---

## 3️⃣ Probar login (10 min)

**En Godot:**

```gdscript
# Ejecutar proyecto web
# Abrir en navegador
# Ingresar nombre de un scout real + patrulla
# Click "Iniciar"

# Esperado:
# ✓ Scout encontrado (búsqueda fuzzy)
# ✓ Progreso descargado
# ✓ Cambiar a mapa
```

**Si aparece error:**
- "Scout no encontrado" → Verificar nombre exacto en DB
- "Error 403" → Verificar reglas Firestore (publicadas?)
- "Error de conexión" → Verificar API Key en firebase_config.gd

---

## 4️⃣ Probar sincronización (10 min)

**Escenario 1: Quiz completado**

```
1. Scout inicia sesión
2. Mapa → Capítulo 1 → Evaluación (Quiz)
3. Responde preguntas, aprueba
4. Capítulo marcado como completado
5. Verificar en Firebase Console:
   - Colección: libro_interactivo_progreso
   - Documento: 127_[scout_id]
   - Campo: capitulos_completados debe tener ["01"]
   - Campo: xp_total debe estar actualizado
```

**Escenario 2: Offline + reconexión**

```
1. Scout completando capítulo
2. Desactivar conexión (DevTools → Network: offline)
3. Completar otra actividad
4. UI muestra "Sincronizando..." (después de 10s)
5. Restaurar conexión
6. Automático: cambios se envían a Firestore
7. Verificar en Firebase Console
```

---

## 📁 Archivos clave

| Archivo | Propósito |
|---------|-----------|
| `godot/firebase_config.gd` | Credenciales + endpoints |
| `godot/scripts/firebase_sync.gd` | Motor de sync (busca + descarga + push) |
| `godot/scenes/onboarding/onboarding.gd` | Login con Firebase |
| `godot/autoload/GameState.gd` | Estado del scout |
| `godot/autoload/SaveManager.gd` | LocalStorage + auto-sync Firestore |

---

## 📚 Documentación detallada

| Documento | Contenido |
|-----------|----------|
| `Firebase_Especificacion_Tecnica.md` | Especificación técnica de Firestore |
| `Firebase_Integracion_Godot.md` | Guía de uso + API |
| `Firebase_Ejemplos_Integracion.gd` | Código ejemplo para todas las escenas |
| `Firebase_Checklist_Setup.md` | Checklist setup + debugging |
| `Firebase_Firestore_Rules_Update.md` | Cómo actualizar reglas |
| `Firebase_Status_Fase7.md` | Status completo + plan testing |

---

## 🔄 Flujo de datos

```
Scout login
    ↓
find_scout_in_firestore()
    ↓ (búsqueda fuzzy 80%)
Validar en DB
    ↓
get_scout_progress()
    ↓ (descarga/crea documento)
Descargar xp, rango, capítulos
    ↓
GameState + localStorage
    ↓
Jugar (capítulos, quiz)
    ↓
GameState.dar_xp() / completar_capitulo()
    ↓
SaveManager.guardar()
    ↓ (auto-sync)
FirebaseSync.push_scout_data()
    ↓ (PATCH Firestore)
✓ Sincronizado a Firestore
    ↓ (si error → buffer local + retry cada 5s)
Cambiar dispositivo → mismo scout descarga progreso
```

---

## ⚙️ Configuración actual

```
Proyecto: fichas-actividad-scout
Grupo ID: 127
API Key: AIzaSyBPFCRvhezdhz27OzPbZJijlOVKLnzKNo4
Sync interval: 5 segundos
UI timeout: 10 segundos (mostrar "Sincronizando...")
Similarity threshold: 80% (búsqueda fuzzy)
```

---

## ✅ Checklist antes de Fase 8

- [ ] Reglas Firestore actualizadas (match /libro_interactivo_progreso)
- [ ] Colección scouts tiene datos reales
- [ ] Test 1: Login fuzzy (nombreaproximado encontrado)
- [ ] Test 2: Progreso descargado/creado
- [ ] Test 3: Quiz sync (xp actualizado en Firestore)
- [ ] Test 4: Offline works (buffer local + reconexión)
- [ ] Test 5: Multi-device (mismo scout en 2 dispositivos)
- [ ] Web export funcional
- [ ] Logs sin errores

---

## 🚀 Próximas fases

**Fase 8:** Panel web del dirigente
- Ver progreso de scouts en tabla
- Validar buenas acciones / campamentos
- Generar códigos de validación

**Fase 9:** Notificaciones
- Notificar cambios de rango
- Insignias desbloqueadas
- Validaciones pendientes

---

## 💬 Soporte

**¿Scout no encontrado?**  
→ Verificar nombre exacto en DB (búsqueda fuzzy 80% mínimo)

**¿Error 403?**  
→ Verificar reglas Firestore (¿están publicadas?)

**¿Cambios no se sincronizan?**  
→ Verificar conexión + logs en Output

**¿Necesito más info?**  
→ Leer `Firebase_Status_Fase7.md` (estado completo + troubleshooting)

