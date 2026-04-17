# Environment Setup

This document covers everything needed to run the code examples and the prototype locally.
No prior Elm experience is required. Follow the steps in order.

---

## Prerequisites

### Node.js

Elm's compiler toolchain requires Node.js. Install the LTS version from the official site:

https://nodejs.org/

Verify the installation:

```bash
node --version
npm --version
```

Any Node.js version 14 or higher works.

---

## Installing Elm

Install the Elm compiler globally via npm:

```bash
npm install -g elm
```

Verify the installation:

```bash
elm --version
```

Expected output: `0.19.1`

---

## Running the Prototype

Once Elm is installed, navigate to the prototype folder.

If you have not made any changes to the Elm source files, the application is already compiled.
You can open `public/index.html` directly in your browser - no build step needed.

If you have made changes to the Elm source files, recompile first:

```bash
cd prototype

# Recompile after changes
elm make src/Main.elm --output=public/app.js
```

Then open `public/index.html` in your browser.

> **Tip:** Install the [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer)
> extension in VS Code and use "Open with Live Server" on `public/index.html`.
> The browser will automatically refresh after each `elm make` run.
> You still need to re-run `elm make` manually after each code change.

Full setup details and run options are in [prototype/README.md](../../prototype/README.md).

---

## Running the Code Examples

The standalone examples in [docs/examples/README.md](../examples/README.md) may include links to run each example directly in the browser via [Ellie](https://ellie-app.com). No local installation is needed for those.

To run an example locally instead:

1. Create a new folder
2. Run `elm init` inside it
3. Copy the example code into `src/Main.elm`
4. Run `elm reactor` and open the file in the browser

---

<sub>Previous | [README](../../README.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [Project Overview](../01-project-overview/01-project-overview.md)</sub>
