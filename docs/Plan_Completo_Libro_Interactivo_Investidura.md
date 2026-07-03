# Plan Completo de Implementación
## Libro Interactivo Animado de Investidura — Tropa Scout (10–15 años)
### Grupo Scout 127 Liceo de Cervantes | Costo objetivo: $0 COP

---

## 1. Visión del producto

**Nombre de trabajo:** *La Senda del Pietierno* — Expedición Investidura

No es un libro digitalizado: es un **juego de expedición** donde el scout avanza por un **mapa de senda** (estilo mapa de campamento ilustrado) con 12 campamentos (capítulos). Cada campamento desbloquea el siguiente. Al completar la senda, el scout está listo para solicitar su ceremonia de investidura real ante la tropa.

**Formato técnico:** Aplicación web progresiva (PWA) construida en **Godot Engine 4**, exportada a HTML5, publicada en **GitHub Pages**. Funciona en Android, iPhone, tablet, PC y se comparte por WhatsApp con un simple enlace. Instalable en pantalla de inicio, funciona offline tras la primera carga.

**Principio pedagógico rector:** El app **prepara y verifica conocimiento**; los dirigentes **validan la vivencia**. Los requisitos prácticos (noches de campamento, pertenencia a patrulla, rendimiento académico, comportamiento en el hogar) se registran en el app pero requieren **código de validación del dirigente** — el juego nunca reemplaza la experiencia scout real.

---

## 2. Mapeo de contenidos: los 20 requisitos → 12 capítulos

Cada capítulo agrupa requisitos afines de la Tabla de Progresión Personal, usa el contenido de la Bitácora Scout 2018 como fuente, y tiene su propia mecánica, evaluación e insignia.

| Cap. | Nombre del campamento | Requisitos cubiertos (Tabla) | Mecánica interactiva principal | Insignia |
|---|---|---|---|---|
| 1 | **El Origen del Fuego** | 1. Qué es el Escultismo, 18. Quién fue B.P. | Novela visual interactiva de Mafeking y Brownsea con decisiones ("¿Qué haría B.P.?") + completar la biografía con espacios en blanco (tomados de la Bitácora) | 🔥 Guardián de la Historia |
| 2 | **El Código del Explorador** | 2. Ley Scout | Arrastrar y soltar: 10 artículos ↔ significado. Modo historia: 10 mini-viñetas animadas, el scout identifica qué artículo de la Ley ilustra cada una | ⚖️ Guardián de la Ley |
| 3 | **Mi Palabra de Honor** | 3. Promesa Scout | Memorización progresiva: la promesa aparece completa, luego con huecos crecientes hasta recitarla de memoria. Grabación de voz opcional para practicar | 🤝 Portador de la Promesa |
| 4 | **Las Raíces** | 4. Principios, 5. Virtudes, 6. Oración | Juego de clasificación: separar principios (3) de virtudes (3) y asociar definiciones. Oración con karaoke de texto resaltado + audio | 🌳 Raíces Firmes |
| 5 | **Los Símbolos de la Hermandad** | 7. Seña, 8. Lema, 9. Flor de Lis, 12. Saludo mano izquierda | Flor de Lis interactiva: tocar cada parte revela su significado, luego quiz visual de armar la flor. Animación del saludo (45°/90°, con bordón) con imitación frente a cámara opcional (sin guardar imagen) | ⚜️ Heraldo de la Flor de Lis |
| 6 | **El Uniforme del Aventurero** | 10. Uniforme e Insignias | "Vestir al scout": arrastrar insignias al lugar correcto del uniforme. Pañoleta del Grupo 127: mini-juego de colorear con rojo y amarillo + asociar cada color con su significado oficial (ver §2.1). Usos de la pañoleta según B.P. | 🎽 Porte Impecable |
| 7 | **La Buena Acción** | 11. Historia de la Buena Acción, 13. Nombre y firma scout | Animación de la historia de la buena acción (el scout londinense y W. Boyce). Diario de buenas acciones: registrar 1 por semana, validada por padre/dirigente (+100 XP c/u) | 💚 Mano Amiga |
| 8 | **El Lenguaje de la Tropa** | 14. Llamados con silbato | Juego de audio: escuchar el llamado (Morse con pito) y seleccionar su significado. Modo inverso: "te piden reunión, ¿qué llamado suena?" | 📯 Oído de Explorador |
| 9 | **Formaciones y Bordón** | 15. Formaciones de tropa, 16. Usos del bordón | Simulador táctico: ver la señal del dirigente animado y colocar las patrullas en la formación correcta (fila, herradura, círculo, etc.). Galería animada de usos del bordón | 🥾 Maestro de Formación |
| 10 | **Mi Tropa, Mi Familia** | 17. Organigramas con nombres, 19. Pertenecer a una patrulla | Constructor de organigrama: arrastrar nombres reales de la tropa/grupo a su cargo. Ficha de patrulla editable: animal, grito, lema, banderín (mini-editor de dibujo) | 🐾 Espíritu de Patrulla |
| 11 | **La Prueba del Campista** | 20. Mínimo 2 noches de campamento, 4 meses de participación | Bitácora de campamento digital: registro de noches con código de validación del dirigente. Contador visual de meses de participación | ⛺ Bajo las Estrellas |
| 12 | **La Gran Ceremonia** | Rendimiento académico, comportamiento en el hogar + repaso general | Examen final integrador (20 preguntas mezclando todos los capítulos, incluidas las 2 fijas sobre los colores de la pañoleta del grupo, mínimo 80%). Validación de padres (hogar) y dirigente (académico) por código. Al aprobar: **animación de la ceremonia de investidura** (pito → formación → bandera → promesa → pañoleta → puente de tropa) | 🏅 Candidato a Investidura |

