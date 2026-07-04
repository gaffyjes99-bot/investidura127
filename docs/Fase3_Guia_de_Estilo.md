# Fase 3 — Guía de Estilo Visual
## La Senda del Pietierno

---

## 1. Dirección de arte

**Estilo:** ilustración plana tipo cartoon (flat design), contornos limpios, sin degradados complejos ni texturas de ruido. Optimizado para producirse rápido con Krita + Inkscape y para animarse por partes en Godot (huesos 2D), no como video renderizado cuadro a cuadro.

**Referencia de tono:** cálido, aventurero, ligeramente retro (evoca los años de B.P.) pero legible y atractivo para un adolescente de 2026 — piensa en el cruce entre un cuaderno de campo ilustrado a mano y un juego indie de exploración.

---

## 2. Paleta de colores

| Uso | Color | Hex aproximado |
|---|---|---|
| Verde bosque (primario) | Fondos, vegetación, UI principal | #2E7D32 |
| Café tierra (secundario) | Troncos, tierra, bordón, cuero del uniforme | #6D4C33 |
| Amarillo fogata (acento) | Luz de fogata, destacados, XP, pañoleta | #F2A93B |
| Rojo pañoleta (acento) | Pañoleta del Grupo 127, alertas suaves | #C0392B |
| Azul cielo (fondo) | Cielos, agua, fondos nocturnos con estrellas | #5B8FA8 |
| Crema hueso (neutro claro) | Fondos de UI, tarjetas, pergamino de bitácora | #F4EDE0 |
| Café oscuro (neutro oscuro) | Contornos, texto sobre fondos claros | #3B2A1E |

Regla: máximo 4 colores por escena, siempre incluyendo el verde bosque o el café tierra como ancla. El amarillo fogata se reserva para momentos de logro (insignias, XP, celebración).

---

## 3. Personajes — guía de diseño

| Personaje | Rol narrativo | Rasgos visuales clave |
|---|---|---|
| Baden Powell (joven y adulto) | Narrador principal, Cap. 1, 3, 9, 11, 12 | Sombrero de ala ancha (campaign hat), bigote, uniforme caqui, bordón |
| Scout protagonista (niño/niña, editable) | Avatar del jugador | Cara neutra y expresiva, uniforme que evoluciona con el rango, pañoleta roja/amarilla del Grupo 127 |
| Akela | Narrador Cap. 2 y 10 | Lobo antropomorfizado de pie, postura de líder, mirada firme |
| Kaa | Narradora Cap. 7 | Serpiente estilizada, colores cálidos, postura sabia/tranquila |
| Baloo | Narrador Cap. 4 | Oso robusto, expresión amigable y paciente |
| Jacala | Narrador Cap. 5 | Cocodrilo/caimán estilizado, postura elegante, asociado a símbolos |
| Wontolla | Narrador Cap. 6 | Perro salvaje, porte orgulloso (asociado al uniforme) |
| Kotick | Narrador Cap. 8 | Foca blanca, asociado al sonido y el mar (llamados/silbato) |

Cada personaje: 2–3 poses (neutral, hablando, celebrando) — no animación facial completa, se anima por capas (parpadeo, gesto de manos) en Godot.

---

## 4. Objetos recurrentes (reutilizables entre capítulos)

Bordón, pañoleta (rojo/amarillo), Flor de Lis, fogata, brújula, mapa, morral, carpa, bandera de tropa, silbato/pito. Diseñar cada uno una sola vez en alta resolución vectorial (Inkscape) y reutilizar como sprite en todos los capítulos donde aparezca.

---

## 5. Tipografía

- **Títulos e insignias:** fuente tipo "trazo de campo" (rótulo manual, ligeramente irregular) — evoca cuaderno de bitácora.
- **Cuerpo de texto y diálogos:** fuente sans-serif redondeada, alta legibilidad en pantallas pequeñas (celular), tamaño mínimo 16px equivalente.
- Ambas deben ser fuentes gratuitas con licencia libre (Google Fonts), para mantener el costo en $0.

---

## 6. Fondos reutilizables (8–10 total)

Bosque de día, bosque de noche con fogata, campamento con tiendas, río/lago, sendero de montaña, salón de reuniones de la tropa (interior), mapa de senda general (pantalla de navegación), cielo estrellado. Cada fondo se reutiliza en múltiples capítulos con variaciones de iluminación (día/noche) para maximizar el rendimiento del arte producido.

---

## 7. Principio de composición para las 4 escenas por capítulo

1. **Narración:** personaje narrador en primer plano, fondo desenfocado o simplificado, composición centrada — foco total en el diálogo.
2. **Animación:** composición más abierta (plano medio o general), para mostrar acción y contexto.
3. **Juego:** composición de "mesa de trabajo" — fondo neutro (crema hueso) con los elementos interactivos como protagonistas visuales (cartas, piezas, dibujos a arrastrar).
4. **Evaluación:** composición de quiz — tarjeta central sobre fondo simplificado del capítulo, sin distracciones visuales.
