#!/bin/bash
# sync-dual.sh — Sincronización bidireccional .agents/ ↔ .claude/
# Parte del sistema dual AiAgentArchitect
set -euo pipefail

# ─── Configuración ───────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT_DEFAULT="$(cd "$SCRIPT_DIR/.." && pwd)"
# PROJECT_ROOT, AGENTS_DIR, CLAUDE_DIR are set after argument parsing because
# --target may override them to point at exports/{name}/ instead of the parent.
PROJECT_ROOT="$PROJECT_ROOT_DEFAULT"
AGENTS_DIR="$PROJECT_ROOT/.agents"
CLAUDE_DIR="$PROJECT_ROOT/.claude"
TARGET_ARG=""   # populated by --target=<dir> if present

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
Uso: sync-dual.sh [opción] [--prune] [--target=<dir>]

Opciones:
  --auto               Detecta dirección automáticamente y sincroniza
  --agents-to-claude   Sincroniza .agents/ → .claude/ (incluye layers/)
  --claude-to-agents   Sincroniza .claude/ → .agents/ (solo raíz; layers no soportado)
  --validate           Solo valida sincronización, no modifica nada
  --file <path>        Sincroniza un archivo específico
  --prune              Tras .agents/ → .claude/, borra archivos en .claude/
                       que no tienen contraparte en .agents/ (ni raíz ni layers).
                       Úsalo tras un refactor mayor (e.g. mover entidades a una capa).
  --target=<dir>       Apunta a un export en lugar del root (e.g. --target=exports/foo).
                       Si <dir>/config/manifest.yaml existe y 'claude-code' NO está en
                       sus 'platforms', el script aborta con un mensaje "Skipping" y
                       exit 0 (no es error). Sin --target opera sobre el root.
  -h, --help           Muestra esta ayuda

Notas v3:
  - .agents/layers/{layer-id}/  se replica a  .claude/layers/{layer-id}/
  - Slash commands de capa (.agents/layers/{X}/commands/*.md) también se copian a
    .claude/commands/ raíz para que sean descubribles por Claude Code.
  - La dirección .claude/ → .agents/ NO maneja layers; siempre edita en .agents/.
  - Con --target, el script lee <dir>/config/manifest.yaml para respetar 'platforms'
    del subsistema. Sin manifest, opera como antes (genera todo).

Ejemplos:
  ./scripts/sync-dual.sh --auto
  ./scripts/sync-dual.sh --agents-to-claude --prune
  ./scripts/sync-dual.sh --target=exports/foo --agents-to-claude --prune
  ./scripts/sync-dual.sh --file .agents/layers/memory/skills/ski-memory-manager/SKILL.md
EOF
    exit 0
}

# ─── Platform check (v3): respect subsystem manifest's 'platforms' list ─────
# Reads <PROJECT_ROOT>/config/manifest.yaml and parses 'platforms' with a
# light parser (no PyYAML dependency). Returns 0 if the given platform is in
# the list (or if the manifest is missing — backward-compat with root and
# pre-v3 exports). Returns 1 (with a "Skipping" message) if the platform is
# explicitly absent.
check_platform_active() {
    local platform="$1"
    local manifest="$PROJECT_ROOT/config/manifest.yaml"
    [ -f "$manifest" ] || return 0   # no manifest → permissive

    # Light YAML parse: find the 'platforms:' block and look for '- $platform'.
    # Stops scanning when a top-level key (no leading whitespace, not a comment,
    # not the platforms block itself) is found, signaling end of the list.
    if awk -v target="$platform" '
        BEGIN { in_block = 0; found = 0 }
        /^platforms:/ { in_block = 1; next }
        in_block {
            # Continue scanning while the line is a list item or indented
            if ($0 ~ /^[[:space:]]*-/) {
                # Strip "- " and any quotes
                item = $0
                sub(/^[[:space:]]*-[[:space:]]*/, "", item)
                gsub(/["'\'']/, "", item)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", item)
                if (item == target) { found = 1; exit }
                next
            }
            if ($0 ~ /^[[:space:]]/) next   # nested non-list line, keep in block
            if ($0 ~ /^#/) next             # comment
            in_block = 0                    # top-level key → end of platforms
        }
        END { exit (found ? 0 : 1) }
    ' "$manifest"; then
        return 0
    fi

    log_info "Skipping .claude/ sync — '$platform' not in platforms of $manifest"
    return 1
}

# ─── Transformaciones de rutas ───────────────────────────────────────────────