### 2.1 Contenido oficial: la pañoleta del Grupo Scout 127

Este es contenido de evaluación obligatoria dentro del Capítulo 6 (hace parte de las pruebas de investidura del grupo):

| Color | Significado oficial |
|---|---|
| **Rojo** | La fuerza del espíritu que nos fortalece para cumplir las metas |
| **Amarillo** | La riqueza del alma y el corazón |

**Diseño de la escena en el app:**
1. **Descubrimiento:** la pañoleta aparece en gris; al tocar cada franja, se colorea y un personaje narra el significado del color con una mini-animación (rojo: una fogata que crece / un scout que persevera; amarillo: un corazón que brilla / un scout compartiendo).
2. **Práctica:** mini-juego de colorear la pañoleta con la combinación correcta (rojo y amarillo) entre opciones distractoras.
3. **Evaluación (2 preguntas fijas del quiz del Cap. 6 y del examen final del Cap. 12):**
   - Arrastrar: Rojo ↔ "La fuerza del espíritu que nos fortalece para cumplir las metas"; Amarillo ↔ "La riqueza del alma y el corazón".
   - Opción múltiple inversa: "¿Qué color de nuestra pañoleta representa la riqueza del alma y el corazón?"
4. **Coleccionable:** al dominar ambos significados se desbloquea la **pañoleta 127 para el avatar**, que el scout luce por el resto de la senda (refuerzo visual permanente del logro).
5. **Validación presencial opcional (+50 XP bonus):** siguiendo la tradición de la Bitácora, el scout puede buscar a su dirigente en la reunión de tropa y contarle de viva voz el significado de los colores. El dirigente le entrega un código de validación que registra en el app. No es requisito para avanzar, pero premia el encuentro personal y refuerza el vínculo scout–dirigente.

---

## 3. Sistema de gamificación (diseño detallado)

### 3.1 Narrativa envolvente
El scout es un **pietierno que inicia su expedición**. Un personaje mentor (Baden Powell joven o el guía de patrulla animado) lo acompaña con mensajes de ánimo. Los personajes del Libro de la Selva (Akela, Kaa, Baloo, Jacala, Wontolla, Kotick) aparecen como narradores de capítulos específicos.

### 3.2 Economía de XP
| Acción | XP | Notas |
|---|---|---|
| Leer una página/escena | +10 | Solo la primera vez |
| Ver una animación completa | +5 | |
| Completar actividad interactiva | +20 | |
| Aprobar quiz de capítulo (≥80%) | +30 | Reintentos ilimitados, XP solo al aprobar |
| Quiz perfecto (100%) | +15 bonus | Fomenta la maestría |
| Buena acción validada | +100 | Máximo 1 por semana (evita farmeo) |
| Racha de 3 días seguidos | +25 | Racha de 7 días: +75 |
| Noche de campamento validada | +150 | Código del dirigente |

### 3.3 Rangos por XP acumulado
Pietierno (0) → Aspirante (200) → Rastreador (500) → Campista (900) → Explorador (1.400) → Candidato (2.000) → **Investido** (solo al completar Cap. 12 + validaciones reales).

El rango se muestra como avatar que evoluciona: el uniforme del avatar gana elementos (pañoleta gris de aspirante, sombrero, bordón, insignias) a medida que sube de rango.

