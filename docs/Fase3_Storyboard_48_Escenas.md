# Fase 3 — Storyboard Detallado
## 48 escenas (4 por capítulo) — especificación para boceto

Formato de cada panel: **Encuadre | Personajes en escena | Acción | Texto/Diálogo en pantalla | Fondo reutilizable | Nota de animación**

---

## Capítulo 1: El Origen del Fuego 🔥 Guardián de la Historia
**Narrador:** Baden Powell (joven, versión animada)

### Panel 1.1 — Escena de Narracion
- **Encuadre:** Plano medio, personaje narrador centrado, fondo simplificado/desenfocado
- **Fondo reutilizable:** Fogata nocturna
- **Acción/Contenido:** B.P. adulto, sentado junto a una fogata, se dirige al jugador: 'Antes de ser Jefe Scout Mundial, fui un niño curioso, un actor de escuela, un soldado en África... Ven, te contaré cómo empezó todo.' Transición a flashback ilustrado.
- **Diálogo en pantalla:** "B.P.: '¿Sabes por qué los guerreros africanos me llamaban Lobo que nunca duerme? Porque un explorador debe estar siempre alerta... y siempre listo.'"
- **Nota de animación:** Animación por capas (parpadeo, gesto de manos), sin lip-sync completo

### Panel 1.2 — Escena de Animacion
- **Encuadre:** Plano general o medio, más contexto y acción visible
- **Fondo reutilizable:** Fondo reutilizable relevante a la escena
- **Acción/Contenido:** Secuencia de 4 viñetas animadas (no video completo, animación por capas en Godot): (1) B.P. niño acampando con sus hermanos en Inglaterra, (2) B.P. joven en la escuela de Charterhouse, (3) el sitio de Mafeking (217 días), (4) el campamento experimental en la isla de Brownsea con 20 muchachos divididos en 4 patrullas.
- **Nota de animación:** Animación de acción principal, ver especificación en escenas.json del capítulo

### Panel 1.3 — Escena de Juego
- **Encuadre:** Composición 'mesa de trabajo', fondo neutro crema hueso, elementos interactivos como protagonistas
- **Fondo reutilizable:** Crema hueso neutro
- **Acción/Contenido:** Novela visual con 2 decisiones ('¿Qué haría B.P.?': ante un peligro en Mafeking, elegir entre 2 opciones; la incorrecta muestra retroalimentación y permite reintentar) + actividad de completar la biografía con espacios en blanco (tomados literalmente de la Bitácora: año de nacimiento, escuela, apodo 'Lobo que nunca duerme', año de Brownsea, nombre del libro de 1908).
- **Nota de animación:** Elementos interactivos con estado hover/drag

### Panel 1.4 — Escena de Evaluacion
- **Encuadre:** Tarjeta de quiz centrada sobre fondo simplificado del capítulo
- **Fondo reutilizable:** Fondo del capítulo, simplificado
- **Acción/Contenido:** 10 preguntas del banco (capitulos/01/preguntas.json), quiz de opción múltiple + completar espacio, mínimo 80% para aprobar.
- **Nota de animación:** Transición de tarjeta con feedback inmediato (correcto/incorrecto)

---

## Capítulo 2: El Código del Explorador ⚖️ Guardián de la Ley
**Narrador:** Akela

### Panel 2.1 — Escena de Narracion
- **Encuadre:** Plano medio, personaje narrador centrado, fondo simplificado/desenfocado
- **Fondo reutilizable:** Bosque de día
- **Acción/Contenido:** Akela explica: 'La Ley no son reglas que te imponen, son compromisos que tú eliges cumplir. Cada artículo es una promesa a ti mismo y a tu hermandad.'
- **Diálogo en pantalla:** "Akela: 'Dime, explorador: ¿cuál de estos 10 artículos te cuesta más cumplir? No hay respuesta incorrecta, solo honestidad.'"
- **Nota de animación:** Animación por capas (parpadeo, gesto de manos), sin lip-sync completo