# Transforma rutas de .agents/ a .claude/
# Args:
#   $1 file — target file in .claude/ to transform in-place
#   $2 layer_id — optional. When set, the file is a layer entity being aliased
#                 to a canonical .claude/ root (commands/, agents/, skills/).
#                 Layer-internal relative refs (../rules/, ../knowledge-base/,
#                 ../skills/, ../resources/) are rewritten to ../layers/$layer_id/...
#                 so they resolve from the alias's new location. Pass empty to skip.
transform_agents_to_claude() {
    local file="$1"
    local layer_id="${2:-}"

    # Referencias a agents: ./age-spe-* → ../agents/age-spe-*
    sed -i '' 's|\./age-spe-|../agents/age-spe-|g' "$file"
    sed -i '' 's|\./age-sup-|../agents/age-sup-|g' "$file"

    # (v3.0.0-alpha.5) Map Gemini model names to Claude equivalents.
    # The .agents/ source uses Gemini (Antigravity native); .claude/ needs Claude.
    # Without this, CC silently rejects the agent (model not recognized) and the
    # whole workflow fails to load. build-codex.py does the analogous Gemini→GPT
    # mapping for Codex.
    sed -i '' 's|^model: gemini-3-flash$|model: haiku|'   "$file"
    sed -i '' 's|^model: gemini-3\.1$|model: sonnet|'     "$file"
    sed -i '' 's|^model: gemini-3\.1-pro$|model: opus|'   "$file"
    sed -i '' 's|^model: gemini-2\.0-flash$|model: haiku|' "$file"
    sed -i '' 's|^model: gemini-2\.5-pro$|model: sonnet|' "$file"
    # Catch-all: any other gemini-* → sonnet (safe default for unknown variants).
    # Order matters: specific maps above run first; this only fires on what they didn't catch.
    sed -i '' 's|^model: gemini-[a-zA-Z0-9.-]*$|model: sonnet|' "$file"

    # Layer-aware rewrite: when aliasing a layer entity to .claude/ root,
    # ../rules/X resolves from the alias's new home. Rewrite to ../layers/$layer_id/...
    # Only single-dot-dot prefix is handled; cross-layer refs (../../../../skills/...)
    # have a different shape and are left untouched.
    if [ -n "$layer_id" ]; then
        sed -i '' "s|\\.\\./rules/|../layers/${layer_id}/rules/|g"                   "$file"
        sed -i '' "s|\\.\\./knowledge-base/|../layers/${layer_id}/knowledge-base/|g" "$file"
        sed -i '' "s|\\.\\./skills/|../layers/${layer_id}/skills/|g"                 "$file"
        sed -i '' "s|\\.\\./resources/|../layers/${layer_id}/resources/|g"           "$file"
    fi

    # Skills paths are now identical between platforms (ski-NAME/SKILL.md) — no transformation needed
}

# Transforma rutas de .claude/ a .agents/
transform_claude_to_agents() {
    local file="$1"

    # Referencias a agents: ../agents/age-spe-* → ./age-spe-*
    sed -i '' 's|\.\./agents/age-spe-|./age-spe-|g' "$file"
    sed -i '' 's|\.\./agents/age-sup-|./age-sup-|g' "$file"

    # Skills paths are now identical between platforms (ski-NAME/SKILL.md) — no transformation needed
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
            local skill_dir
            skill_dir=$(echo "$relative" | sed 's|skills/\(ski-[^/]*\)/SKILL.md|\1|')
            mkdir -p "$CLAUDE_DIR/skills/${skill_dir}"
            dest="$CLAUDE_DIR/skills/${skill_dir}/SKILL.md"
            ;;
        rules/*.md|knowledge-base/*.md|resources/*.md)
            dest="$CLAUDE_DIR/$relative"
            ;;
        scripts/scp-*|hooks/hok-*.md)
            mkdir -p "$CLAUDE_DIR/$(dirname "$relative")"
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
        skills/ski-*/SKILL.md)
            local skill_dir
            skill_dir=$(echo "$relative" | sed 's|skills/\(ski-[^/]*\)/SKILL.md|\1|')
            mkdir -p "$AGENTS_DIR/skills/${skill_dir}"
            dest="$AGENTS_DIR/skills/${skill_dir}/SKILL.md"
            ;;
        rules/*.md|knowledge-base/*.md|resources/*.md)
            dest="$AGENTS_DIR/$relative"
            ;;
        scripts/scp-*|hooks/hok-*.md)
            mkdir -p "$AGENTS_DIR/$(dirname "$relative")"
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
    log_info "Sincronizando .agents/ → .claude/ (root)"
    SYNCED=0

    # Workflows y agents
    for f in "$AGENTS_DIR"/workflows/*.md; do
        [ -f "$f" ] && sync_file_to_claude "$f"
    done

    # Skills (estructura idéntica — copia directa)
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

    # Scripts
    if [ -d "$AGENTS_DIR/scripts" ]; then
        for f in "$AGENTS_DIR"/scripts/scp-*; do
            [ -f "$f" ] && sync_file_to_claude "$f"
        done
    fi

    # Hooks
    if [ -d "$AGENTS_DIR/hooks" ]; then
        for f in "$AGENTS_DIR"/hooks/hok-*.md; do
            [ -f "$f" ] && sync_file_to_claude "$f"
        done
    fi

    # Layers (.agents/layers/{layer-id}/ → .claude/layers/{layer-id}/)
    if [ -d "$AGENTS_DIR/layers" ]; then
        for layer_dir in "$AGENTS_DIR"/layers/*/; do
            [ -d "$layer_dir" ] || continue
            local layer_id
            layer_id=$(basename "$layer_dir")
            [[ "$layer_id" == _* ]] && continue  # skip _user/, _disabled/, etc.
            sync_layer_to_claude "$layer_id"
        done
    fi

    log_ok "Sincronización completada: $SYNCED archivos"

    if [ "${PRUNE:-false}" = "true" ]; then
        prune_claude_orphans
    fi

    # Regenerar CLAUDE.md desde template + secciones de capas activas
    if [ -f "$PROJECT_ROOT/scripts/build-context-roots.py" ]; then
        log_info "Regenerando context roots (CLAUDE.md, AGENTS.md)..."
        python3 "$PROJECT_ROOT/scripts/build-context-roots.py" --quiet 2>&1 | sed 's/^/  /' || log_warn "build-context-roots.py falló (continuando)"
    fi
}

