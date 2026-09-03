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

The installer checks your environment (git + PHP 8.4+), clones this kit, initializes the Bootgly platform and opens the **project wizard**. Nothing is asked about platforms: both (Console and Web) are set up, and every shipped example is imported as a living guide. The wizard then asks only how you want to start — **use one of the imported projects**, create one **from scratch**, or **import** from a Git remote.

Start your project right after:

```bash
cd bootgly.kit
bootgly projects list
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

`bootgly test` runs the suites of **where you stand** — every project carries its own `tests/` registry (scaffolded with an example suite), and the working directory selects the scope:

```bash
cd projects/App && bootgly test    # this project's suites
cd projects && bootgly test        # every registered project, one merged run
bootgly test --bootgly             # the Bootgly framework suites
bootgly test --console             # the Console platform suites
bootgly test --web                 # the Web platform suites
```

From the kit root, a terminal gets a picker (one project, or all); a headless run prints the registered projects and exits non-zero. The first line of every run states the resolved scope.

## 🧩 Importing projects

The shipped examples — the framework Demos, the Console games and the Web apps — are **imported automatically** when the kit is prepared, as living guides; they arrive unbooted (no repository of their own) and `php bootgly project <Name> boot` adopts one. Any directory with a `*.Project.php` file at its root is a Bootgly project; import your own directly from a git repository (the clone keeps its history and `origin`, so you keep pushing from `projects/`):

```bash
php bootgly projects import https://github.com/foo/project1 Project1
```

## 🗂 Structure

```text
bootgly.kit/
├── Bootgly/     ← the Bootgly platform (git submodule)
├── Console/     ← Console platform extras (git submodule)
├── Web/         ← Web platform extras (git submodule)
├── projects/    ← your projects — each one a git repository of its own
├── bootgly      ← the Bootgly CLI launcher
└── index.php    ← the Web front controller
```

The kit is a delivery vehicle: you never commit to it — your projects are the repositories (`create` boots each one with the scaffold as its initial commit), and Composer runs per project. Update the kit anytime with `php bootgly kit upgrade` (and go back with `php bootgly kit downgrade`) — `php bootgly kit list` shows the releases; it works on a clone and on a kit generated from this template alike.

Install the CLI globally (optional):

```bash
php bootgly setup
```

Keep PHP and the Kit unprivileged. Setup requests sudo only for the fixed
system installation operation when `/usr/local/bin` requires it.

## 📚 Documentation

- [Getting started](https://docs.bootgly.com/guide/getting-started/overview/)
- [Projects manual](https://docs.bootgly.com/manual/Bootgly/essential/projects/overview/)

## License

[MIT](./LICENSE)
