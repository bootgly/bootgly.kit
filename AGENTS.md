# Bootgly Kit — AI agent guide

Operating manual for AI coding agents working in a Bootgly Kit checkout.
Everything here works without a TTY. The human quick-start lives in
`README.md`; this file is the canonical reference for the non-interactive
flags, which are intentionally left out of the user-facing docs.

## What this kit is

- A starter checkout: your application lives in `projects/`; the framework is
  pinned as the `Bootgly/` git submodule.
- Optional platform submodules: `Console/` (opinionated CLI extras) and
  `Web/` (opinionated WPI extras). They stay empty until initialized.
- Run every command from the kit root as `php bootgly ...` (drop the `php `
  prefix if the CLI was installed globally with `sudo php bootgly setup`).

## Non-interactive install

The canonical installer accepts arguments after `--`:

```sh
curl -fsSL https://bootgly.com/install | bash -s -- [DIR] [--yes] [--no-wizard]
```

| Argument | Effect |
| --- | --- |
| `DIR` | Target directory (default `bootgly.kit`) |
| `--yes` | Fully non-interactive: auto-approves dependency installs (git / PHP 8.4 / extensions via the system package manager), skips the wizard and the global-CLI offer |
| `--no-wizard` | Skips only the project wizard (dependency prompts still ask on a TTY) |

Environment overrides:

- `BOOTGLY_KIT_REPO=<url|path>` — clone the kit from another remote.
- `BOOTGLY_TTY=0` — force Bootgly commands into non-interactive mode even on a
  PTY (rarely needed: `--yes` already bypasses every prompt).

## Create and import projects (headless)

```sh
php bootgly project create <Name> [flags] --yes
```

`--yes` is what keeps `create` non-interactive on a TTY/PTY — without it the
wizard opens. Flags:

| Flag | Values | Notes |
| --- | --- | --- |
| `--from=` | `scratch` (default) \| `<source>` | `<source>` copies a shipped project, e.g. `Demo/HTTP_Server_CLI` (framework), `Snake` (Console), `Blog` (Web) |
| `--interfaces=` | `CLI` \| `WPI` | Scratch template: CLI console app or WPI web (HTTP) server. Default `CLI` |
| `--platform=` | `console` \| `web` \| `console,web` \| `none` | Platform submodules to initialize on first run. **A fresh kit without this flag initializes ALL platforms (network clones)** — pass `none` for a base-only setup |
| `--port=` | int | WPI only: HTTP port written into the project file (default `8080`; the `PORT` env overrides it at runtime) |
| `--description=`, `--version=`, `--author=` | string | Project metadata |
| `--default` | — | Register the project as the web default (WPI) |
| `--dry-run` | — | Preview without writing |

Recipes:

```sh
# Console application (base platform only)
php bootgly project create App --yes --platform=none

# Web (HTTP) server on port 8080, set as the default project
php bootgly project create App --yes --platform=none --interfaces=WPI --port=8080 --default

# Copy of a shipped example (framework sources work base-only)
php bootgly project create MyServer --yes --platform=none --from=Demo/HTTP_Server_CLI

# Copy of a Web platform project (initializes Web/ when missing)
php bootgly project create MyBlog --yes --platform=web --from=Blog

# Import from a git repository (the URL is required headless)
php bootgly project import <url> [Name] --yes
```

Gotchas:

- `--from=<platform source>` requires that platform initialized — pass
  `--platform=console|web` in the same command, or the create fails with
  "not found in the platform folders".
- Project paths: the first segment starts uppercase and must not be a reserved
  name (`Bootgly`, `Console`, `Web`, `Data`, `Graphics`, `Embedded`,
  `Mobile`). Nested paths are fine: `App/API`.
- `project import` without a URL is interactive-only; to copy a *named
  platform project* headless, use `create --from=<source>` instead.

## Operate

```sh
php bootgly project list                        # registered projects (default marked)
php bootgly project <Name> start                # boot it — WPI servers daemonize (start
                                                # returns); console apps hold the terminal:
                                                # run those under a background task
php bootgly project <Name> stop                 # stop a running server project
php bootgly project <Name> migrate up           # when the project ships database/migrations
php bootgly project <Name> seed run             # when the project ships database/seeders
AI_AGENT=1 php bootgly test                     # kit test suites, agent-formatted output
php bootgly test --bootgly|--console|--web      # framework/platform suites instead
```

## Structure

```text
Bootgly/     framework (git submodule — read-only)
Console/     Console platform (optional submodule — read-only)
Web/         Web platform (optional submodule — read-only)
projects/    your applications + Bootgly.projects.php (machine-managed registry)
tests/       your test suites (registered in tests/autoboot.php)
public/      web entry (index.php front controller)
scripts/     operational scripts
storage/     runtime data (logs, pids, cache — gitignored)
```

## Do not

- Do not edit anything inside `Bootgly/`, `Console/` or `Web/` — they are
  pinned submodules; changes belong upstream.
- Do not hand-edit `projects/Bootgly.projects.php` — the registry is rewritten
  whole by `project create/import`.
- Do not add Composer packages for framework-core concerns (HTTP server,
  autoloading, testing, config, logging): Bootgly ships them natively.

## Go deeper

- Documentation: https://docs.bootgly.com — Markdown index at
  https://docs.bootgly.com/llms.txt
- MCP server (docs search + page fetch): https://docs.bootgly.com/mcp
- Agent setup prompt (this flow, self-contained): https://bootgly.com/prompt.md
