#!/bin/bash
# sync-dual.sh — Sincronización bidireccional .agents/ ↔ .claude/
# Parte del sistema dual AiAgentArchitect
set -euo pipefail

# ─── Configuración ───────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_DIR="$PROJECT_ROOT/.agents"
CLAUDE_DIR="$PROJECT_ROOT/.claude"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
SYNCED=0
ERRORS=0

# ─── Funciones de utilidad ───────────────────────────────────────────────────

log_info()  { echo -e "${BLUE}[sync]${NC} $1"; }
log_ok()    { echo -e "${GREEN}[sync]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[sync]${NC} $1"; }
log_error() { echo -e "${RED}[sync]${NC} $1"; }

usage() {
    cat <<EOF
Uso: sync-dual.sh [opción]

Opciones:
  --auto               Detecta dirección automáticamente y sincroniza
  --agents-to-claude   Sincroniza .agents/ → .claude/
  --claude-to-agents   Sincroniza .claude/ → .agents/
  --validate           Solo valida sincronización, no modifica nada
  --file <path>        Sincroniza un archivo específico
  -h, --help           Muestra esta ayuda

Ejemplos:
  ./scripts/sync-dual.sh --auto
  ./scripts/sync-dual.sh --agents-to-claude
  ./scripts/sync-dual.sh --file .agents/rules/rul-audit-behavior.md
EOF
    exit 0
}

# ─── Transformaciones de rutas ───────────────────────────────────────────────

# Transforma rutas de .agents/ a .claude/
transform_agents_to_claude() {
    local file="$1"

    # Referencias a agents: ./age-spe-* → ../agents/age-spe-*
    sed -i '' 's|\./age-spe-|../agents/age-spe-|g' "$file"
    sed -i '' 's|\./age-sup-|../agents/age-sup-|g' "$file"

    # Referencias a skills: ../skills/ski-NAME/SKILL.md → ../skills/ski-NAME.md
    sed -i '' 's|\.\./skills/ski-\([^/]*\)/SKILL\.md|../skills/ski-\1.md|g' "$file"
}

# Transforma rutas de .claude/ a .agents/
transform_claude_to_agents() {
    local file="$1"

    # Referencias a agents: ../agents/age-spe-* → ./age-spe-*
    sed -i '' 's|\.\./agents/age-spe-|./age-spe-|g' "$file"
    sed -i '' 's|\.\./agents/age-sup-|./age-sup-|g' "$file"

    # Referencias a skills: ../skills/ski-NAME.md → ../skills/ski-NAME/SKILL.md
    sed -i '' 's|\.\./skills/ski-\([^/.]*\)\.md|../skills/ski-\1/SKILL.md|g' "$file"
}

# ─── Sincronización por archivo ──────────────────────────────────────────────

