# Capítulo 1: El Origen del Fuego
**Insignia:** 🔥 Guardián de la Historia
**Narrador:** Baden Powell (joven, versión animada)
**Requisitos de la Tabla de Progresión cubiertos:** 1. Qué es el Escultismo | 18. Quién fue B.P.

## Objetivo de aprendizaje
El scout comprende qué es el Escultismo y conoce los hitos clave de la vida de su fundador, Robert Baden Powell.

## Escena 1 — Narración
B.P. adulto, sentado junto a una fogata, se dirige al jugador: 'Antes de ser Jefe Scout Mundial, fui un niño curioso, un actor de escuela, un soldado en África... Ven, te contaré cómo empezó todo.' Transición a flashback ilustrado.

**Diálogo de muestra:**
> B.P.: '¿Sabes por qué los guerreros africanos me llamaban Lobo que nunca duerme? Porque un explorador debe estar siempre alerta... y siempre listo.'

## Escena 2 — Animación (REVISADO — técnicamente viable en Godot 2D)
Técnica: **efecto Ken Burns** (paneo y zoom lento con Tween/AnimationPlayer sobre una ilustración estática única por viñeta) + capas simples con movimiento aislado, NO animación de personajes en acción ni escenas de multitud. Esto se logra 100% con nodos Sprite2D/TextureRect y un Tween moviendo posición/escala de cámara.

4 viñetas, cada una es UNA sola ilustración estática (no una secuencia de fotogramas de acción):
1. **Niñez de B.P.:** ilustración estática de B.P. niño con sus hermanos frente a una carpa. Ken Burns: zoom lento de un plano general a un primer plano de su cara. Elemento animado aislado: humo de fogata con partículas simples (Godot Particles2D).
2. **Charterhouse:** ilustración estática de B.P. joven frente al edificio de la escuela. Ken Burns: paneo horizontal lento. Elemento animado aislado: hojas cayendo (Particles2D).
3. **Mafeking:** ilustración estática de silueta de B.P. observando el horizonte desde una fortificación (sin mostrar batalla ni multitudes, se sugiere con sombras/siluetas lejanas fijas). Ken Burns: zoom lento hacia el horizonte. Elemento animado aislado: bandera ondeando (sprite de 2-3 frames en loop, no animación de cuerpo completo).
4. **Brownsea:** ilustración estática de un campamento con carpas y una fogata central (los "20 muchachos" se sugieren como pequeñas siluetas sentadas alrededor de la fogata, dibujadas ya en la ilustración fija, no animadas individualmente). Ken Burns: zoom out revelando el campamento completo. Elemento animado aislado: fogata con partículas de fuego (2-3 frames en loop).

**Regla general para todo el proyecto:** cuando una escena de "animación" en el guion original implique acción histórica compleja, multitudes, o movimiento de cuerpo completo de varios personajes, se reemplaza por: 1 ilustración estática + Ken Burns (paneo/zoom) + máximo 1-2 elementos aislados con loop simple (partículas, sprite de 2-3 frames). Ningún capítulo requiere animación de personaje completo tipo video.

## Escena 3 — Juego (mecánica interactiva)
Novela visual con 2 decisiones ('¿Qué haría B.P.?': ante un peligro en Mafeking, elegir entre 2 opciones; la incorrecta muestra retroalimentación y permite reintentar) + actividad de completar la biografía con espacios en blanco (tomados literalmente de la Bitácora: año de nacimiento, escuela, apodo 'Lobo que nunca duerme', año de Brownsea, nombre del libro de 1908).

## Escena 4 — Evaluación
10 preguntas del banco (capitulos/01/preguntas.json), quiz de opción múltiple + completar espacio, mínimo 80% para aprobar.

## Reglas de XP de este capítulo
Lectura +10 | Cada viñeta vista +5 | Decisión narrativa tomada +10 c/u | Biografía completada +20 | Quiz aprobado +30 | Quiz perfecto +15 bonus

## Insignia al completar
🔥 Guardián de la Historia