### Panel 2.2 — Escena de Animacion
- **Encuadre:** Plano general o medio, más contexto y acción visible
- **Fondo reutilizable:** Fondo reutilizable relevante a la escena
- **Acción/Contenido:** 10 mini-viñetas animadas, una por artículo, mostrando una situación cotidiana de un scout que vive ese artículo (ej: artículo 8 'sonríe y canta en sus dificultades' → un scout que se cae en una caminata y se ríe, se levanta y sigue cantando).
- **Nota de animación:** Animación de acción principal, ver especificación en escenas.json del capítulo

### Panel 2.3 — Escena de Juego
- **Encuadre:** Composición 'mesa de trabajo', fondo neutro crema hueso, elementos interactivos como protagonistas
- **Fondo reutilizable:** Crema hueso neutro
- **Acción/Contenido:** Mecánica reutilizable 'Arrastrar y soltar': el scout arrastra cada uno de los 10 artículos (texto exacto de la Bitácora) a su significado/viñeta correspondiente. Modo 2: dada una viñeta, identificar qué artículo ilustra.
- **Nota de animación:** Elementos interactivos con estado hover/drag

### Panel 2.4 — Escena de Evaluacion
- **Encuadre:** Tarjeta de quiz centrada sobre fondo simplificado del capítulo
- **Fondo reutilizable:** Fondo del capítulo, simplificado
- **Acción/Contenido:** 10 preguntas (una por artículo), formato arrastrar/emparejar y opción múltiple, mínimo 80%.
- **Nota de animación:** Transición de tarjeta con feedback inmediato (correcto/incorrecto)

---

## Capítulo 3: Mi Palabra de Honor 🤝 Portador de la Promesa
**Narrador:** Baden Powell

### Panel 3.1 — Escena de Narracion
- **Encuadre:** Plano medio, personaje narrador centrado, fondo simplificado/desenfocado
- **Fondo reutilizable:** Fogata nocturna / sendero de montaña
- **Acción/Contenido:** B.P.: 'Esta promesa es muy difícil de cumplir, precisamente porque es muy seria. El Escultismo no es solo diversión: requiere bastante de ti. Pero sé que harás todo por cumplirla.'
- **Diálogo en pantalla:** "B.P.: 'Recuerda: no prometes ganar, prometes intentar con todo tu esfuerzo. Eso es lo que te hace un scout.'"
- **Nota de animación:** Animación por capas (parpadeo, gesto de manos), sin lip-sync completo

### Panel 3.2 — Escena de Animacion
- **Encuadre:** Plano general o medio, más contexto y acción visible
- **Fondo reutilizable:** Fondo reutilizable relevante a la escena
- **Acción/Contenido:** Animación de una ceremonia de investidura real (silueta de scout ante la Tropa formada, pronunciando la Promesa) para dar contexto emocional antes de memorizar.
- **Nota de animación:** Animación de acción principal, ver especificación en escenas.json del capítulo

### Panel 3.3 — Escena de Juego
- **Encuadre:** Composición 'mesa de trabajo', fondo neutro crema hueso, elementos interactivos como protagonistas
- **Fondo reutilizable:** Crema hueso neutro
- **Acción/Contenido:** Memorización progresiva (mecánica 'completar espacios' con dificultad creciente): 1) texto completo visible, 2) texto con 25% de palabras ocultas, 3) 50% ocultas, 4) 75% ocultas, 5) recitar completo. Opción de grabar audio propio para practicar (no se almacena, solo reproducción local).
- **Nota de animación:** Elementos interactivos con estado hover/drag

### Panel 3.4 — Escena de Evaluacion
- **Encuadre:** Tarjeta de quiz centrada sobre fondo simplificado del capítulo
- **Fondo reutilizable:** Fondo del capítulo, simplificado
- **Acción/Contenido:** Completar la Promesa de memoria (escrita), + 4 preguntas de comprensión sobre su significado, mínimo 80%. NOTA: el texto exacto debe confirmarse con el jefe pedagógico contra el documento oficial de la Asociación Scouts de Colombia antes de producción.
- **Nota de animación:** Transición de tarjeta con feedback inmediato (correcto/incorrecto)

---

## Capítulo 4: Las Raíces 🌳 Raíces Firmes
**Narrador:** Baloo

