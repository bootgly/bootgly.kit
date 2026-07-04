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

The installer checks your environment (git + PHP 8.4+), clones this kit, initializes the Bootgly platform and opens the **project wizard** — where you pick your platform (Console or Web), boot the resource folders and create your first project **from scratch** or by **importing** a platform project (like the Demos).

Start your project right after:

```bash
cd bootgly.kit
bootgly project list
bootgly project <Name> start
```

## 📦 Manual setup (git submodules)

Prefer to do it by hand? Use this repository as a GitHub template (or clone it), then:

```bash
git submodule update --init Bootgly   # the Bootgly platform (required)
php bootgly project create            # the wizard initializes the rest
```

The wizard initializes the optional platform submodules (`Console/`, `Web/`) and runs `bootgly boot` to install the resource folders (`projects/`, `public/`, `scripts/`, `storage/`, `tests/`).

Non-interactive (CI / scripts):

```bash
php bootgly project create App/Web --platform=web --interfaces=WPI --yes
```

## 🧩 Importing projects

Any directory with a `*.project.php` file at its root is a Bootgly project. Import one from a git repository:

```bash
php bootgly project import https://github.com/foo/project1 Project1
```

## 🎼 Composer (alternative)

```bash
composer create-project bootgly/bootgly.kit --stability=dev
cd bootgly.kit
php bootgly project create
```

## 🗂 Structure

```text
bootgly.kit/
├── Bootgly/     ← the Bootgly platform (git submodule)
├── Console/     ← Console platform extras (optional submodule)
├── Web/         ← Web platform extras (optional submodule)
├── projects/    ← your projects (installed by `bootgly boot`)
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
