# investidura127

**La Senda del Pietierno** — Libro Interactivo Animado de Investidura
Grupo Scout 127 Liceo de Cervantes

Aplicación web progresiva (PWA) gamificada, construida en Godot Engine 4, que prepara a los scouts (10–15 años) para su ceremonia de investidura. Costo: $0 COP.

## Ubicación local del proyecto
```
C:\Users\gaffy\OneDrive\DocumentosJES\Singular_AI\Clientes\GS127\Tropa\Libro_Animado_investidura
```
Este directorio es la raíz del repositorio Git y el punto de partida para trabajar con Claude Code:
```
cd "C:\Users\gaffy\OneDrive\DocumentosJES\Singular_AI\Clientes\GS127\Tropa\Libro_Animado_investidura"
claude
```

**Nota OneDrive:** el `.gitignore` ya excluye builds y carpetas pesadas de Godot (`.godot/`, exports). Aun así, se recomienda excluir esta carpeta de la sincronización automática de OneDrive mientras se trabaja activamente en Fase 7 (Godot), para evitar conflictos de sincronización con archivos binarios de export.

## Estado del proyecto
🟢 Fase 0 — Kickoff y arquitectura: **Completa** (repo en GitHub, estructura de carpetas)
🟢 Validación técnica — Proyecto Godot mínimo exportado a Web y probado (incluye Safari/iPhone): **Completa**
🟢 Fase 1 — Extracción de contenidos: **Completa** (matriz maestra + banco de 120 preguntas)
🟢 Fase 2 — Guion pedagógico y de juego: **Completa** (guion.md, escenas.json, preguntas.json en cada capítulo + docs/Fase2_Guion_Pedagogico.md)
🟢 Fase 3 — Storyboard: **Especificación completa** (docs/Fase3_Guia_de_Estilo.md + docs/Fase3_Storyboard_48_Escenas.md)
🟡 Fase 4 — Producción gráfica: **En curso, ajustada a equipo de 1 persona** — arte generado con IA local (Stable Diffusion/Fooocus), prompts listos en docs/Fase4_Prompts_Generacion_Arte.md
⬜ Fase 5 en adelante

## Stack & Arquitectura Técnica
- **Frontend:** Godot Engine 4 → export HTML5 → GitHub Pages (costo: $0)
- **Backend de sincronización:** Firestore (Google, proyecto existente `fichas-actividad-scout` del Grupo 127, reutilizado sin costo adicional)
  - Nueva colección: `libro_interactivo_progreso` (coexiste con colecciones existentes `scouts`, `progresion_scouts`, etc.)
- **Identificación del usuario:** nombre scout + patrulla elegidos por el usuario en el app, **sin email**. Se vincula automáticamente con el scoutId en la colección `scouts` existente.
- **Privacidad:** progreso guardado localmente en el dispositivo + sincronizado automáticamente a Firestore. Sin datos personales sensibles (progreso educativo únicamente). Sujeto a Terms of Service de Google / Privacy de Firestore.
- **Panel dirigente:** nueva sección en la app React existente (`scouts-app`), accesible solo para jefes autenticados, que muestra progreso del Libro Interactivo y permite validaciones.

## Nota sobre el equipo
El proyecto se ejecuta con **una sola persona**. El cronograma y roles del Plan Maestro original (§6) asumían un equipo de 5-6 voluntarios; se ajustó para producir arte con IA en vez de ilustración manual, lo que reduce significativamente el tiempo de Fases 3-6.

## Documentación
- `/docs/Plan_Completo_Libro_Interactivo_Investidura.md` — plan maestro completo (fases, gamificación, cronograma, equipo, asignación de modelos Claude)
- `/docs/Matriz_Maestra_Contenidos.xlsx` — matriz de los 12 capítulos vs. requisitos de investidura
- `/docs/Firebase_Especificacion_Tecnica.md` — cómo funciona la sincronización de progreso en tiempo real (Fase 7)

## Estructura
```
investidura127
├── assets/          # audio, video, imágenes, sprites
├── capitulos/        # 12 carpetas, una por capítulo (01-12)
├── evaluaciones/      # bancos de preguntas en JSON
├── gamificacion/      # sistema de XP e insignias
├── personajes/       # arte de personajes narradores
├── patrullas/        # arte de Jaguares, Lobos, Mapaches, Pandas
├── export/           # builds de Godot (web, android)
└── docs/             # documentación del proyecto
```

## Cómo contribuir
1. Cada capítulo tiene su propia carpeta en `/capitulos/NN_nombre/` con: `guion.md`, `escenas.json`, `preguntas.json`.
2. Los assets van en la subcarpeta correspondiente de `/assets/`, nombrados `capNN_descripcion.ext`.
3. El desarrollo Godot se hace en una carpeta `godot/` en la raíz (se crea al iniciar Fase 7).

## Equipo
| Rol | Responsable |
|---|---|
| Jefe pedagógico scout | Por asignar |
| Diseñador/ilustrador | Por asignar |
| Programador Godot | Por asignar |
| Narradores (2) | Por asignar |
| Testers scouts (4) | Por asignar |

## Licencia
Uso interno del Grupo Scout 127. Contenido pedagógico basado en la Bitácora Scout 2018 y la Tabla de Progresión Personal de la Asociación Scouts de Colombia.