### Panel 4.1 — Escena de Narracion
- **Encuadre:** Plano medio, personaje narrador centrado, fondo simplificado/desenfocado
- **Fondo reutilizable:** Bosque de día / árbol
- **Acción/Contenido:** Baloo: 'Todo árbol fuerte necesita raíces profundas. Las tuyas son tus principios, tus virtudes y tu fe. Vamos a conocerlas.'
- **Diálogo en pantalla:** "Baloo: 'La Abnegación sig­nifica dar sin esperar nada a cambio. ¿Se te ocurre un momento en que ya lo hayas hecho?'"
- **Nota de animación:** Animación por capas (parpadeo, gesto de manos), sin lip-sync completo

### Panel 4.2 — Escena de Animacion
- **Encuadre:** Plano general o medio, más contexto y acción visible
- **Fondo reutilizable:** Fondo reutilizable relevante a la escena
- **Acción/Contenido:** Árbol animado que crece raíz por raíz a medida que se explica cada principio y virtud; cada raíz se ilumina con su nombre.
- **Nota de animación:** Animación de acción principal, ver especificación en escenas.json del capítulo

### Panel 4.3 — Escena de Juego
- **Encuadre:** Composición 'mesa de trabajo', fondo neutro crema hueso, elementos interactivos como protagonistas
- **Fondo reutilizable:** Crema hueso neutro
- **Acción/Contenido:** Mecánica 'clasificador de categorías': el scout arrastra 6 tarjetas (3 principios + 3 virtudes) a dos canastas correctas. Luego, karaoke de texto resaltado con audio narrado de la Oración Scout, sílaba por sílaba.
- **Nota de animación:** Elementos interactivos con estado hover/drag

### Panel 4.4 — Escena de Evaluacion
- **Encuadre:** Tarjeta de quiz centrada sobre fondo simplificado del capítulo
- **Fondo reutilizable:** Fondo del capítulo, simplificado
- **Acción/Contenido:** 10 preguntas: clasificación, definiciones y orden de la Oración, mínimo 80%.
- **Nota de animación:** Transición de tarjeta con feedback inmediato (correcto/incorrecto)

---

## Capítulo 5: Los Símbolos de la Hermandad ⚜️ Heraldo de la Flor de Lis
**Narrador:** Jacala

### Panel 5.1 — Escena de Narracion
- **Encuadre:** Plano medio, personaje narrador centrado, fondo simplificado/desenfocado
- **Fondo reutilizable:** Río o lago
- **Acción/Contenido:** Jacala: 'Todo pueblo tiene símbolos que lo unen. Los nuestros viajan por el mundo entero: donde haya un scout, hay una Flor de Lis.'
- **Diálogo en pantalla:** "Jacala: 'Cuando saludas con la izquierda, saludas sin escudo, sin defensas. Es un gesto de confianza total en tu hermano scout.'"
- **Nota de animación:** Animación por capas (parpadeo, gesto de manos), sin lip-sync completo

### Panel 5.2 — Escena de Animacion
- **Encuadre:** Plano general o medio, más contexto y acción visible
- **Fondo reutilizable:** Fondo reutilizable relevante a la escena
- **Acción/Contenido:** Animación de un scout ejecutando el saludo completo (45°) y el saludo medio (90°, con y sin bordón); animación del saludo de mano izquierda con la historia de la tribu Ashanti (escudo abajo, mano desprotegida).
- **Nota de animación:** Animación de acción principal, ver especificación en escenas.json del capítulo

### Panel 5.3 — Escena de Juego
- **Encuadre:** Composición 'mesa de trabajo', fondo neutro crema hueso, elementos interactivos como protagonistas
- **Fondo reutilizable:** Crema hueso neutro
- **Acción/Contenido:** Flor de Lis interactiva: tocar cada parte del dibujo revela su significado (contenido a completar por el scout según desafío de la Bitácora, luego confirmado). Quiz visual: armar la flor arrastrando sus partes al lugar correcto. Espejo de cámara opcional (no se guarda imagen) para practicar el saludo, comparando ángulo con una guía animada superpuesta.
- **Nota de animación:** Elementos interactivos con estado hover/drag

### Panel 5.4 — Escena de Evaluacion
- **Encuadre:** Tarjeta de quiz centrada sobre fondo simplificado del capítulo
- **Fondo reutilizable:** Fondo del capítulo, simplificado
- **Acción/Contenido:** 10 preguntas: lema, significado de dedos en la seña, ángulos de saludo, origen del saludo izquierdo, función de la Flor de Lis, mínimo 80%.
- **Nota de animación:** Transición de tarjeta con feedback inmediato (correcto/incorrecto)