# Sincroniza una capa entera: .agents/layers/{layer_id}/ → .claude/layers/{layer_id}/
# Slash commands de la capa también se copian a .claude/commands/ (raíz) para discoverability.
sync_layer_to_claude() {
    local layer_id="$1"
    local layer_src="$AGENTS_DIR/layers/$layer_id"
    log_info "  layer: $layer_id"

    # workflows → commands/agents (bajo .claude/layers/{layer_id}/)
    if [ -d "$layer_src/workflows" ]; then
        for f in "$layer_src"/workflows/*.md; do
            [ -f "$f" ] && sync_layer_file_to_claude "$layer_id" "$f"
        done
    fi

    # skills (estructura idéntica)
    if [ -d "$layer_src/skills" ]; then
        for skill_dir in "$layer_src"/skills/ski-*/; do
            [ -f "${skill_dir}SKILL.md" ] && sync_layer_file_to_claude "$layer_id" "${skill_dir}SKILL.md"
        done
    fi

    # rules / knowledge-base / resources — recursive (handles e.g. resources/output-templates/tpl-*.md)
    for sub in rules knowledge-base resources; do
        if [ -d "$layer_src/$sub" ]; then
            while IFS= read -r f; do
                [ -f "$f" ] && sync_layer_file_to_claude "$layer_id" "$f"
            done < <(find "$layer_src/$sub" -type f \( -name "*.md" -o -name "*.csv" -o -name "*.json" \) 2>/dev/null)
        fi
    done

    # scripts
    if [ -d "$layer_src/scripts" ]; then
        for f in "$layer_src"/scripts/*; do
            [ -f "$f" ] && sync_layer_file_to_claude "$layer_id" "$f"
        done
    fi

    # hooks
    if [ -d "$layer_src/hooks" ]; then
        for f in "$layer_src"/hooks/hok-*.md; do
            [ -f "$f" ] && sync_layer_file_to_claude "$layer_id" "$f"
        done
    fi

    # commands de capa (slash commands) — sync_layer_file_to_claude maneja la
    # duplicación a .claude/commands/ raíz vía also_root.
    if [ -d "$layer_src/commands" ]; then
        for f in "$layer_src"/commands/*.md; do
            [ -f "$f" ] && sync_layer_file_to_claude "$layer_id" "$f"
        done
    fi

    # MANIFEST.yaml también se replica
    if [ -f "$layer_src/MANIFEST.yaml" ]; then
        mkdir -p "$CLAUDE_DIR/layers/$layer_id"
        cp "$layer_src/MANIFEST.yaml" "$CLAUDE_DIR/layers/$layer_id/MANIFEST.yaml"
        SYNCED=$((SYNCED + 1))
    fi
}

# Sincroniza un archivo individual de capa con el mismo mapeo lógico que el root.
# Para entidades discoverable por Claude Code (workflows, skills, commands), también
# crea un alias en .claude/ raíz, porque CC solo descubre las rutas canónicas
# (.claude/commands/, .claude/agents/, .claude/skills/), no .claude/layers/{X}/.
# El espejo en .claude/layers/{X}/ se mantiene como referencia estructural.
sync_layer_file_to_claude() {
    local layer_id="$1"
    local src="$2"
    local layer_src="$AGENTS_DIR/layers/$layer_id"
    local relative="${src#$layer_src/}"
    local layer_claude_dir="$CLAUDE_DIR/layers/$layer_id"
    local dest=""
    local also_root=""    # ruta relativa bajo .claude/ donde duplicar para discovery
    local needs_transform=false

    case "$relative" in
        workflows/wor-*.md|workflows/com-*.md)
            mkdir -p "$layer_claude_dir/commands"
            dest="$layer_claude_dir/commands/$(basename "$src")"
            also_root="commands/$(basename "$src")"
            needs_transform=true
            ;;
        workflows/age-*.md)
            mkdir -p "$layer_claude_dir/agents"
            dest="$layer_claude_dir/agents/$(basename "$src")"
            also_root="agents/$(basename "$src")"
            needs_transform=true
            ;;
        skills/ski-*/SKILL.md)
            local skill_dir
            skill_dir=$(echo "$relative" | sed 's|skills/\(ski-[^/]*\)/SKILL.md|\1|')
            mkdir -p "$layer_claude_dir/skills/${skill_dir}"
            dest="$layer_claude_dir/skills/${skill_dir}/SKILL.md"
            also_root="skills/${skill_dir}/SKILL.md"
            ;;
        commands/*.md)
            mkdir -p "$layer_claude_dir/commands"
            dest="$layer_claude_dir/commands/$(basename "$src")"
            also_root="commands/$(basename "$src")"
            ;;
        rules/*|knowledge-base/*|resources/*)
            # Permissive: handles flat (resources/foo.md) and nested (resources/output-templates/tpl-*.md).
            # Also accepts non-md files like .csv (methods-registry) and .json (mcp).
            mkdir -p "$layer_claude_dir/$(dirname "$relative")"
            dest="$layer_claude_dir/$relative"
            # No alias root: rules/kb/resources se referencian por path explícito
            ;;
        scripts/*|hooks/hok-*.md)
            mkdir -p "$layer_claude_dir/$(dirname "$relative")"
            dest="$layer_claude_dir/$relative"
            # No alias root: hooks se cablean explícitamente por settings.json
            ;;
        *)
            log_warn "    archivo no mapeado en capa $layer_id: $relative"
            return 0
            ;;
    esac

    cp "$src" "$dest"
    if [ "$needs_transform" = true ]; then
        transform_agents_to_claude "$dest"
    fi
    SYNCED=$((SYNCED + 1))
    log_ok "    layer:$layer_id $relative → ${dest#$PROJECT_ROOT/}"

    # Discovery alias en .claude/ raíz para entidades descubribles.
    if [ -n "$also_root" ]; then
        local alias_dest="$CLAUDE_DIR/$also_root"
        mkdir -p "$(dirname "$alias_dest")"
        cp "$src" "$alias_dest"
        if [ "$needs_transform" = true ]; then
            # Pass layer_id so layer-internal refs (../rules/X) get rewritten to
            # ../layers/$layer_id/rules/X — required because the alias lives at a
            # different relative depth than its source.
            transform_agents_to_claude "$alias_dest" "$layer_id"
        fi
        SYNCED=$((SYNCED + 1))
        log_ok "    layer:$layer_id $(basename "$src") → ${alias_dest#$PROJECT_ROOT/} (discovery alias)"
    fi
}

# Borra archivos en .claude/ (raíz y layers/) que no tienen contraparte en .agents/.
# Útil tras un refactor que mueve entidades entre raíz y layers.
prune_claude_orphans() {
    log_info "Prune: buscando archivos huérfanos en .claude/..."
    local pruned=0

    # .claude/commands/ ↔ .agents/workflows/ + .agents/layers/{X}/{workflows,commands}/
    if [ -d "$CLAUDE_DIR/commands" ]; then
        for f in "$CLAUDE_DIR"/commands/*.md; do
            [ -f "$f" ] || continue
            local name
            name=$(basename "$f")
            # Buscar en raíz
            if [ -f "$AGENTS_DIR/workflows/$name" ]; then continue; fi
            # Buscar en layers
            local found=false
            for layer_dir in "$AGENTS_DIR"/layers/*/; do
                [ -d "$layer_dir" ] || continue
                if [ -f "${layer_dir}workflows/$name" ] || [ -f "${layer_dir}commands/$name" ]; then
                    found=true; break
                fi
            done
            if ! $found; then
                rm "$f"
                pruned=$((pruned + 1))
                log_ok "  pruned: .claude/commands/$name"
            fi
        done
    fi

    # .claude/agents/ ↔ .agents/workflows/age-* + .agents/layers/{X}/workflows/age-*
    if [ -d "$CLAUDE_DIR/agents" ]; then
        for f in "$CLAUDE_DIR"/agents/*.md; do
            [ -f "$f" ] || continue
            local name
            name=$(basename "$f")
            if [ -f "$AGENTS_DIR/workflows/$name" ]; then continue; fi
            local found=false
            for layer_dir in "$AGENTS_DIR"/layers/*/; do
                [ -d "$layer_dir" ] || continue
                if [ -f "${layer_dir}workflows/$name" ]; then found=true; break; fi
            done
            if ! $found; then
                rm "$f"
                pruned=$((pruned + 1))
                log_ok "  pruned: .claude/agents/$name"
            fi
        done
    fi

    # .claude/skills/ski-*/SKILL.md
    if [ -d "$CLAUDE_DIR/skills" ]; then
        for skill_dir in "$CLAUDE_DIR"/skills/ski-*/; do
            [ -d "$skill_dir" ] || continue
            local skill_name
            skill_name=$(basename "$skill_dir")
            if [ -f "$AGENTS_DIR/skills/$skill_name/SKILL.md" ]; then continue; fi
            local found=false
            for layer_dir in "$AGENTS_DIR"/layers/*/; do
                [ -d "$layer_dir" ] || continue
                if [ -f "${layer_dir}skills/$skill_name/SKILL.md" ]; then found=true; break; fi
            done
            if ! $found; then
                rm -rf "$skill_dir"
                pruned=$((pruned + 1))
                log_ok "  pruned: .claude/skills/$skill_name/"
            fi
        done
    fi

    # .claude/{rules,knowledge-base,resources}/ ↔ misma carpeta en .agents/ (raíz o layers)
    for sub in rules knowledge-base resources; do
        [ -d "$CLAUDE_DIR/$sub" ] || continue
        for f in "$CLAUDE_DIR"/"$sub"/*.md; do
            [ -f "$f" ] || continue
            local name
            name=$(basename "$f")
            if [ -f "$AGENTS_DIR/$sub/$name" ]; then continue; fi
            local found=false
            for layer_dir in "$AGENTS_DIR"/layers/*/; do
                [ -d "$layer_dir" ] || continue
                if [ -f "${layer_dir}${sub}/$name" ]; then found=true; break; fi
            done
            if ! $found; then
                rm "$f"
                pruned=$((pruned + 1))
                log_ok "  pruned: .claude/$sub/$name"
            fi
        done
    done

    # .claude/hooks/ ↔ .agents/hooks/ + .agents/layers/{X}/hooks/
    if [ -d "$CLAUDE_DIR/hooks" ]; then
        for f in "$CLAUDE_DIR"/hooks/hok-*.md; do
            [ -f "$f" ] || continue
            local name
            name=$(basename "$f")
            if [ -f "$AGENTS_DIR/hooks/$name" ]; then continue; fi
            local found=false
            for layer_dir in "$AGENTS_DIR"/layers/*/; do
                [ -d "$layer_dir" ] || continue
                if [ -f "${layer_dir}hooks/$name" ]; then found=true; break; fi
            done
            if ! $found; then
                rm "$f"
                pruned=$((pruned + 1))
                log_ok "  pruned: .claude/hooks/$name"
            fi
        done
    fi

    # .claude/layers/ ↔ .agents/layers/  (capa entera puede haber sido borrada)
    if [ -d "$CLAUDE_DIR/layers" ]; then
        for layer_dir in "$CLAUDE_DIR"/layers/*/; do
            [ -d "$layer_dir" ] || continue
            local layer_id
            layer_id=$(basename "$layer_dir")
            if [ ! -d "$AGENTS_DIR/layers/$layer_id" ]; then
                rm -rf "$layer_dir"
                pruned=$((pruned + 1))
                log_ok "  pruned: .claude/layers/$layer_id/ (capa ya no existe)"
            else
                # La capa existe; inspeccionar archivos individuales dentro de los espejos
                prune_layer_orphans "$layer_id" false
            fi
        done
    fi

    # Borrar subdirectorios vacíos en .claude/layers/{X}/ que quedaron tras el prune
    if [ -d "$CLAUDE_DIR/layers" ]; then
        find "$CLAUDE_DIR/layers" -mindepth 2 -type d -empty -delete 2>/dev/null || true
    fi

    log_info "Prune: $pruned archivo(s) o directorio(s) eliminados"
}

