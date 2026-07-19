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

With git/PHP/extensions already present, both flags touch nothing system-wide
— the installer only clones into the target directory. `--yes` drives the
system package manager (often via sudo) ONLY when a dependency is missing; on
a user's machine, confirm with them before letting it do that (prefer
`--no-wizard`, which fails fast naming what is missing).

When the default `php` is older than 8.4 but a versioned binary exists
(`php8.4` on Debian/sury, `php84` on RHEL/Remi and Alpine), the installer
detects and uses it, and prints the next steps with that prefix — substitute
it for `php` in every command in this guide.

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

## Database

`migrate`/`seed` read the project connection from
`projects/<Name>/configs/database/database.config.php`. SQLite needs no server
— the shipped demos use it. Scratch projects don't have the config yet; create
it first:

```php
<?php

use Bootgly\API\Environment\Configs\Config;
use Bootgly\API\Environment\Configs\Config\Types;


return new Config(scope: 'database')
   ->Enabled->bind(key: 'DB_ENABLED', default: true, cast: Types::Boolean)
   ->Default->bind(key: 'DB_CONNECTION', default: 'sqlite')
   ->Connections
      ->SQLite
         ->Driver->bind(key: '', default: 'sqlite')
         ->Database->bind(key: 'DB_NAME', default: __DIR__ . '/../../database/app.sqlite')
         ->up()
      ->up();
```

(For MySQL, bind a `MySQL` connection with host/port/user/password keys —
see https://docs.bootgly.com/guide/database-dbal/overview.md.)

The workflow:

```sh
php bootgly project <Name> migrate create <name>   # scaffold database/migrations/<ts>_<name>.php (creates the dirs)
php bootgly project <Name> migrate status          # applied × pending × missing
php bootgly project <Name> migrate up [limit]      # apply pending migrations
php bootgly project <Name> migrate down <steps>    # revert the last <steps> migrations
php bootgly project <Name> seed create <name>      # scaffold database/seeders/<name>.php
php bootgly project <Name> seed list
php bootgly project <Name> seed run [name]         # run every seeder, or a single one
```

- Migrations are files returning `new Migration(Up:, Down:)` over the Schema
  Blueprint DSL: `$Schema->create('items', function (Blueprint $Table): void {
  $Table->add('id', Types::BigInteger)->generate()->constrain(Keys::Primary);
  })` — `Types::*`, `Keys::*`, `$Table->add(...)->limit()/->default`.
- Seeders return `new Seeder(Run: function (SQL $Database, Seed $Seed) {...})`
  — return one query, a list of queries, or null; keep the files return-only.
- Models (ORM) are plain classes mapped by attributes — `#[Table('items')]` on
  the class, `#[Key]`/`#[Column]` on properties — conventionally in
  `projects/<Name>/Models/`. Working reference shipped with the Web platform:
  `Web/projects/Tasks` (`Models/Task.php` + migration + seeder).
- `migrate sync` reconciles the migration history but asks for confirmation —
  interactive only; headless it aborts safely.
- Guides (Markdown): https://docs.bootgly.com/guide/database-dbal/overview.md,
  database-migrations, database-seeders, database-orm, database-queries,
  database-transactions, database-read-replicas (same URL pattern).

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

- Documentation: https://docs.bootgly.com — the Guide (features), the Manual
  (per component) and the Testing book. Every page is also served as Markdown:
  append `.md` to any page URL, or start from
  https://docs.bootgly.com/llms.txt (index) and
  https://docs.bootgly.com/llms-full.txt (the whole corpus in one file).
- MCP: docs.bootgly.com ships an MCP server (streamable HTTP) at
  https://docs.bootgly.com/mcp — tools `search_bootgly` and `get_page_bootgly`
  for searching and fetching docs while you build; server card at
  https://bootgly.com/.well-known/mcp/server-card.json. Claude Code:
  `claude mcp add --transport http bootgly https://docs.bootgly.com/mcp`
- Agent setup prompt (this flow, self-contained): https://bootgly.com/prompt.md
