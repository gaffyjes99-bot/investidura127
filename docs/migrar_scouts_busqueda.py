"""
Migración: scouts → scouts_busqueda
Copia solo los campos seguros (nombre, patrulla, grupoId, idScout).

REQUISITO PREVIO: aplicar las reglas de MIGRACIÓN en Firebase Console.
Ver: docs/FIRESTORE_RULES_MIGRACION.md

Ejecutar:
    python docs/migrar_scouts_busqueda.py
"""

import urllib.request
import urllib.error
import json

API_KEY   = "AIzaSyBPFCRvhezdhz27OzPbZJijlOVKLnzKNo4"
PROJECT   = "fichas-actividad-scout"
BASE_URL  = f"https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents"

def get_all_scouts():
    url = f"{BASE_URL}/scouts?key={API_KEY}&pageSize=300"
    req = urllib.request.Request(url)
    with urllib.request.urlopen(req, timeout=15) as resp:
        data = json.loads(resp.read())
    return data.get("documents", [])

def str_field(fields, key):
    return fields.get(key, {}).get("stringValue", "")

def patch_busqueda(doc_id, nombre, patrulla, grupo_id, id_scout):
    url = f"{BASE_URL}/scouts_busqueda/{doc_id}?key={API_KEY}"
    body = {
        "fields": {
            "nombre":   {"stringValue": nombre},
            "patrulla": {"stringValue": patrulla},
            "grupoId":  {"stringValue": grupo_id},
            "idScout":  {"stringValue": id_scout},
        }
    }
    data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request(url, data=data, method="PATCH",
                                  headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=15) as resp:
        return resp.status

def main():
    print("Leyendo colección scouts...")
    docs = get_all_scouts()
    print(f"  {len(docs)} scouts encontrados\n")

    ok = 0
    errores = []

    for doc in docs:
        doc_id  = doc["name"].split("/")[-1]
        fields  = doc.get("fields", {})
        nombre   = str_field(fields, "nombre")
        patrulla = str_field(fields, "patrulla")
        grupo_id = str_field(fields, "grupoId")
        id_scout = str_field(fields, "idScout")

        if not nombre or not patrulla:
            print(f"  ⚠ {doc_id}: sin nombre o patrulla — omitiendo")
            continue

        try:
            status = patch_busqueda(doc_id, nombre, patrulla, grupo_id, id_scout)
            print(f"  ✅ {nombre} ({patrulla})")
            ok += 1
        except urllib.error.HTTPError as e:
            msg = f"HTTP {e.code}"
            print(f"  ❌ {nombre}: {msg}")
            errores.append((doc_id, msg))
        except Exception as e:
            print(f"  ❌ {doc_id}: {e}")
            errores.append((doc_id, str(e)))

    print(f"\n{'='*40}")
    print(f"Migrados: {ok}/{len(docs)}")
    if errores:
        print(f"Errores ({len(errores)}):")
        for d, e in errores:
            print(f"  {d}: {e}")
    else:
        print("Sin errores ✅")
        print("\nSiguiente paso: aplicar reglas FINALES en Firebase Console.")
        print("Ver: docs/FIRESTORE_RULES_FINAL.md")

if __name__ == "__main__":
    main()
