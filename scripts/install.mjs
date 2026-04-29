#!/usr/bin/env node
/**
 * AiAgentArchitect Lite — Interactive installation wizard.
 *
 * Discovers available layers from `.agents/layers/{layer-id}/MANIFEST.yaml`,
 * detects platforms present on the host (Claude Code, Codex), prompts the
 * user for choices, and writes:
 *
 *   - config/manifest.yaml         (layer + platform state, 0644)
 *   - config/config.user.toml      (runtime overrides, 0600)
 *
 * Designed to be invoked either directly:
 *   node scripts/install.mjs [flags]
 *
 * Or via npx:
 *   npx aiagent-architect install [flags]
 *
 * Or via the bash bootstrap (which forwards flags here):
 *   bash install.sh [flags]
 *
 * Flags:
 *   --yes                 Accept all defaults; no prompts.
 *   --layers=a,b,c        Override root-layer selection (skips that prompt).
 *   --platforms=a,b       Override platform selection (skips that prompt).
 *   --lang=es|en          Override language (skips that prompt).
 *   --no-deps             (Forwarded from install.sh; ignored here.)
 *   install               Optional positional command (for `npx ... install`).
 *   --help, -h            Show this message and exit.
 */

import { existsSync, readdirSync, readFileSync, writeFileSync, mkdirSync, chmodSync } from 'node:fs';
import { join, dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { homedir } from 'node:os';
import { execFileSync } from 'node:child_process';

import yaml from 'js-yaml';
import TOML from '@iarna/toml';
import { select, checkbox, confirm } from '@inquirer/prompts';

const __filename = fileURLToPath(import.meta.url);
const SCRIPT_DIR = dirname(__filename);
const PROJECT_ROOT = resolve(SCRIPT_DIR, '..');

// ---------------------------------------------------------------------------
// Color helpers (ANSI; gracefully degrade if not a TTY)
// ---------------------------------------------------------------------------
const useColor = process.stdout.isTTY && process.env.NO_COLOR !== '1';
const c = (code, s) => (useColor ? `\x1b[${code}m${s}\x1b[0m` : s);
const bold = (s) => c('1', s);
const dim = (s) => c('2', s);
const red = (s) => c('31', s);
const green = (s) => c('32', s);
const yellow = (s) => c('33', s);
const blue = (s) => c('34', s);

const log = {
    info:  (s) => console.log(`${blue('i')}  ${s}`),
    ok:    (s) => console.log(`${green('+')}  ${s}`),
    warn:  (s) => console.error(`${yellow('!')}  ${s}`),
    err:   (s) => console.error(`${red('x')}  ${s}`),
    title: (s) => console.log(`\n${bold(`== ${s} ==`)}`),
};

// ---------------------------------------------------------------------------
// CLI argument parsing
// ---------------------------------------------------------------------------
function parseArgs(argv) {
    const opts = {
        yes: false,
        layers: null,
        platforms: null,
        lang: null,
        help: false,
    };
    for (const arg of argv) {
        if (arg === '--yes' || arg === '-y') opts.yes = true;
        else if (arg === '--help' || arg === '-h') opts.help = true;
        else if (arg === '--no-deps' || arg === 'install') { /* ignore */ }
        else if (arg.startsWith('--layers=')) opts.layers = arg.slice('--layers='.length).split(',').map(s => s.trim()).filter(Boolean);
        else if (arg.startsWith('--platforms=')) opts.platforms = arg.slice('--platforms='.length).split(',').map(s => s.trim()).filter(Boolean);
        else if (arg.startsWith('--lang=')) opts.lang = arg.slice('--lang='.length).trim();
        else log.warn(`Unknown argument ignored: ${arg}`);
    }
    return opts;
}

function showHelp() {
    console.log(`AiAgentArchitect Lite — Interactive installation wizard

Usage:
  node scripts/install.mjs [OPTIONS]
  npx aiagent-architect install [OPTIONS]
  bash install.sh [OPTIONS]      (bootstraps deps, then runs this wizard)

Options:
  --yes, -y             Accept all defaults; no prompts.
  --layers=a,b,c        Override root-layer selection (skips that prompt).
  --platforms=a,b       Override platform selection (skips that prompt).
                        Valid: antigravity, claude-code, codex
  --lang=es|en          Override output language (skips that prompt).
  --help, -h            Show this message.

Examples:
  node scripts/install.mjs --yes
  node scripts/install.mjs --layers=qa,memory --platforms=claude-code --lang=es
`);
}

// ---------------------------------------------------------------------------
// Discovery: layers, platforms, language
// ---------------------------------------------------------------------------
function discoverLayers() {
    const layersDir = join(PROJECT_ROOT, '.agents', 'layers');
    if (!existsSync(layersDir)) return [];
    return readdirSync(layersDir, { withFileTypes: true })
        .filter(d => d.isDirectory() && !d.name.startsWith('_'))
        .map(d => {
            const manifestPath = join(layersDir, d.name, 'MANIFEST.yaml');
            if (!existsSync(manifestPath)) return null;
            try {
                const raw = readFileSync(manifestPath, 'utf8');
                // MANIFEST may have leading frontmatter delimiters (---) followed by
                // a markdown body; we only care about the YAML head.
                const yamlBlock = raw.startsWith('---')
                    ? raw.split(/^---\s*$/m)[1] ?? raw
                    : raw;
                const m = yaml.load(yamlBlock);
                if (!m || !m.layer_id) return null;
                return {
                    id: m.layer_id,
                    version: m.version || '0.0.0',
                    description: (m.description || '').trim(),
                    scopes: m.scopes || ['root'],
                    defaultRoot: m.default_enabled_root !== false,
                    defaultSubsystem: m.default_enabled_subsystem !== false,
                };
            } catch (e) {
                log.warn(`Failed to parse ${manifestPath}: ${e.message}`);
                return null;
            }
        })
        .filter(Boolean);
}

function detectPlatforms() {
    const detected = { antigravity: true /* always present in repo */, 'claude-code': false, codex: false };
    if (existsSync(join(homedir(), '.claude'))) detected['claude-code'] = true;
    if (existsSync(join(homedir(), '.codex'))) detected.codex = true;
    return detected;
}

function detectLanguage() {
    const lang = (process.env.LANG || process.env.LC_ALL || process.env.LC_MESSAGES || '').toLowerCase();
    return lang.startsWith('es') ? 'es' : 'en';
}

function detectCommitSha() {
    // execFileSync is safer than execSync: no shell, args are passed as an array.
    // Arguments here are hardcoded (no user input), but this is best practice.
    try {
        return execFileSync('git', ['rev-parse', 'HEAD'], {
            cwd: PROJECT_ROOT,
            stdio: ['ignore', 'pipe', 'ignore'],
        }).toString().trim();
    } catch {
        return 'unknown';
    }
}

// ---------------------------------------------------------------------------
// Wizard prompts (skipped if --yes or specific flag overrides)
// ---------------------------------------------------------------------------
async function chooseUsageMode(opts) {
    if (opts.yes) return 'use';
    return select({
        message: 'How will you use AiAgentArchitect?',
        choices: [
            { name: 'Use it to generate systems', value: 'use' },
            { name: 'Contribute to AiAgentArchitect itself', value: 'contribute' },
            { name: 'Both', value: 'both' },
        ],
        default: 'use',
    });
}

async function choosePlatforms(opts, detected) {
    if (opts.platforms) return opts.platforms;
    if (opts.yes) return Object.keys(detected).filter(k => detected[k]);
    const allPlatforms = ['antigravity', 'claude-code', 'codex'];
    const choices = allPlatforms.map(p => ({
        name: detected[p] ? `${p} ${dim('(detected)')}` : p,
        value: p,
        checked: detected[p],
    }));
    const picked = await checkbox({
        message: 'Which platforms do you want to activate?',
        choices,
        required: true,
    });
    return picked;
}

// Build a checkbox choice line that surfaces the layer's status (stable vs skeleton),
// version and a one-line description. Truncation lets us show meaningful info without
// blowing the terminal width.
function layerChoiceLine(l) {
    const isSkeleton = String(l.version).includes('skeleton');
    const status = isSkeleton ? yellow('[skeleton]') : green('[stable]');
    const summary = (l.description || '').slice(0, 90);
    return `${l.id} ${status} ${dim(`v${l.version} — ${summary}`)}`;
}

async function chooseRootLayers(opts, layers) {
    if (opts.layers) {
        const valid = new Set(layers.map(l => l.id));
        return opts.layers.filter(id => valid.has(id));
    }
    if (opts.yes) return layers.filter(l => l.defaultRoot && l.scopes.includes('root')).map(l => l.id);
    const eligible = layers.filter(l => l.scopes.includes('root'));
    const stableCount = eligible.filter(l => !String(l.version).includes('skeleton')).length;
    const skeletonCount = eligible.length - stableCount;
    log.info(`Root layers available (${eligible.length} total: ${stableCount} stable + ${skeletonCount} skeleton).`);
    log.info(`Defaults pre-checked. You can toggle individually. Re-run install.sh any time to change selection.`);
    const choices = eligible.map(l => ({
        name: layerChoiceLine(l),
        value: l.id,
        checked: l.defaultRoot,
    }));
    return checkbox({
        message: 'Which layers to enable on AiAgentArchitect itself (root)?',
        choices,
        required: false,
        pageSize: Math.min(eligible.length + 2, 20),
    });
}

async function chooseSubsystemDefaults(opts, layers) {
    if (opts.yes) return layers.filter(l => l.defaultSubsystem && l.scopes.includes('subsystem')).map(l => l.id);
    const eligible = layers.filter(l => l.scopes.includes('subsystem'));
    const onByDefault = eligible.filter(l => l.defaultSubsystem).length;
    log.info(`Subsystem defaults: ${eligible.length} layers eligible, ${onByDefault} pre-checked.`);
    log.info(`These are baked into every new subsystem you generate.`);
    const choices = eligible.map(l => ({
        name: layerChoiceLine(l),
        value: l.id,
        checked: l.defaultSubsystem,
    }));
    return checkbox({
        message: 'Which layers should be embedded by default in subsystems you generate?',
        choices,
        required: false,
        pageSize: Math.min(eligible.length + 2, 20),
    });
}

async function chooseLanguage(opts, detected) {
    if (opts.lang) return opts.lang;
    if (opts.yes) return detected;
    return select({
        message: 'Output language for generated content',
        choices: [
            { name: 'English (en)', value: 'en' },
            { name: 'Spanish (es)', value: 'es' },
        ],
        default: detected,
    });
}

// ---------------------------------------------------------------------------
// Output writers
// ---------------------------------------------------------------------------
function writeManifest({ platforms, rootLayers, subsystemDefaults, layersIndex }) {
    const now = new Date().toISOString();
    const sha = detectCommitSha();

    const layersRoot = {};
    for (const id of rootLayers) {
        const meta = layersIndex.find(l => l.id === id);
        layersRoot[id] = {
            enabled: true,
            version: meta ? meta.version : '0.0.0',
            embedded_at: now,
        };
    }
    const layersSubsystemDefaults = {};
    for (const id of subsystemDefaults) {
        layersSubsystemDefaults[id] = { enabled: true };
    }

    const manifest = {
        aiagent_architect_version: '0.1.0-lite',
        installed_at: now,
        last_modified: now,
        commit_sha: sha,
        platforms,
        layers_root: layersRoot,
        layers_subsystem_defaults: layersSubsystemDefaults,
    };

    const configDir = join(PROJECT_ROOT, 'config');
    if (!existsSync(configDir)) mkdirSync(configDir, { recursive: true });
    const dest = join(configDir, 'manifest.yaml');
    const header = '# Generated by scripts/install.mjs. Re-run the wizard to regenerate.\n# This file is .gitignored. Re-run install.sh to change layer selection.\n\n';
    writeFileSync(dest, header + yaml.dump(manifest, { lineWidth: 100, noRefs: true }), 'utf8');
    log.ok(`Wrote ${dim(dest.replace(PROJECT_ROOT + '/', ''))}`);
    return dest;
}

function writeUserConfig({ language }) {
    const configDir = join(PROJECT_ROOT, 'config');
    if (!existsSync(configDir)) mkdirSync(configDir, { recursive: true });
    const dest = join(configDir, 'config.user.toml');

    const userCfg = {
        runtime: { language },
    };
    const header = '# Generated by scripts/install.mjs.\n# Personal overrides. .gitignored. Edit freely.\n# Precedence: config.base.toml < config.team.toml < THIS FILE < CLI flags.\n\n';
    writeFileSync(dest, header + TOML.stringify(userCfg), 'utf8');
    try {
        chmodSync(dest, 0o600);
    } catch (e) {
        log.warn(`Could not chmod 600 on ${dest}: ${e.message}`);
    }
    log.ok(`Wrote ${dim(dest.replace(PROJECT_ROOT + '/', ''))} ${dim('(0600)')}`);
    return dest;
}

// ---------------------------------------------------------------------------
// Summary
// ---------------------------------------------------------------------------
function printSummary({ usageMode, platforms, rootLayers, subsystemDefaults, language }) {
    log.title('Summary');
    console.log(`  Usage mode:           ${bold(usageMode)}`);
    console.log(`  Platforms:            ${platforms.length ? platforms.map(bold).join(', ') : dim('(none)')}`);
    console.log(`  Root layers:          ${rootLayers.length ? rootLayers.map(bold).join(', ') : dim('(none)')}`);
    console.log(`  Subsystem defaults:   ${subsystemDefaults.length ? subsystemDefaults.map(bold).join(', ') : dim('(none)')}`);
    console.log(`  Output language:      ${bold(language)}`);
}

function printNextSteps() {
    log.title('Next steps');
    console.log(`  ${dim('1.')} Review ${bold('config/manifest.yaml')} and ${bold('config/config.user.toml')}.`);
    console.log(`  ${dim('2.')} From your IDE, run ${bold('/wor-onboarding')} to start your first session.`);
    console.log(`  ${dim('3.')} Or run ${bold('/wor-agentic-architect')} to generate a new agentic system.`);
    console.log(`  ${dim('4.')} See ${bold('QUICKSTART.md')} for examples and ${bold('system-overview.md')} for entity inventory.`);
    console.log(`  ${dim('5.')} ${dim('To re-run setup:')} ${bold('node scripts/install.mjs')}`);
    console.log();
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
async function main() {
    const opts = parseArgs(process.argv.slice(2));
    if (opts.help) { showHelp(); return 0; }

    log.title('AiAgentArchitect Lite — Interactive Setup');

    const layers = discoverLayers();
    if (layers.length === 0) {
        log.err('No layers discovered in .agents/layers/. Are you running this from a valid AiAgentArchitect repo?');
        return 1;
    }
    log.info(`Discovered ${layers.length} layer(s): ${layers.map(l => l.id).join(', ')}`);

    const detectedPlatforms = detectPlatforms();
    const detectedLanguage = detectLanguage();
    const detectedActive = Object.keys(detectedPlatforms).filter(k => detectedPlatforms[k]);
    log.info(`Detected platforms on this machine: ${detectedActive.join(', ') || '(none beyond antigravity)'}`);
    log.info(`Detected locale language: ${detectedLanguage}`);

    let usageMode, platforms, rootLayers, subsystemDefaults, language;
    try {
        usageMode         = await chooseUsageMode(opts);
        platforms         = await choosePlatforms(opts, detectedPlatforms);
        rootLayers        = await chooseRootLayers(opts, layers);
        subsystemDefaults = await chooseSubsystemDefaults(opts, layers);
        language          = await chooseLanguage(opts, detectedLanguage);
    } catch (e) {
        if (e && e.name === 'ExitPromptError') {
            log.warn('Setup cancelled by user.');
            return 130;
        }
        throw e;
    }

    printSummary({ usageMode, platforms, rootLayers, subsystemDefaults, language });

    if (!opts.yes) {
        const proceed = await confirm({ message: 'Write configuration files?', default: true }).catch(() => false);
        if (!proceed) {
            log.warn('Aborted before writing files.');
            return 0;
        }
    }

    log.title('Writing configuration');
    writeManifest({ platforms, rootLayers, subsystemDefaults, layersIndex: layers });
    writeUserConfig({ language });

    // Resolve config so .resolved.toml is ready for first invocation.
    const resolver = join(PROJECT_ROOT, 'scripts', 'resolve-config.py');
    if (existsSync(resolver)) {
        try {
            execFileSync('python3', [resolver, '--quiet'], {
                cwd: PROJECT_ROOT,
                stdio: ['ignore', 'pipe', 'pipe'],
            });
            log.ok(`Wrote ${dim('config/.resolved.toml')}`);
        } catch (e) {
            log.warn(`Could not run resolve-config.py: ${e.message}. You can run it manually.`);
        }
    }

    // Build context-root files (CLAUDE.md, AGENTS.md) from active layers.
    const ctxBuilder = join(PROJECT_ROOT, 'scripts', 'build-context-roots.py');
    if (existsSync(ctxBuilder)) {
        try {
            execFileSync('python3', [ctxBuilder, '--quiet'], {
                cwd: PROJECT_ROOT,
                stdio: ['ignore', 'pipe', 'pipe'],
            });
            log.ok(`Wrote ${dim('CLAUDE.md, AGENTS.md')} from templates`);
        } catch (e) {
            log.warn(`Could not run build-context-roots.py: ${e.message}. You can run it manually.`);
        }
    }

    printNextSteps();
    return 0;
}

main().then(code => process.exit(code)).catch(err => {
    log.err(`Fatal error: ${err.stack || err.message || err}`);
    process.exit(1);
});
