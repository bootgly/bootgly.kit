<p align="center">
  <img src="https://github.com/bootgly/.github/raw/main/bootgly-logo.128x128.jpg" alt="bootgly-logo" width="120px" height="120px"/>
</p>
<h1 align="center">Bootgly.Kit</h1>
<p align="center">
  <i>The official Bootgly starter template</i>
</p>

One kit for both platforms: create **Console** (CLI / TUI) or **Web** projects from a single template — the project wizard sets everything up for you.

## ⚡ Get started (one command)

```bash
curl -fsSL https://bootgly.com/install | bash
```

The installer checks your environment (git + PHP 8.4+), clones this kit, initializes the Bootgly platform and opens the **project wizard** — where you pick your extra platforms (Console and/or Web), boot the resource folders and create your first project **from scratch** or by **importing** a platform project (like the Demos) or a Git remote.

Start your project right after:

```bash
cd bootgly.kit
bootgly project list
bootgly project <Name> start
```

## 🗄 Database projects

Projects that ship database resources — like the Web platform demos (Blog, Tasks, Auth) — prepare their database before the first start:

```bash
bootgly project <Name> migrate up   # create the database schema
bootgly project <Name> seed run     # seed the database
bootgly project <Name> start
```

The CLI advises these exact steps right after a project with database resources is created or imported.

## 🧪 Tests

`bootgly test` runs **your** workspace suites — register them in `tests/autoboot.php`; imported demo projects ship an example suite under `tests/` as a writing guide. The framework and platform suites run behind flags:

```bash
bootgly test              # your suites (tests/autoboot.php)
bootgly test --bootgly    # the Bootgly framework suites
bootgly test --console    # the Console platform suites
bootgly test --web        # the Web platform suites
```

## 🧩 Importing projects

Run `bootgly project import` with no arguments to choose the source interactively — the Platforms (Demos, games and Web scaffolds) or a Git remote. Any directory with a `*.project.php` file at its root is a Bootgly project; import one directly from a git repository:

```bash
php bootgly project import https://github.com/foo/project1 Project1
```

## 🗂 Structure

```text
bootgly.kit/
├── Bootgly/     ← the Bootgly platform (git submodule)
├── Console/     ← Console platform extras (optional submodule)
├── Web/         ← Web platform extras (optional submodule)
├── projects/    ← your projects (installed by `bootgly boot`)
├── tests/       ← your test suites (`bootgly test`)
├── bootgly      ← the Bootgly CLI launcher
└── index.php    ← the Web front controller
```

Install the CLI globally (optional):

```bash
sudo php bootgly setup
```

## 📚 Documentation

- [Getting started](https://docs.bootgly.com/guide/getting-started/overview/)
- [Projects manual](https://docs.bootgly.com/manual/Bootgly/essential/projects/overview/)

## License

[MIT](./LICENSE)