# Sincroniza un archivo de .agents/ → .claude/
sync_file_to_claude() {
    local src="$1"
    local relative="${src#$AGENTS_DIR/}"
    local dest=""
    local needs_transform=false

    case "$relative" in
        workflows/wor-*.md|workflows/test.md|workflows/com-*.md)
            dest="$CLAUDE_DIR/commands/$(basename "$src")"
            needs_transform=true
            ;;
        workflows/age-*.md)
            dest="$CLAUDE_DIR/agents/$(basename "$src")"
            needs_transform=true
            ;;
        skills/ski-*/SKILL.md)
            local skill_name
            skill_name=$(echo "$relative" | sed 's|skills/\(ski-[^/]*\)/SKILL.md|\1|')
            dest="$CLAUDE_DIR/skills/${skill_name}.md"
            ;;
        rules/*.md|knowledge-base/*.md|resources/*.md)
            dest="$CLAUDE_DIR/$relative"
            ;;
        *)
            log_warn "Archivo no mapeado: $relative"
            return 0
            ;;
    esac

    cp "$src" "$dest"
    if [ "$needs_transform" = true ]; then
        transform_agents_to_claude "$dest"
    fi
    SYNCED=$((SYNCED + 1))
    log_ok "  $relative → ${dest#$PROJECT_ROOT/}"
}

# Sincroniza un archivo de .claude/ → .agents/
sync_file_to_agents() {
    local src="$1"
    local relative="${src#$CLAUDE_DIR/}"
    local dest=""
    local needs_transform=false

    case "$relative" in
        commands/wor-*.md|commands/test.md|commands/com-*.md)
            dest="$AGENTS_DIR/workflows/$(basename "$src")"
            needs_transform=true
            ;;
        agents/age-*.md)
            dest="$AGENTS_DIR/workflows/$(basename "$src")"
            needs_transform=true
            ;;
        skills/ski-*.md)
            local skill_name
            skill_name=$(basename "$src" .md)
            mkdir -p "$AGENTS_DIR/skills/${skill_name}"
            dest="$AGENTS_DIR/skills/${skill_name}/SKILL.md"
            ;;
        rules/*.md|knowledge-base/*.md|resources/*.md)
            dest="$AGENTS_DIR/$relative"
            ;;
        settings.local.json|plans/*)
            return 0  # Archivos específicos de Claude Code, no sincronizar
            ;;
        *)
            log_warn "Archivo no mapeado: $relative"
            return 0
            ;;
    esac

    cp "$src" "$dest"
    if [ "$needs_transform" = true ]; then
        transform_claude_to_agents "$dest"
    fi
    SYNCED=$((SYNCED + 1))
    log_ok "  $relative → ${dest#$PROJECT_ROOT/}"
}

# ─── Sincronización completa ────────────────────────────────────────────────

sync_agents_to_claude() {
    log_info "Sincronizando .agents/ → .claude/"
    SYNCED=0

    # Workflows y agents
    for f in "$AGENTS_DIR"/workflows/*.md; do
        [ -f "$f" ] && sync_file_to_claude "$f"
    done

    # Skills (aplanar)
    for skill_dir in "$AGENTS_DIR"/skills/ski-*/; do
        [ -f "${skill_dir}SKILL.md" ] && sync_file_to_claude "${skill_dir}SKILL.md"
    done

    # Rules
    for f in "$AGENTS_DIR"/rules/*.md; do
        [ -f "$f" ] && sync_file_to_claude "$f"
    done

    # Knowledge-base
    for f in "$AGENTS_DIR"/knowledge-base/*.md; do
        [ -f "$f" ] && sync_file_to_claude "$f"
    done

    # Resources
    for f in "$AGENTS_DIR"/resources/*.md; do
        [ -f "$f" ] && sync_file_to_claude "$f"
    done

    log_ok "Sincronización completada: $SYNCED archivos"
}

sync_claude_to_agents() {
    log_info "Sincronizando .claude/ → .agents/"
    SYNCED=0

    # Commands
    for f in "$CLAUDE_DIR"/commands/*.md; do
        [ -f "$f" ] && sync_file_to_agents "$f"
    done

    # Agents
    for f in "$CLAUDE_DIR"/agents/*.md; do
        [ -f "$f" ] && sync_file_to_agents "$f"
    done

    # Skills (des-aplanar)
    for f in "$CLAUDE_DIR"/skills/ski-*.md; do
        [ -f "$f" ] && sync_file_to_agents "$f"
    done

    # Rules
    for f in "$CLAUDE_DIR"/rules/*.md; do
        [ -f "$f" ] && sync_file_to_agents "$f"
    done

    # Knowledge-base
    for f in "$CLAUDE_DIR"/knowledge-base/*.md; do
        [ -f "$f" ] && sync_file_to_agents "$f"
    done

    # Resources
    for f in "$CLAUDE_DIR"/resources/*.md; do
        [ -f "$f" ] && sync_file_to_agents "$f"
    done

    log_ok "Sincronización completada: $SYNCED archivos"
}

# ─── Detección automática de dirección ───────────────────────────────────────

detect_and_sync() {
    log_info "Detectando dirección de sincronización..."

    # Buscar el archivo más recientemente modificado en cada lado
    local agents_newest claude_newest
    agents_newest=$(find "$AGENTS_DIR" -name "*.md" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | head -1 | awk '{print $1}')
    claude_newest=$(find "$CLAUDE_DIR" \( -name "*.md" -type f \) -not -path "*/plans/*" -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | head -1 | awk '{print $1}')

    if [ -z "$agents_newest" ] && [ -z "$claude_newest" ]; then
        log_warn "No se encontraron archivos .md en ningún lado"
        exit 1
    fi

    agents_newest=${agents_newest:-0}
    claude_newest=${claude_newest:-0}

    if [ "$agents_newest" -gt "$claude_newest" ]; then
        log_info "Cambios más recientes detectados en .agents/"
        sync_agents_to_claude
    elif [ "$claude_newest" -gt "$agents_newest" ]; then
        log_info "Cambios más recientes detectados en .claude/"
        sync_claude_to_agents
    else
        log_ok "Ambos lados tienen la misma fecha. No se requiere sincronización."
    fi
}

# ─── Sincronización de archivo individual ────────────────────────────────────

sync_single_file() {
    local file_path="$1"

    # Normalizar a ruta absoluta si es relativa
    if [[ "$file_path" != /* ]]; then
        file_path="$PROJECT_ROOT/$file_path"
    fi

    if [[ "$file_path" == "$AGENTS_DIR"/* ]]; then
        log_info "Sincronizando archivo .agents/ → .claude/"
        sync_file_to_claude "$file_path"
    elif [[ "$file_path" == "$CLAUDE_DIR"/* ]]; then
        log_info "Sincronizando archivo .claude/ → .agents/"
        sync_file_to_agents "$file_path"
    else
        log_error "Archivo fuera de .agents/ y .claude/: $file_path"
        exit 1
    fi

    log_ok "Archivo sincronizado: $SYNCED"
}

# ─── Validación ──────────────────────────────────────────────────────────────

validate() {
    log_info "Validando sincronización..."
    local errors=0

    # Contar archivos
    local agents_count claude_count
    agents_count=$(find "$AGENTS_DIR" -name "*.md" -type f | wc -l | tr -d ' ')
    claude_count=$(find "$CLAUDE_DIR" -name "*.md" -type f -not -path "*/plans/*" | wc -l | tr -d ' ')

    log_info "Archivos .md en .agents/: $agents_count"
    log_info "Archivos .md en .claude/: $claude_count"

    if [ "$agents_count" -ne "$claude_count" ]; then
        log_error "Diferente cantidad de archivos: .agents/=$agents_count .claude/=$claude_count"
        errors=$((errors + 1))
    fi

    # Verificar conteo por directorio
    local expected_commands=2 expected_agents=7 expected_skills=10
    local expected_rules=5 expected_kb=8 expected_resources=6

    local actual_commands actual_agents actual_skills actual_rules actual_kb actual_resources
    actual_commands=$(find "$CLAUDE_DIR/commands" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    actual_agents=$(find "$CLAUDE_DIR/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    actual_skills=$(find "$CLAUDE_DIR/skills" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    actual_rules=$(find "$CLAUDE_DIR/rules" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    actual_kb=$(find "$CLAUDE_DIR/knowledge-base" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    actual_resources=$(find "$CLAUDE_DIR/resources" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

    [ "$actual_commands" -ne "$expected_commands" ] && log_error "commands/: esperado $expected_commands, encontrado $actual_commands" && errors=$((errors + 1))
    [ "$actual_agents" -ne "$expected_agents" ] && log_error "agents/: esperado $expected_agents, encontrado $actual_agents" && errors=$((errors + 1))
    [ "$actual_skills" -ne "$expected_skills" ] && log_error "skills/: esperado $expected_skills, encontrado $actual_skills" && errors=$((errors + 1))
    [ "$actual_rules" -ne "$expected_rules" ] && log_error "rules/: esperado $expected_rules, encontrado $actual_rules" && errors=$((errors + 1))
    [ "$actual_kb" -ne "$expected_kb" ] && log_error "knowledge-base/: esperado $expected_kb, encontrado $actual_kb" && errors=$((errors + 1))
    [ "$actual_resources" -ne "$expected_resources" ] && log_error "resources/: esperado $expected_resources, encontrado $actual_resources" && errors=$((errors + 1))

    # Verificar que no queden patrones sin transformar en .claude/
    if grep -rq '\./age-spe-\|\.\/age-sup-' "$CLAUDE_DIR/commands/" 2>/dev/null; then
        log_error "Encontradas referencias ./age-spe- o ./age-sup- sin transformar en .claude/commands/"
        errors=$((errors + 1))
    fi

    if grep -rq 'SKILL\.md' "$CLAUDE_DIR/commands/" "$CLAUDE_DIR/agents/" 2>/dev/null | grep -v '\[nombre-skill\]' | grep -q .; then
        log_error "Encontradas referencias a SKILL.md sin transformar en .claude/"
        errors=$((errors + 1))
    fi

    # Verificar que no queden patrones sin transformar en .agents/
    if grep -rq '\.\./agents/age-spe-\|\.\./agents/age-sup-' "$AGENTS_DIR/workflows/" 2>/dev/null; then
        log_error "Encontradas referencias ../agents/age-spe- sin transformar en .agents/workflows/"
        errors=$((errors + 1))
    fi

    # Verificar contenido idéntico en rules, KB, resources
    for dir in rules knowledge-base resources; do
        for f in "$AGENTS_DIR/$dir"/*.md; do
            [ -f "$f" ] || continue
            local basename_f
            basename_f=$(basename "$f")
            local claude_f="$CLAUDE_DIR/$dir/$basename_f"
            if [ -f "$claude_f" ]; then
                if ! diff -q "$f" "$claude_f" > /dev/null 2>&1; then
                    log_error "Contenido difiere en $dir/$basename_f"
                    errors=$((errors + 1))
                fi
            else
                log_error "Falta en .claude/: $dir/$basename_f"
                errors=$((errors + 1))
            fi
        done
    done

    # Resultado
    if [ "$errors" -eq 0 ]; then
        log_ok "Validación exitosa: ambas estructuras están sincronizadas"
        return 0
    else
        log_error "Validación fallida: $errors errores encontrados"
        return 1
    fi
}

# ─── Main ────────────────────────────────────────────────────────────────────

cd "$PROJECT_ROOT"

case "${1:---help}" in
    --auto)
        detect_and_sync
        ;;
    --agents-to-claude)
        sync_agents_to_claude
        ;;
    --claude-to-agents)
        sync_claude_to_agents
        ;;
    --validate)
        validate
        ;;
    --file)
        if [ -z "${2:-}" ]; then
            log_error "Se requiere la ruta del archivo: --file <path>"
            exit 1
        fi
        sync_single_file "$2"
        ;;
    -h|--help)
        usage
        ;;
    *)
        log_error "Opción desconocida: $1"
        usage
        ;;
esac