---

## Capítulo 6: El Uniforme del Aventurero 🎽 Porte Impecable
**Narrador:** Wontolla

### Panel 6.1 — Escena de Narracion
- **Encuadre:** Plano medio, personaje narrador centrado, fondo simplificado/desenfocado
- **Fondo reutilizable:** Salón de reuniones (interior)
- **Acción/Contenido:** Wontolla: 'Tu uniforme no es solo tela: es orgullo. B.P. decía que quien no lo porta bien, no ha entendido el espíritu del Escultismo.'
- **Diálogo en pantalla:** "Wontolla: 'Ese rojo que llevas en el cuello no es decoración. Es la fuerza de tu espíritu, visible para todos.'"
- **Nota de animación:** Animación por capas (parpadeo, gesto de manos), sin lip-sync completo

### Panel 6.2 — Escena de Animacion
- **Encuadre:** Plano general o medio, más contexto y acción visible
- **Fondo reutilizable:** Fondo reutilizable relevante a la escena
- **Acción/Contenido:** Avatar del scout girando 360° mostrando cada parte del uniforme; al tocar cada parte, se resalta y nombra.
- **Nota de animación:** Animación de acción principal, ver especificación en escenas.json del capítulo

### Panel 6.3 — Escena de Juego
- **Encuadre:** Composición 'mesa de trabajo', fondo neutro crema hueso, elementos interactivos como protagonistas
- **Fondo reutilizable:** Crema hueso neutro
- **Acción/Contenido:** 'Vestir al scout': arrastrar cada insignia (patrulla, progresión, especialidad) a su ubicación correcta en el uniforme (a confirmar con estándar oficial del Grupo 127). Mini-juego de colorear la pañoleta: descubrir tocando cada franja (rojo/amarillo), ver la mini-animación de significado, y colorearla correctamente entre opciones distractoras.
- **Nota de animación:** Elementos interactivos con estado hover/drag

### Panel 6.4 — Escena de Evaluacion
- **Encuadre:** Tarjeta de quiz centrada sobre fondo simplificado del capítulo
- **Fondo reutilizable:** Fondo del capítulo, simplificado
- **Acción/Contenido:** 10 preguntas, incluidas las 2 preguntas fijas de los colores de la pañoleta (rojo = fuerza del espíritu; amarillo = riqueza del alma y el corazón), mínimo 80%.
- **Nota de animación:** Transición de tarjeta con feedback inmediato (correcto/incorrecto)

---

## Capítulo 7: La Buena Acción 💚 Mano Amiga
**Narrador:** Kaa

### Panel 7.1 — Escena de Narracion
- **Encuadre:** Plano medio, personaje narrador centrado, fondo simplificado/desenfocado
- **Fondo reutilizable:** Bosque de noche con fogata
- **Acción/Contenido:** Kaa: 'Una tarde de niebla en Londres, un muchacho ayudó a un extraño sin pedir nada a cambio. Ese gesto cruzó el océano y así nació el Escultismo en Estados Unidos.'
- **Diálogo en pantalla:** "Kaa: 'El muchacho nunca pidió nada. Ese es el secreto: la buena acción pierde su magia si esperas algo a cambio.'"
- **Nota de animación:** Animación por capas (parpadeo, gesto de manos), sin lip-sync completo

### Panel 7.2 — Escena de Animacion
- **Encuadre:** Plano general o medio, más contexto y acción visible
- **Fondo reutilizable:** Fondo reutilizable relevante a la escena
- **Acción/Contenido:** Animación narrativa de la historia completa: la niebla de Londres, el Sr. Boyce perdido, el muchacho scout que lo guía y rechaza la propina, la visita a las oficinas de los Boy Scouts, el encuentro con B.P.
- **Nota de animación:** Animación de acción principal, ver especificación en escenas.json del capítulo