# Inspecciona los espejos en .claude/layers/{X}/{sub}/ archivo por archivo y borra
# (o reporta, si dry_run=true) los que no tienen contraparte en .agents/layers/{X}/.
# Cubre el caso "capa existe pero un workflow/skill/etc dentro fue renombrado o borrado".
# Args: $1 = layer_id, $2 = dry_run (true|false). Cuando dry_run=true, solo log_warn,
# y cuenta en la variable global `orphans` en vez de `pruned`.
prune_layer_orphans() {
    local layer_id="$1"
    local dry_run="${2:-false}"
    local layer_claude="$CLAUDE_DIR/layers/$layer_id"
    local layer_agents="$AGENTS_DIR/layers/$layer_id"
    [ -d "$layer_claude" ] || return 0
    [ -d "$layer_agents" ] || return 0

    # Helper: report or remove a single orphan file
    _orphan_action() {
        local target="$1"
        local rel="${target#$CLAUDE_DIR/}"
        if [ "$dry_run" = "true" ]; then
            log_warn "  huérfano: $rel (sin contraparte en .agents/layers/$layer_id/)"
            orphans=$((orphans + 1))
        else
            rm -rf "$target"
            log_ok "  pruned: $rel"
            pruned=$((pruned + 1))
        fi
    }

    # agents/age-*.md  ←  workflows/age-*.md (mismo basename)
    if [ -d "$layer_claude/agents" ]; then
        for f in "$layer_claude"/agents/*.md; do
            [ -f "$f" ] || continue
            local name; name=$(basename "$f")
            if [ ! -f "$layer_agents/workflows/$name" ]; then
                _orphan_action "$f"
            fi
        done
    fi

    # commands/*.md  ←  workflows/{name} ó commands/{name}
    if [ -d "$layer_claude/commands" ]; then
        for f in "$layer_claude"/commands/*.md; do
            [ -f "$f" ] || continue
            local name; name=$(basename "$f")
            if [ ! -f "$layer_agents/workflows/$name" ] && [ ! -f "$layer_agents/commands/$name" ]; then
                _orphan_action "$f"
            fi
        done
    fi

    # skills/ski-*/SKILL.md  ←  skills/ski-*/SKILL.md
    if [ -d "$layer_claude/skills" ]; then
        for skill_dir in "$layer_claude"/skills/ski-*/; do
            [ -d "$skill_dir" ] || continue
            local skill_name; skill_name=$(basename "$skill_dir")
            if [ ! -f "$layer_agents/skills/$skill_name/SKILL.md" ]; then
                _orphan_action "$skill_dir"
            fi
        done
    fi

    # rules / knowledge-base — flat
    for sub in rules knowledge-base; do
        [ -d "$layer_claude/$sub" ] || continue
        for f in "$layer_claude"/"$sub"/*.md; do
            [ -f "$f" ] || continue
            local name; name=$(basename "$f")
            if [ ! -f "$layer_agents/$sub/$name" ]; then
                _orphan_action "$f"
            fi
        done
    done

    # resources / scripts / hooks — recursive (handles tpl-*, .csv, .json, scp-, hok-)
    for sub in resources scripts hooks; do
        [ -d "$layer_claude/$sub" ] || continue
        while IFS= read -r f; do
            [ -f "$f" ] || continue
            local rel="${f#$layer_claude/}"
            if [ ! -f "$layer_agents/$rel" ]; then
                _orphan_action "$f"
            fi
        done < <(find "$layer_claude/$sub" -type f 2>/dev/null)
    done

    # MANIFEST.yaml (siempre debe existir si la capa existe en .agents)
    if [ -f "$layer_claude/MANIFEST.yaml" ] && [ ! -f "$layer_agents/MANIFEST.yaml" ]; then
        _orphan_action "$layer_claude/MANIFEST.yaml"
    fi
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

    # Skills (estructura idéntica — copia directa)
    for skill_dir in "$CLAUDE_DIR"/skills/ski-*/; do
        [ -f "${skill_dir}SKILL.md" ] && sync_file_to_agents "${skill_dir}SKILL.md"
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

    # Scripts
    if [ -d "$CLAUDE_DIR/scripts" ]; then
        for f in "$CLAUDE_DIR"/scripts/scp-*; do
            [ -f "$f" ] && sync_file_to_agents "$f"
        done
    fi

    # Hooks
    if [ -d "$CLAUDE_DIR/hooks" ]; then
        for f in "$CLAUDE_DIR"/hooks/hok-*.md; do
            [ -f "$f" ] && sync_file_to_agents "$f"
        done
    fi

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

    # Conteos top-level (raíz, sin layers)
    local agents_root_count claude_root_count
    agents_root_count=$(find "$AGENTS_DIR" -maxdepth 2 -name "*.md" -type f -not -path "*/layers/*" 2>/dev/null | wc -l | tr -d ' ')
    claude_root_count=$(find "$CLAUDE_DIR" -maxdepth 2 -name "*.md" -type f -not -path "*/layers/*" -not -path "*/plans/*" 2>/dev/null | wc -l | tr -d ' ')
    log_info ".agents/ raíz (md sin layers): $agents_root_count"
    log_info ".claude/ raíz (md sin layers/plans): $claude_root_count"

    # Conteos por capa
    if [ -d "$AGENTS_DIR/layers" ]; then
        for layer_dir in "$AGENTS_DIR"/layers/*/; do
            [ -d "$layer_dir" ] || continue
            local layer_id agents_layer_count claude_layer_count
            layer_id=$(basename "$layer_dir")
            agents_layer_count=$(find "$layer_dir" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
            claude_layer_count=$(find "$CLAUDE_DIR/layers/$layer_id" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
            log_info "  layer:$layer_id  .agents=$agents_layer_count  .claude=$claude_layer_count"
            if [ "$agents_layer_count" -ne "$claude_layer_count" ]; then
                log_error "  layer:$layer_id desincronizado: .agents=$agents_layer_count .claude=$claude_layer_count (run: --agents-to-claude --prune)"
                errors=$((errors + 1))
            fi
        done
    fi

    # Verificar que no queden patrones sin transformar en .claude/commands/ raíz
    if find "$CLAUDE_DIR/commands" -maxdepth 1 -name "*.md" -type f 2>/dev/null | xargs grep -lE '(\./age-spe-|\./age-sup-)' 2>/dev/null | grep -q .; then
        log_error "Encontradas referencias ./age-spe- o ./age-sup- sin transformar en .claude/commands/"
        errors=$((errors + 1))
    fi

    # Verificar que skills en .claude/ usan estructura subdirectorio (no archivos planos)
    if find "$CLAUDE_DIR/skills" -maxdepth 1 -name "*.md" -type f 2>/dev/null | grep -q .; then
        log_error "Encontrados archivos .md planos en .claude/skills/ (deben ser ski-*/SKILL.md)"
        errors=$((errors + 1))
    fi

    # Verificar que no queden patrones sin transformar en .agents/workflows raíz
    if find "$AGENTS_DIR/workflows" -maxdepth 1 -name "*.md" -type f 2>/dev/null | xargs grep -lE '\.\./agents/age-(spe|sup)-' 2>/dev/null | grep -q .; then
        log_error "Encontradas referencias ../agents/age-spe- sin transformar en .agents/workflows/"
        errors=$((errors + 1))
    fi

    # Verificar contenido idéntico en rules/kb/resources del root
    for dir in rules knowledge-base resources; do
        [ -d "$AGENTS_DIR/$dir" ] || continue
        for f in "$AGENTS_DIR/$dir"/*.md; do
            [ -f "$f" ] || continue
            local basename_f claude_f
            basename_f=$(basename "$f")
            claude_f="$CLAUDE_DIR/$dir/$basename_f"
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

    # Verificar archivos huérfanos en .claude/ (sin contraparte en .agents/ raíz ni layers)
    local orphans=0
    for sub in commands agents skills rules knowledge-base resources hooks; do
        [ -d "$CLAUDE_DIR/$sub" ] || continue
        if [ "$sub" = "skills" ]; then
            for skill_dir in "$CLAUDE_DIR"/skills/ski-*/; do
                [ -d "$skill_dir" ] || continue
                local skill_name
                skill_name=$(basename "$skill_dir")
                if [ ! -f "$AGENTS_DIR/skills/$skill_name/SKILL.md" ]; then
                    local found=false
                    for layer_dir in "$AGENTS_DIR"/layers/*/; do
                        [ -f "${layer_dir}skills/$skill_name/SKILL.md" ] && found=true && break
                    done
                    if ! $found; then
                        log_warn "Huérfano en .claude/: skills/$skill_name (sin contraparte en .agents/)"
                        orphans=$((orphans + 1))
                    fi
                fi
            done
        else
            for f in "$CLAUDE_DIR"/"$sub"/*.md; do
                [ -f "$f" ] || continue
                local name
                name=$(basename "$f")
                local search_paths=()
                case "$sub" in
                    commands) search_paths=("$AGENTS_DIR/workflows/$name") ;;
                    agents)   search_paths=("$AGENTS_DIR/workflows/$name") ;;
                    *)        search_paths=("$AGENTS_DIR/$sub/$name") ;;
                esac
                local found=false
                for p in "${search_paths[@]}"; do [ -f "$p" ] && found=true && break; done
                if ! $found; then
                    for layer_dir in "$AGENTS_DIR"/layers/*/; do
                        [ -d "$layer_dir" ] || continue
                        case "$sub" in
                            commands|agents)
                                if [ -f "${layer_dir}workflows/$name" ] || [ -f "${layer_dir}commands/$name" ]; then
                                    found=true; break
                                fi
                                ;;
                            *)
                                [ -f "${layer_dir}${sub}/$name" ] && found=true && break
                                ;;
                        esac
                    done
                fi
                if ! $found; then
                    log_warn "Huérfano en .claude/: $sub/$name (sin contraparte en .agents/)"
                    orphans=$((orphans + 1))
                fi
            done
        fi
    done
    # Verificar archivos huérfanos DENTRO de cada .claude/layers/{X}/{sub}/
    # (caso: capa existe pero un workflow/skill renombrado dejó un huérfano dentro)
    if [ -d "$CLAUDE_DIR/layers" ]; then
        for layer_dir in "$CLAUDE_DIR"/layers/*/; do
            [ -d "$layer_dir" ] || continue
            local layer_id
            layer_id=$(basename "$layer_dir")
            [ -d "$AGENTS_DIR/layers/$layer_id" ] || continue  # ya cubierto arriba
            prune_layer_orphans "$layer_id" true   # dry_run=true → solo reporta
        done
    fi

    if [ "$orphans" -gt 0 ]; then
        log_warn "Hay $orphans huérfano(s). Ejecuta --agents-to-claude --prune para limpiar."
        errors=$((errors + 1))
    fi

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

# Parse global flags (--prune, --target=<dir>) before dispatching
PRUNE=false
ACTION=""
ACTION_ARG=""
while [ $# -gt 0 ]; do
    case "$1" in
        --prune) PRUNE=true; shift ;;
        --target=*) TARGET_ARG="${1#--target=}"; shift ;;
        --target) TARGET_ARG="${2:-}"; shift 2 || true ;;
        --auto|--agents-to-claude|--claude-to-agents|--validate|-h|--help)
            ACTION="$1"; shift
            ;;
        --file)
            ACTION="$1"; ACTION_ARG="${2:-}"; shift 2 || true
            ;;
        *)
            log_error "Opción desconocida: $1"
            usage
            ;;
    esac
done
export PRUNE

# Resolve PROJECT_ROOT after parsing --target. If --target points at an export,
# rebase all paths to that subsystem. Otherwise stay at the parent.
if [ -n "$TARGET_ARG" ]; then
    if [ ! -d "$TARGET_ARG" ]; then
        # Try interpreting it relative to the parent
        if [ -d "$PROJECT_ROOT_DEFAULT/$TARGET_ARG" ]; then
            TARGET_ARG="$PROJECT_ROOT_DEFAULT/$TARGET_ARG"
        else
            log_error "Target directory does not exist: $TARGET_ARG"
            exit 1
        fi
    fi
    PROJECT_ROOT="$(cd "$TARGET_ARG" && pwd)"
    AGENTS_DIR="$PROJECT_ROOT/.agents"
    CLAUDE_DIR="$PROJECT_ROOT/.claude"
    log_info "Operating on subsystem: ${PROJECT_ROOT#$PROJECT_ROOT_DEFAULT/}"
fi

cd "$PROJECT_ROOT"

# (v3) If we're operating on a subsystem (--target), respect the subsystem's
# 'platforms' list. Skip .claude/ generation if 'claude-code' is not active.
# At the root (no --target), this is a no-op (the root manifest always has
# claude-code in platforms).
if [ -n "$TARGET_ARG" ] && [ "${ACTION:-}" != "--validate" ] && [ "${ACTION:-}" != "--help" ] && [ "${ACTION:-}" != "-h" ]; then
    if ! check_platform_active "claude-code"; then
        exit 0
    fi
fi

case "${ACTION:---help}" in
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
        if [ -z "$ACTION_ARG" ]; then
            log_error "Se requiere la ruta del archivo: --file <path>"
            exit 1
        fi
        sync_single_file "$ACTION_ARG"
        ;;
    -h|--help)
        usage
        ;;
    *)
        log_error "Opción desconocida: $ACTION"
        usage
        ;;
esac