### 3.4 Colecciones e inventario
- **Insignias de capítulo** (12): las de la tabla anterior. Vitrina de insignias en el perfil.
- **Objetos coleccionables ocultos**: 24 objetos escondidos en las escenas (brújulas, nudos, fogatas, flores de lis). Encontrarlos da +5 XP y llena el "morral" del scout. Incentiva la relectura.
- **Cartas de personaje**: al terminar cada capítulo se desbloquea una carta del personaje narrador con datos curiosos (colección estilo álbum).

### 3.5 Competencia sana entre patrullas
- Al crear el perfil, el scout elige su patrulla real (Jaguares, Lobos, Mapaches, Pandas).
- **Tablero de patrullas**: la suma de XP de los miembros alimenta un ranking visible (sin exponer datos individuales de menores — solo nombre scout y patrulla).
- **Banderín de la semana**: la patrulla con más XP semanal luce su banderín en la pantalla de inicio.
- Los dirigentes ven un **panel de progreso** para saber quién está listo para ceremonia.

### 3.6 Mecánicas anti-frustración (crítico para 10–15 años)
- Sesiones cortas: cada escena dura 3–5 minutos (uso en celular, atención adolescente).
- Sin vidas ni castigos: fallar un quiz da retroalimentación inmediata y pistas, no penalización.
- Progreso siempre visible: barra de senda en el mapa, "te faltan 3 campamentos".
- Celebración exagerada de logros: confeti, sonido de pito, animación de la insignia.

---

## 4. Fases de ejecución

### FASE 0 — Kickoff y arquitectura (Semana 1)
- Validar este plan con la jefatura de tropa.
- Crear repositorio `investidura127` en GitHub con la estructura de carpetas (assets, capítulos, evaluaciones, gamificación, personajes, patrullas, export).
- Definir responsables por rol (ver §6).
- **Entregable:** repositorio creado + acta de arranque.

### FASE 1 — Matriz maestra de contenidos (Semana 2)
- Ya está el 80% hecho: la tabla del §2 es la matriz. Completar con: página exacta de la Bitácora por tema, textos extraídos y adaptados al tono del juego, banco inicial de 10 preguntas por capítulo (120 preguntas totales).
- Herramientas: Google Sheets u Obsidian.
- **Entregable:** matriz maestra con textos y banco de preguntas v1.

### FASE 2 — Guion pedagógico y de juego (Semanas 3–4)
- Por capítulo: objetivo de aprendizaje, guion de escenas, diálogos de personajes, especificación exacta de la mecánica (qué se arrastra, qué se toca, condición de victoria), reglas de XP.
- Revisión pedagógica del jefe de tropa: ¿esto prepara realmente para la investidura?
- **Entregable:** documento maestro de 12 capítulos.

### FASE 3 — Storyboard (Semanas 5–6)
- 4 escenas por capítulo (narración → animación → juego → evaluación) bocetadas en Excalidraw o papel fotografiado.
- Definir paleta de colores (verde bosque, café tierra, amarillo fogata) y estilo (ilustración plana tipo cartoon, económica de producir).
- **Entregable:** 48 escenas bocetadas + guía de estilo de 2 páginas.

### FASE 4 — Producción gráfica (Semanas 7–9, en paralelo con Fase 5)
- Personajes: B.P., scout niño/niña, Akela, Kaa, Baloo, Jacala, Wontolla, Kotick (2–3 poses c/u, no animación completa: se anima por partes en Godot).
- Escudos de patrulla, 12 insignias, 24 coleccionables, avatar evolutivo (6 estados), mapa de senda, fondos (8–10 reutilizables).
- Herramientas: Krita (ilustración), Inkscape (insignias/UI vectorial), IA de imágenes local como acelerador de bocetos (siempre retocado a mano para estilo consistente).
- **Entregable:** paquete de assets en /assets/images y /assets/sprites.

### FASE 5 — Audio (Semana 8, en paralelo)
- Narraciones: grabar con scouts mayores/dirigentes (voz masculina: B.P., Jacala, Wontolla; femenina: Kaa, Akela, Kotick) usando Audacity, o Piper TTS como respaldo.
- **Llamados de silbato reales**: grabar al dirigente con el pito de la tropa (esto es contenido de evaluación, debe ser fiel).
- Efectos: fogata, bosque, confeti, pito de logro (bancos libres: freesound.org).
- **Entregable:** /assets/audio completo y normalizado.

