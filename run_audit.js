const fs = require('fs');
const path = require('path');

const agenticPath = path.join(process.cwd(), 'agentic');

function getAllFiles(dirPath, filesArray) {
  const files = fs.readdirSync(dirPath);
  filesArray = filesArray || [];

  files.forEach(function(file) {
    if (fs.statSync(dirPath + "/" + file).isDirectory()) {
      filesArray = getAllFiles(dirPath + "/" + file, filesArray);
    } else {
      filesArray.push(path.join(dirPath, "/", file));
    }
  });

  return filesArray;
}

const allFiles = getAllFiles(agenticPath, []).filter(file => file.endsWith('.md'));

console.log(`Auditing ${allFiles.length} files...`);

const issues = [];
const improvements = [];

// Rule 1: Naming Conventions
const namingRules = {
  'agents': /^(age-spe-|age-sup-)[a-z0-z-]+.md$/,
  'skills': /^ski-[a-z0-z-]+(\/SKILL)?\.md$/,
  'rules': /^rul-[a-z0-z-]+.md$/,
  'knowledge-base': /^kno-[a-z0-z-]+.md$/,
  'workflows': /^wor-[a-z0-z-]+.md$/,
  'commands': /^com-[a-z0-z-]+.md$/
};

const requiredSections = {
  'agents': ['## Role & Mission', '## Context', '## Goals', '## Execution Protocol', '## Input', '## Output', '## Rules'],
  'skills': ['# ', '## Input / Output', '## Procedure', '## Examples', '## Error Handling'],
  'rules': ['## Context', '## Hard Constraints', '## Soft Constraints'],
  'knowledge-base': ['## Table of Contents', '## Documentation'],
  'workflows': ['## 1. System Prompt', '## 2. Process Info', '## 8. Workflow Sequence']
};

allFiles.forEach(file => {
  const relPath = path.relative(agenticPath, file);
  const type = relPath.split('/')[0];
  const filename = path.basename(file);
  const content = fs.readFileSync(file, 'utf8');

  // Check internal name (yaml frontmatter)
  const nameMatch = content.match(/^name:\s*(.+)$/m);
  if (nameMatch && (type === 'agents' || type === 'skills' || type === 'workflows')) {
    const internalName = nameMatch[1].trim();
    const expectedPrefix = type === 'agents' ? 'age-' : (type === 'skills' ? 'ski-' : 'wor-');
    if (!internalName.startsWith(expectedPrefix) && !internalName.startsWith('com-')) {
       issues.push(`[Naming] ${relPath}: Internal name '${internalName}' does not match expected prefix`);
    }
  }

  // Check required sections
  if (requiredSections[type]) {
    requiredSections[type].forEach(section => {
      if (!content.includes(section)) {
        if (section === '## Examples' && type === 'skills') {
          improvements.push(`[Completeness] ${relPath}: Missing '## Examples' section (Soft Constraint)`);
        } else if (file.includes('kno-qa-layer-template')) {
          // ignore template file structure
        } else {
          issues.push(`[Completeness] ${relPath}: Missing required section '${section}'`);
        }
      }
    });
  }

  // Check content quality
  if (content.includes('[descripcion]') || content.includes('[nombre]')) {
    issues.push(`[Quality] ${relPath}: Contains unreplaced placeholders`);
  }

  // Check if skills have SKILL.md format
  if (type === 'skills' && filename !== 'SKILL.md') {
    issues.push(`[Structure] ${relPath}: Skills should be in a folder with a SKILL.md file`);
  }
});

console.log("\n❌ ISSUES (Hard Constraints violated):");
issues.forEach(i => console.log(i));

console.log("\n⚠️ IMPROVEMENTS (Soft Constraints / Quality):");
improvements.forEach(i => console.log(i));
console.log("\nDone.");
