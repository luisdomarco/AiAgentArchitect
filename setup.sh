#!/bin/bash
# =============================================================================
# AiAgentArchitect — Setup para Google Antigravity
# Ejecutar una vez desde la raíz del directorio AiAgentArchitect/
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTIC="$SCRIPT_DIR/agentic"

echo ""
echo "🔧 AiAgentArchitect — Setup para Antigravity"
echo "============================================="
echo "Directorio raíz: $SCRIPT_DIR"
echo ""

# -----------------------------------------------------------------------------
# .agent/ — Antigravity
# Skills, Workflows, Rules
# -----------------------------------------------------------------------------

echo "📁 Creando estructura .agent/ (Antigravity)..."

mkdir -p "$SCRIPT_DIR/.agent"

# Eliminar symlinks anteriores si existen
[ -L "$SCRIPT_DIR/.agent/skills" ]    && rm "$SCRIPT_DIR/.agent/skills"
[ -L "$SCRIPT_DIR/.agent/workflows" ] && rm "$SCRIPT_DIR/.agent/workflows"
[ -L "$SCRIPT_DIR/.agent/rules" ]     && rm "$SCRIPT_DIR/.agent/rules"

# Crear symlinks
ln -s "$AGENTIC/skills"    "$SCRIPT_DIR/.agent/skills"
ln -s "$AGENTIC/workflows" "$SCRIPT_DIR/.agent/workflows"
ln -s "$AGENTIC/rules"     "$SCRIPT_DIR/.agent/rules"

echo "  ✓ .agent/skills    → agentic/skills"
echo "  ✓ .agent/workflows → agentic/workflows"
echo "  ✓ .agent/rules     → agentic/rules"


# -----------------------------------------------------------------------------
# exports/ — directorio de sistemas generados
# -----------------------------------------------------------------------------

mkdir -p "$SCRIPT_DIR/exports"
echo "  ✓ exports/ listo"

# -----------------------------------------------------------------------------
# Verificación final
# -----------------------------------------------------------------------------

echo ""
echo "================================================="
echo "✅ Setup completado. Estructura activa:"
echo ""
echo "  AiAgentArchitect/"
echo "  ├── agentic/          ← source of truth"
echo "  │   ├── workflows/"
echo "  │   ├── agents/"
echo "  │   ├── skills/"
echo "  │   ├── rules/"
echo "  │   └── knowledge-base/"
echo "  ├── .agent/           ← Antigravity (symlinks)"
echo "  │   ├── skills → agentic/skills"
echo "  │   ├── workflows → agentic/workflows"
echo "  │   └── rules → agentic/rules"
echo "  ├── exports/          ← sistemas generados"
echo "  │   └── template/     ← base para nuevos sistemas"
echo "  ├── CLAUDE.md"
echo "  └── setup.sh"
echo ""
echo "Para ejecutar el sistema, abre este directorio en Google Antigravity."