### FASE 6 — Animaciones (Semanas 9–12)
- Priorizar animaciones dentro de Godot (huesos 2D / AnimationPlayer) sobre video renderizado: pesan menos y son editables.
- Lista mínima: intro de Mafeking/Brownsea, saludo scout (45°/90°/bordón), historia de la buena acción, formaciones de tropa (top-down), ceremonia final de investidura (la joya del producto).
- **Entregable:** animaciones integradas por capítulo.

### FASE 7 — Desarrollo en Godot (Semanas 9–16, arranca en paralelo con arte)
Arquitectura de escenas:
```
main
 ├── inicio (login por nombre scout + patrulla)
 ├── perfil (avatar, rango, XP, morral)
 ├── mapa_senda (12 campamentos, desbloqueo progresivo)
 ├── capitulos/01..12 (escenas de contenido)
 ├── juegos (mecánicas reutilizables: drag&drop, quiz, audio-quiz, clasificador, memoria)
 ├── evaluaciones (motor de quiz con banco de preguntas en JSON)
 ├── insignias (vitrina)
 ├── panel_dirigente (validaciones por código, progreso de la tropa)
 └── ceremonia (animación final)
```
Decisiones técnicas clave:
- **5 mecánicas reutilizables**, no 12 juegos distintos: drag&drop de parejas, quiz de opción múltiple, quiz de audio, clasificador de categorías, completar espacios. Cada capítulo las configura con datos JSON. Esto reduce el desarrollo a la mitad.
- Guardado: LocalStorage del navegador (JSON). Botón "exportar mi progreso" (archivo/código QR) para no perder avance al cambiar de dispositivo.
- Validación de dirigentes: códigos de 6 dígitos generados por una hoja simple que maneja la jefatura (sin servidor, sin costo).
- Peso total objetivo: **< 50 MB** para que cargue en datos móviles colombianos.
- **Entregable:** build web funcional con los 12 capítulos.

### FASE 8 — Pruebas con scouts (Semanas 17–18)
- 4 scouts testers (idealmente 2 pietiernos reales, 1 scout investido, 1 guía de patrulla).
- Protocolo: sesión de 30 min observada, sin ayuda; medir dónde se traban, qué aburre, qué repiten por gusto.
- Prueba en gama baja Android y en iPhone (Safari es el navegador más problemático para exports de Godot: probar temprano, en Fase 7).
- Corrección de bugs y ajuste de dificultad de quizzes.
- **Entregable:** informe de pruebas + build corregido.

### FASE 9 — Lanzamiento (Semana 19)
- Publicar en GitHub Pages (respaldo: Cloudflare Pages / Netlify).
- Generar QR para imprimir y pegar en el local de reuniones.
- Lanzamiento como evento de tropa: presentación en reunión sabatina, cada patrulla crea sus perfiles en vivo, primer reto colectivo ("primera patrulla en completar el Campamento 1").
- Comunicado a padres por WhatsApp: qué es, para qué sirve, cómo validan las buenas acciones.
- **Entregable:** app en producción + kit de lanzamiento.

### FASE 10 — Operación continua
- Ciclo mensual: revisar panel de dirigente, celebrar rangos alcanzados en la formación de tropa (conectar lo digital con lo presencial), rotar preguntas del banco.
- Roadmap futuro: módulos Vigía, Explorador, Excursionista y Expedicionario reutilizando el mismo motor (la inversión se amortiza en toda la progresión).

---

## 5. Cronograma consolidado

| Semanas | Fase | Hito |
|---|---|---|
| 1 | Kickoff | Repositorio + roles |
| 2 | Contenidos | Matriz maestra |
| 3–4 | Guion | Documento de 12 capítulos |
| 5–6 | Storyboard | 48 escenas + guía de estilo |
| 7–9 | Arte + Audio | Paquete de assets |
| 9–12 | Animación | Animaciones clave |
| 9–16 | Desarrollo Godot | Build web completo |
| 17–18 | Pruebas | Informe + correcciones |
| 19 | Lanzamiento | App en producción |

**Total: 19 semanas (~4,5 meses).** Con equipo voluntario de fines de semana, presupuestar 6 meses reales.

---

## 6. Equipo y herramientas ($0 COP)

| Rol | Cant. | Responsabilidad | Herramientas |
|---|---|---|---|
| Jefe pedagógico scout | 1 | Fidelidad del contenido, validaciones | Sheets, Obsidian |
| Diseñador/ilustrador | 1 | Fases 3, 4 y apoyo a 6 | Krita, Inkscape, GIMP |
| Programador Godot | 1 | Fases 7–9 | Godot 4, VS Code, Git |
| Narradores | 2 | Fase 5 | Audacity, Piper |
| Testers scouts | 4 | Fase 8 | Sus propios celulares |

