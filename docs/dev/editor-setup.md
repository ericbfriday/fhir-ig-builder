# Editor Setup

This guide covers IDE and editor configuration for working with FHIR Shorthand (FSH) in this project.

---

## VS Code

VS Code has the best FSH support. The devcontainer auto-installs recommended extensions, but here's the full list for reference.

### Required extensions

| Extension | ID | Purpose |
|-----------|-----|---------|
| FHIR Shorthand | `kmaravilla.vscode-fhir-shorthand` | Syntax highlighting, snippets, and basic validation for `.fsh` files |
| YAML | `redhat.vscode-yaml` | Schema validation for `sushi-config.yaml` and other YAML files |
| EditorConfig | `editorconfig.editorconfig` | Enforces consistent formatting from `.editorconfig` |

These are declared in `.vscode/extensions.json` and install automatically inside the devcontainer.

### Recommended (optional)

| Extension | ID | Purpose |
|-----------|-----|---------|
| Prettier | `esbenp.prettier-vscode` | Auto-format Markdown and JSON files |
| markdownlint | `davidanson.vscode-markdownlint` | Lint documentation files |
| GitLens | `eamodio.gitlens` | Enhanced git blame and history |

### Workspace settings

The repo ships `.vscode/settings.json` with:

```json
{
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "files.eol": "\n",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true
}
```

These apply automatically when you open the project.

---

## Zed

Zed has minimal FSH support but works well for general editing.

### Available

- **YAML** — Built-in YAML support; no extension needed
- **EditorConfig** — Supported natively since Zed v0.130+

### Not available

- **FSH grammar** — No FSH Tree-sitter grammar exists for Zed yet. FSH files will have no syntax highlighting.
- **Dev Container extensions** — Zed doesn't install VS Code extensions inside containers

### Configuration

Add to your Zed settings (`~/.config/zed/settings.json`):

```json
{
  "tab_size": 2,
  "hard_tabs": false,
  "file_types": {
    "yaml": ["sushi-config.yaml"]
  }
}
```

### Dev Container usage

Zed supports local devcontainers since v0.218. Open the project folder and accept the "Open in Container" prompt. See the [Getting Started guide](getting-started.md#option-d-zed--dev-container) for limitations.

---

## Kiro IDE

Kiro IDE is a Code OSS fork. It supports the same extensions as VS Code, but the Dev Containers extension requires sideloading because it's a proprietary Microsoft extension.

### Setup

Run the provided setup script:

```bash
./scripts/setup-kiro-devcontainers.sh
```

This installs the Dev Containers extension and configures the required `enable-proposed-api` entry. See the [Getting Started guide](getting-started.md#option-a-kiro-ide--dev-container-recommended) for full details.

### Extensions

Once inside the devcontainer, Kiro IDE has the same extensions as VS Code:
- FHIR Shorthand (`kmaravilla.vscode-fhir-shorthand`)
- YAML (`redhat.vscode-yaml`)
- EditorConfig (`editorconfig.editorconfig`)

### After Kiro IDE updates

Sideloaded extensions may break when Kiro IDE updates. Re-run the setup script:

```bash
./scripts/setup-kiro-devcontainers.sh
```

---

## Kiro CLI

Kiro CLI is a terminal-based AI assistant. It doesn't need extensions — it works with the file system directly.

### No setup needed

- Works in any terminal (inside or outside the devcontainer)
- Reads `.kiro/` configuration automatically
- Has full access to FSH files, SUSHI output, and build commands

### Usage

```bash
# Inside the devcontainer or locally
kiro chat "compile the FSH and show me any errors"
kiro chat "add a Patient profile with NMDP donor identifiers"
```

---

## Pre-commit Hooks

> **Status:** Not yet configured (future work).

A future iteration will add:
- [Husky](https://typicode.github.io/husky/) for git hook management
- `pnpm sushi` as a pre-commit check (ensures FSH compiles)
- Prettier for Markdown/JSON formatting

For now, run `pnpm sushi` manually before committing to catch errors early.

---

## File Associations

If your editor doesn't recognize `.fsh` files, add this mapping:

| Editor | Configuration |
|--------|--------------|
| VS Code / Kiro IDE | `"files.associations": { "*.fsh": "fsh" }` in settings.json |
| Zed | `"file_types": { "plaintext": ["*.fsh"] }` in settings.json |
| Vim/Neovim | `au BufRead,BufNewFile *.fsh set filetype=fsh` in init.vim |

---

## Further Reading

- [Getting Started](getting-started.md) — Full setup guide for every IDE
- [Toolchain](toolchain.md) — How the build tools fit together
- [Dev Container cross-IDE research](../research/devcontainer-cross-ide-compatibility.md) — Detailed compatibility findings