### Panel 7.3 — Escena de Juego
- **Encuadre:** Composición 'mesa de trabajo', fondo neutro crema hueso, elementos interactivos como protagonistas
- **Fondo reutilizable:** Crema hueso neutro
- **Acción/Contenido:** Diario de Buenas Acciones: el scout redacta o dicta una buena acción real de su semana; queda pendiente de validación por un padre o dirigente (código), otorga XP solo tras validar (máx. 1 por semana para evitar farmeo). Además, firma su nombre scout digitalmente en su perfil.
- **Nota de animación:** Elementos interactivos con estado hover/drag

### Panel 7.4 — Escena de Evaluacion
- **Encuadre:** Tarjeta de quiz centrada sobre fondo simplificado del capítulo
- **Fondo reutilizable:** Fondo del capítulo, simplificado
- **Acción/Contenido:** 10 preguntas sobre la historia (ciudad, personajes, por qué rechazó la propina, qué pasó después), mínimo 80%.
- **Nota de animación:** Transición de tarjeta con feedback inmediato (correcto/incorrecto)

---

## Capítulo 8: El Lenguaje de la Tropa 📯 Oído de Explorador
**Narrador:** Kotick

### Panel 8.1 — Escena de Narracion
- **Encuadre:** Plano medio, personaje narrador centrado, fondo simplificado/desenfocado
- **Fondo reutilizable:** Cielo estrellado / campamento
- **Acción/Contenido:** Kotick: 'En el bosque no siempre puedes gritar. Por eso los scouts hablamos con el pito: cada sonido es una palabra.'
- **Diálogo en pantalla:** "Kotick: 'Escucha con atención... ¿reconoces ese llamado? Tu tropa te está diciendo algo ahora mismo.'"
- **Nota de animación:** Animación por capas (parpadeo, gesto de manos), sin lip-sync completo

### Panel 8.2 — Escena de Animacion
- **Encuadre:** Plano general o medio, más contexto y acción visible
- **Fondo reutilizable:** Fondo reutilizable relevante a la escena
- **Acción/Contenido:** Animación de un dirigente tocando distintos llamados y la tropa reaccionando correctamente a cada uno (formarse, guardar silencio, alerta).
- **Nota de animación:** Animación de acción principal, ver especificación en escenas.json del capítulo

### Panel 8.3 — Escena de Juego
- **Encuadre:** Composición 'mesa de trabajo', fondo neutro crema hueso, elementos interactivos como protagonistas
- **Fondo reutilizable:** Crema hueso neutro
- **Acción/Contenido:** Quiz de audio: se reproduce un llamado grabado con el pito real de la tropa, el scout selecciona su significado entre opciones. Modo inverso: se da una instrucción escrita ('Es hora de silencio') y el scout identifica cuál de 3 audios corresponde.
- **Nota de animación:** Elementos interactivos con estado hover/drag

### Panel 8.4 — Escena de Evaluacion
- **Encuadre:** Tarjeta de quiz centrada sobre fondo simplificado del capítulo
- **Fondo reutilizable:** Fondo del capítulo, simplificado
- **Acción/Contenido:** 10 preguntas de audio + comprensión, mínimo 80%. IMPORTANTE: el código exacto de llamados debe ser grabado y confirmado por el dirigente del Grupo 127 antes de producción — no existe un estándar universal.
- **Nota de animación:** Transición de tarjeta con feedback inmediato (correcto/incorrecto)

---

## Capítulo 9: Formaciones y Bordón 🥾 Maestro de Formación
**Narrador:** Baden Powell

### Panel 9.1 — Escena de Narracion
- **Encuadre:** Plano medio, personaje narrador centrado, fondo simplificado/desenfocado
- **Fondo reutilizable:** Fogata nocturna / sendero de montaña
- **Acción/Contenido:** B.P.: 'Una tropa que se forma con orden y rapidez demuestra disciplina y respeto por su hermandad. Y el bordón... el bordón es tu tercer brazo en el camino.'
- **Diálogo en pantalla:** "B.P.: 'Recuerda: el bordón siempre en la mano derecha. Así, en cualquier formación, tu tropa sabrá que estás listo.'"
- **Nota de animación:** Animación por capas (parpadeo, gesto de manos), sin lip-sync completo

