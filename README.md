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
🟢 Fase 3 — Storyboard: **Especificación completa** (docs/Fase3_Guia_de_Estilo.md + docs/Fase3_Storyboard_48_Escenas.md). Pendiente: boceto visual real a cargo del diseñador/ilustrador en Excalidraw.
⬜ Fase 4 — Producción gráfica

## Documentación
- `/docs/Plan_Completo_Libro_Interactivo_Investidura.md` — plan maestro completo (fases, gamificación, cronograma, equipo, asignación de modelos Claude)
- `/docs/Matriz_Maestra_Contenidos.xlsx` — matriz de los 12 capítulos vs. requisitos de investidura

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
