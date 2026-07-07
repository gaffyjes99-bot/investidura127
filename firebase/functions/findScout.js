/**
 * Cloud Function: findScout
 * Busca scout en colección 'scouts' con búsqueda fuzzy (Levenshtein 80%)
 * Protege datos personales - retorna solo scout_id
 *
 * Llamada desde app Godot:
 * POST https://us-central1-fichas-actividad-scout.cloudfunctions.net/findScout
 * Body: { "nombre": "Carlos López", "patrulla": "Jaguares" }
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

/**
 * Calcula distancia Levenshtein entre dos strings
 * @param {string} s1
 * @param {string} s2
 * @returns {number} distancia
 */
function levenshteinDistance(s1, s2) {
  const len1 = s1.length;
  const len2 = s2.length;
  const dp = Array(len1 + 1).fill(null).map(() => Array(len2 + 1).fill(0));

  for (let i = 0; i <= len1; i++) dp[i][0] = i;
  for (let j = 0; j <= len2; j++) dp[0][j] = j;

  for (let i = 1; i <= len1; i++) {
    for (let j = 1; j <= len2; j++) {
      if (s1[i - 1] === s2[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1];
      } else {
        dp[i][j] = 1 + Math.min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]);
      }
    }
  }
  return dp[len1][len2];
}

/**
 * Calcula similitud (0-1) entre dos strings
 * @param {string} s1
 * @param {string} s2
 * @returns {number} similitud (0-1)
 */
function levenshteinSimilarity(s1, s2) {
  const distance = levenshteinDistance(s1, s2);
  const maxLen = Math.max(s1.length, s2.length);
  if (maxLen === 0) return 1.0;
  return 1.0 - (distance / maxLen);
}

/**
 * Busca scout en DB
 * @param {string} nombreInput - nombre del scout
 * @param {string} patrulla - patrulla exacta
 * @returns {Promise<Object>} { scoutId, nombre, patrulla, similarity } o error
 */
async function buscarScout(nombreInput, patrulla) {
  const nombreNorm = nombreInput.toLowerCase().trim();
  const patullaExacta = patrulla.toLowerCase().trim();

  // Consultar scouts de la patrulla
  const snapshot = await db.collection('scouts')
    .where('patrulla', '==', patrulla)
    .get();

  if (snapshot.empty) {
    return {
      error: `No se encontraron scouts en patrulla "${patrulla}"`,
      code: 'PATRULLA_NOT_FOUND'
    };
  }

  // Buscar coincidencias por nombre con similitud >= 80%
  const matches = [];
  snapshot.forEach(doc => {
    const nombreDB = doc.data().nombre || '';
    const nombreNormDB = nombreDB.toLowerCase();
    const similarity = levenshteinSimilarity(nombreNorm, nombreNormDB);

    if (similarity >= 0.80) {
      matches.push({
        scoutId: doc.id,
        nombre: nombreDB,
        patrulla: doc.data().patrulla || patrulla,
        similarity: similarity
      });
    }
  });

  if (matches.length === 0) {
    return {
      error: `Scout "${nombreInput}" no encontrado en patrulla "${patrulla}" (búsqueda fuzzy 80% mínimo)`,
      code: 'SCOUT_NOT_FOUND'
    };
  }

  // Ordenar por similitud descendente
  matches.sort((a, b) => b.similarity - a.similarity);

  if (matches.length === 1) {
    // Una sola coincidencia - retornar
    return {
      scoutId: matches[0].scoutId,
      nombre: matches[0].nombre,
      patrulla: matches[0].patrulla,
      similarity: matches[0].similarity
    };
  }

  // Múltiples coincidencias
  return {
    error: `Se encontraron ${matches.length} scouts similares. Intenta con el nombre completo.`,
    code: 'MULTIPLE_MATCHES',
    matches: matches
  };
}

/**
 * Cloud Function HTTP endpoint
 * POST: { "nombre": "...", "patrulla": "..." }
 * Response: { "scoutId": "...", "nombre": "...", "patrulla": "...", "similarity": 0.95 }
 */
exports.findScout = functions.https.onRequest(async (req, res) => {
  // CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  // Solo POST
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { nombre, patrulla } = req.body;

    // Validar inputs
    if (!nombre || typeof nombre !== 'string') {
      return res.status(400).json({
        error: 'Campo "nombre" requerido y debe ser string',
        code: 'INVALID_INPUT'
      });
    }

    if (!patrulla || typeof patrulla !== 'string') {
      return res.status(400).json({
        error: 'Campo "patrulla" requerido y debe ser string',
        code: 'INVALID_INPUT'
      });
    }

    // Buscar
    const result = await buscarScout(nombre, patrulla);

    // Si hay error
    if (result.error) {
      return res.status(400).json(result);
    }

    // Éxito
    return res.status(200).json({
      scoutId: result.scoutId,
      nombre: result.nombre,
      patrulla: result.patrulla,
      similarity: result.similarity
    });

  } catch (error) {
    console.error('Error en findScout:', error);
    return res.status(500).json({
      error: 'Error interno del servidor',
      message: error.message
    });
  }
});