Hosting, licencias y publicación: **$0**. Propiedad total del Grupo Scout 127.

---

## 7. Riesgos y mitigaciones

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Export web de Godot falla en iPhone/Safari | Alto | Probar en Safari desde la semana 9, no al final. Plan B: versión HTML/JS ligera de los quizzes |
| Voluntarios abandonan a mitad de camino | Alto | Mecánicas reutilizables + capítulos independientes: aun con 6 capítulos el producto es usable y lanzable (MVP: capítulos 1–6) |
| Scouts pierden progreso al cambiar de celular | Medio | Exportación de progreso por código/QR desde el día 1 |
| El app se percibe como reemplazo del dirigente | Medio | Validaciones presenciales obligatorias por código en Cap. 7, 11 y 12 |
| Datos de menores | Alto | Solo nombre scout y patrulla; sin correo, sin fotos, sin servidor externo. Todo local en el dispositivo |
| Contenido difiere del programa de la Asociación | Medio | Revisión del jefe pedagógico contra Bitácora 2018 y Tabla de Progresión antes de cada release |

---

## 8. Métricas de éxito

1. **≥ 80%** de los pietiernos de la tropa crean perfil en el primer mes.
2. **≥ 60%** completa los capítulos 1–6 en 3 meses.
3. Tiempo promedio de preparación para investidura **se reduce** frente a cohortes anteriores (medir contra los 4 meses de participación mínima).
4. En el examen presencial previo a la ceremonia, los scouts que completaron el app aprueban a la primera en **≥ 90%** de los casos.
5. Retención: sesiones de al menos 2 días por semana por scout activo.

---

## 9. Primeros 5 pasos accionables (esta semana)

1. Presentar este plan al consejo de jefes y obtener el visto bueno pedagógico.
2. Crear el repositorio GitHub `investidura127` con la estructura de carpetas.
3. Copiar la tabla del §2 a Google Sheets y asignar un responsable de redactar el banco de preguntas de los capítulos 1–3.
4. Instalar Godot 4 y hacer una prueba de export HTML5 con una escena vacía publicada en GitHub Pages (validar el pipeline técnico antes de producir contenido).
5. Reclutar a los 4 scouts testers y a los 2 narradores en la próxima reunión de tropa.

---

## 10. Asignación de modelos Claude por fase

Guía de qué modelo/herramienta usar en cada etapa del proyecto, para que el equipo trabaje de forma consistente y eficiente en costo.

| Fase | Modelo | ¿Claude Code? |
|---|---|---|
| 0 — Kickoff/arquitectura | Sonnet 5 (chat) | No |
| 1 — Matriz maestra de contenidos | Sonnet 5 (chat) | No |
| 2 — Guion pedagógico y de juego | Sonnet 5 (chat) | No |
| 3 — Storyboard | Sonnet 5 (chat, con Visualizer para bocetos) | No |
| 4 — Producción gráfica (assets) | Sonnet 5 (chat, image_search/generación) | No |
| 5 — Audio | Sonnet 5 (chat) | No |
| 6 — Animaciones | Sonnet 5 (chat) para diseño; Claude Code si ya implica scripts/escenas .tscn | Parcial |
| 7 — Desarrollo en Godot | Claude Code | Sí |
| 8 — Pruebas con scouts | Sonnet 5 (chat) para analizar resultados; Claude Code para corregir bugs | Parcial |
| 9 — Lanzamiento | Claude Code (deploy a GitHub Pages, configuración) | Sí |
| 10 — Operación continua | Sonnet 5 (chat) para contenido nuevo; Claude Code para cambios de código | Mixto |

**Regla de corte:** se usa Claude Code cuando el trabajo implica crear/editar archivos del repositorio real, ejecutar comandos o tocar código del proyecto Godot. Todo lo que es texto, diseño, guion, contenido pedagógico o assets sueltos se resuelve en el chat con Sonnet 5.

**Sobre Claude Fable 5 (nivel Mythos, vía Claude Platform/API/Claude Code):** no se requiere en ninguna fase de este proyecto. Está diseñado para tareas autónomas de muy larga duración (migraciones masivas de código, razonamiento extremo con supervisión mínima) y su costo es significativamente mayor. El único escenario donde se justificaría es si, en Fase 7, la base de código de Godot crece lo suficiente como para necesitar una refactorización masiva multi-archivo, autónoma y de varias horas sin supervisión. Fuera de ese caso puntual, Sonnet 5 y Claude Code cubren todas las necesidades del proyecto con mejor relación costo-beneficio.