### Panel 9.2 — Escena de Animacion
- **Encuadre:** Plano general o medio, más contexto y acción visible
- **Fondo reutilizable:** Fondo reutilizable relevante a la escena
- **Acción/Contenido:** Animación top-down (vista de pájaro) de una tropa ejecutando fila, herradura y círculo al recibir la señal del dirigente; animación del saludo con bordón y posiciones de 'siempre listo' y 'descanso'.
- **Nota de animación:** Animación de acción principal, ver especificación en escenas.json del capítulo

### Panel 9.3 — Escena de Juego
- **Encuadre:** Composición 'mesa de trabajo', fondo neutro crema hueso, elementos interactivos como protagonistas
- **Fondo reutilizable:** Crema hueso neutro
- **Acción/Contenido:** Simulador táctico: se muestra la señal animada del dirigente y el scout debe arrastrar los íconos de patrulla a la formación correcta en un tablero top-down. Galería interactiva de usos del bordón (apoyo, medición, pionerismo).
- **Nota de animación:** Elementos interactivos con estado hover/drag

### Panel 9.4 — Escena de Evaluacion
- **Encuadre:** Tarjeta de quiz centrada sobre fondo simplificado del capítulo
- **Fondo reutilizable:** Fondo del capítulo, simplificado
- **Acción/Contenido:** 10 preguntas sobre formaciones, posiciones y usos del bordón, mínimo 80%.
- **Nota de animación:** Transición de tarjeta con feedback inmediato (correcto/incorrecto)

---

## Capítulo 10: Mi Tropa, Mi Familia 🐾 Espíritu de Patrulla
**Narrador:** Akela

### Panel 10.1 — Escena de Narracion
- **Encuadre:** Plano medio, personaje narrador centrado, fondo simplificado/desenfocado
- **Fondo reutilizable:** Bosque de día
- **Acción/Contenido:** Akela: 'Una tropa no es una lista de cargos, es una familia con roles. Y tu patrulla es tu hogar dentro de esa familia.'
- **Diálogo en pantalla:** "Akela: '¿Ya elegiste tu patrulla? Jaguares, Lobos, Mapaches o Pandas... cada una tiene su propio grito. ¡Hazlo sonar!'"
- **Nota de animación:** Animación por capas (parpadeo, gesto de manos), sin lip-sync completo

### Panel 10.2 — Escena de Animacion
- **Encuadre:** Plano general o medio, más contexto y acción visible
- **Fondo reutilizable:** Fondo reutilizable relevante a la escena
- **Acción/Contenido:** Animación del organigrama construyéndose pieza por pieza (Jefe de Grupo → Jefe de Tropa → Guías de Patrulla → Subguías → Scouts).
- **Nota de animación:** Animación de acción principal, ver especificación en escenas.json del capítulo

### Panel 10.3 — Escena de Juego
- **Encuadre:** Composición 'mesa de trabajo', fondo neutro crema hueso, elementos interactivos como protagonistas
- **Fondo reutilizable:** Crema hueso neutro
- **Acción/Contenido:** Constructor de organigrama: arrastrar nombres reales de la tropa (a cargar por el dirigente) a su cargo correcto. Editor de ficha de patrulla: elegir/dibujar animal, escribir lema y grito, dibujar banderín (mini-editor simple de trazos y colores).
- **Nota de animación:** Elementos interactivos con estado hover/drag

### Panel 10.4 — Escena de Evaluacion
- **Encuadre:** Tarjeta de quiz centrada sobre fondo simplificado del capítulo
- **Fondo reutilizable:** Fondo del capítulo, simplificado
- **Acción/Contenido:** 10 preguntas sobre estructura de patrulla y organigrama (algunas con datos reales de la tropa, a cargo del dirigente), mínimo 80%.
- **Nota de animación:** Transición de tarjeta con feedback inmediato (correcto/incorrecto)

---

## Capítulo 11: La Prueba del Campista ⛺ Bajo las Estrellas
**Narrador:** Baden Powell

### Panel 11.1 — Escena de Narracion
- **Encuadre:** Plano medio, personaje narrador centrado, fondo simplificado/desenfocado
- **Fondo reutilizable:** Fogata nocturna / sendero de montaña
- **Acción/Contenido:** B.P.: 'Ningún libro reemplaza dormir bajo las estrellas. Esto no se aprende aquí: se vive allá afuera. Yo solo llevo la cuenta contigo.'
- **Diálogo en pantalla:** "B.P.: 'No dejes signos de que estuviste ahí, salvo en tu propio corazón y en tu bitácora.'"
- **Nota de animación:** Animación por capas (parpadeo, gesto de manos), sin lip-sync completo

