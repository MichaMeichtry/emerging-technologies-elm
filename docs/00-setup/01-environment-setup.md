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

## Optional: elm-live (Hot Reload)

`elm-live` is a development server that automatically recompiles and reloads the browser when a file changes. It is not required but makes development faster.

```bash
npm install -g elm-live
```

Verify:

```bash
elm-live --version
```

---

## Running the Prototype

Once Elm is installed, navigate to the prototype folder and start the development server:

```bash
cd prototype
elm reactor
```

Then open http://localhost:8000/public/index.html in your browser.

Alternatively, compile to a JavaScript file manually:

```bash
elm make src/Main.elm --output=public/app.js
```

Then open `public/index.html` directly in the browser.

Full setup details and run options are in [prototype/README.md](../../prototype/README.md).

---

## Running the Code Examples

The standalone examples in [docs/examples/01-examples.md](../examples/01-examples.md) may include links to run each example directly in the browser via [Ellie](https://ellie-app.com). No local installation is needed for those.

To run an example locally instead:

1. Create a new folder
2. Run `elm init` inside it
3. Copy the example code into `src/Main.elm`
4. Run `elm reactor` and open the file in the browser

---

<sub>Previous | [README](../../README.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [Project Overview](../01-project-overview/01-project-overview.md)</sub>
