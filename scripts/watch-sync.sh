#!/bin/bash
# watch-sync.sh — Sincronización en tiempo real con fswatch
# Detecta cambios en .agents/ y .claude/ y sincroniza automáticamente
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SYNC_SCRIPT="$SCRIPT_DIR/sync-dual.sh"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar que fswatch está disponible
if ! command -v fswatch &> /dev/null; then
    echo -e "${RED}[watch]${NC} fswatch no está instalado."
    echo "  Instalar con: brew install fswatch"
    exit 1
fi

# Verificar que el script de sync existe
if [ ! -x "$SYNC_SCRIPT" ]; then
    echo -e "${RED}[watch]${NC} sync-dual.sh no encontrado o no ejecutable."
    exit 1
fi

echo -e "${BLUE}[watch]${NC} Observando cambios en .agents/ y .claude/"
echo -e "${BLUE}[watch]${NC} Presiona Ctrl+C para detener"
echo ""

# Debounce: ignorar eventos dentro de 2 segundos del último sync
LAST_SYNC=0
DEBOUNCE_SECONDS=2

cd "$PROJECT_ROOT"

fswatch -r \
    --event Created --event Updated --event Renamed --event Removed \
    --exclude '.*\.DS_Store' \
    --exclude '.*plans/.*' \
    --exclude '.*settings\.local\.json' \
    .agents/ .claude/ | while read -r changed_path; do

    # Solo procesar archivos .md
    if [[ "$changed_path" != *.md ]]; then
        continue
    fi

    # Debounce
    current_time=$(date +%s)
    if (( current_time - LAST_SYNC < DEBOUNCE_SECONDS )); then
        continue
    fi
    LAST_SYNC=$current_time

    echo -e "${YELLOW}[watch]${NC} Cambio detectado: $changed_path"

    # Verificar que el archivo existe (podría haber sido eliminado)
    if [ -f "$changed_path" ]; then
        "$SYNC_SCRIPT" --file "$changed_path" || true
    fi

    echo ""
done