### Panel 11.2 — Escena de Animacion
- **Encuadre:** Plano general o medio, más contexto y acción visible
- **Fondo reutilizable:** Fondo reutilizable relevante a la escena
- **Acción/Contenido:** Animación de un campamento nocturno con fogata, tiendas y estrellas; contador visual que se ilumina con cada noche registrada.
- **Nota de animación:** Animación de acción principal, ver especificación en escenas.json del capítulo

### Panel 11.3 — Escena de Juego
- **Encuadre:** Composición 'mesa de trabajo', fondo neutro crema hueso, elementos interactivos como protagonistas
- **Fondo reutilizable:** Crema hueso neutro
- **Acción/Contenido:** Bitácora de campamento digital: el scout registra fecha y lugar de cada noche de campamento; el dirigente confirma con un código de 6 dígitos. Contador de meses de participación activa desde el registro de ingreso a la tropa.
- **Nota de animación:** Elementos interactivos con estado hover/drag

### Panel 11.4 — Escena de Evaluacion
- **Encuadre:** Tarjeta de quiz centrada sobre fondo simplificado del capítulo
- **Fondo reutilizable:** Fondo del capítulo, simplificado
- **Acción/Contenido:** No es un quiz tradicional: la 'evaluación' es el cumplimiento real de los requisitos (2 noches validadas + 4 meses cumplidos). 5 preguntas de comprensión sobre campismo de bajo impacto y planificación de salidas.
- **Nota de animación:** Transición de tarjeta con feedback inmediato (correcto/incorrecto)

---

## Capítulo 12: La Gran Ceremonia 🏅 Candidato a Investidura
**Narrador:** Todos los personajes (cameo final de cada uno)

### Panel 12.1 — Escena de Narracion
- **Encuadre:** Plano medio, personaje narrador centrado, fondo simplificado/desenfocado
- **Fondo reutilizable:** Mapa de senda general
- **Acción/Contenido:** Cada personaje narrador aparece brevemente: 'Has llegado lejos, explorador. Pero antes de la gran ceremonia, demuestra que dominas todo lo aprendido.'
- **Diálogo en pantalla:** "Baden Powell (cierre): 'Ahora ve con tu dirigente y pide tu ceremonia. Lo que sigue, ya no lo aprendes en una pantalla: lo vives ante tu Tropa.'"
- **Nota de animación:** Animación por capas (parpadeo, gesto de manos), sin lip-sync completo

### Panel 12.2 — Escena de Animacion
- **Encuadre:** Plano general o medio, más contexto y acción visible
- **Fondo reutilizable:** Fondo reutilizable relevante a la escena
- **Acción/Contenido:** Mapa de senda completo iluminándose capítulo por capítulo como recapitulación visual antes del examen.
- **Nota de animación:** Animación de acción principal, ver especificación en escenas.json del capítulo

### Panel 12.3 — Escena de Juego
- **Encuadre:** Composición 'mesa de trabajo', fondo neutro crema hueso, elementos interactivos como protagonistas
- **Fondo reutilizable:** Crema hueso neutro
- **Acción/Contenido:** Examen final integrador de 20 preguntas mezclando los 12 capítulos (incluye las 2 preguntas fijas de la pañoleta), mínimo 80% para aprobar. Reintentos ilimitados sin penalización.
- **Nota de animación:** Elementos interactivos con estado hover/drag

### Panel 12.4 — Escena de Evaluacion
- **Encuadre:** Tarjeta de quiz centrada sobre fondo simplificado del capítulo
- **Fondo reutilizable:** Fondo del capítulo, simplificado
- **Acción/Contenido:** Validación de comportamiento en el hogar (código de padres) + validación de rendimiento académico (código de dirigente). Al cumplir ambas + aprobar el examen: se desbloquea la animación de la Gran Ceremonia (llamado de pito → formación → bandera → Promesa → entrega de pañoleta → puente de tropa → Investidura).
- **Nota de animación:** Transición de tarjeta con feedback inmediato (correcto/incorrecto)

---
