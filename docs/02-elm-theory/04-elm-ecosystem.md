# The Elm Ecosystem

## Overview

The Elm ecosystem is deliberately small and self-contained. While JavaScript projects usually comprise a build pipeline made up of dozens of separate tools and packages, Elm provides a single binary that covers compilation, package management, a development server and a code formatter. This is not an accident - it reflects a conscious design philosophy that prioritises stability and a reliable out-of-the-box experience over extensibility [1].

The trade-off is real: the ecosystem has fewer packages than npm, and some browser APIs require a JavaScript bridge via ports. However, for the use cases that Elm targets - reliable, long-lived front-end applications - the constraints tend to pay off over time [1].

## The Elm Compiler and Toolchain

All components of Elm's toolchain are distributed as a single executable. The following commands are available after installation [1]:

### elm make

`elm make` compiles an Elm application into JavaScript. This is the only build step required for production.

```bash
elm make src/Main.elm --output=main.js
```

The `--optimize` flag enables dead-code elimination and minification hints for production builds. Without this flag, the output includes debugging information and user-friendly runtime error messages [1].

```bash
elm make src/Main.elm --output=main.js --optimize
```

The compiled output is a plain JavaScript file that exposes an `Elm.Main.init` function. No bundler or runtime dependencies are required, and it can be loaded directly with a `<script>` tag [1]. See [04-ports-localstorage/index.html](../examples/04-ports-localstorage/index.html) for an example of how the compiled output is loaded and connected to JavaScript ports.

### elm reactor

`elm reactor` starts a local development server that compiles Elm files on demand in the browser. No configuration is required.

```bash
elm reactor
```

Navigating to `http://localhost:8000` shows a file browser. Clicking on any `.elm` file compiles and runs it immediately. This is the fastest way to experiment with Elm, as no build setup is required [1].

### elm repl

`elm repl` opens an interactive shell for evaluating Elm expressions. This is useful for testing small functions and exploring the core library.

```bash
elm repl
> 2 + 2
4 : Int
> String.toUpper "elm"
"ELM" : String
```

### elm install

`elm install` adds a package to the current project. It automatically resolves dependencies and updates `elm.json` [3].

```bash
elm install elm/http
elm install elm/json
```

## elm.json

Every Elm project has an `elm.json` file at its root. This file serves the same purpose as `package.json` in a Node project, in that it declares the Elm version, the source directories, and the direct and indirect dependencies [3].

```json
{
    "type": "application",
    "source-directories": ["src"],
    "elm-version": "0.19.1",
    "dependencies": {
        "direct": {
            "elm/browser": "1.0.2",
            "elm/core": "1.0.5",
            "elm/html": "1.0.1"
        },
        "indirect": {
            "elm/json": "1.1.4",
            "elm/virtual-dom": "1.0.5"
        }
    },
    "test-dependencies": {
        "direct": {},
        "indirect": {}
    }
}
```

An important difference from npm is that Elm enforces exact version pinning for application projects. There are no version ranges or qualifiers such as `^` or `~`. Every dependency resolves to a single, known version, making builds fully reproducible without a lockfile [3]. The `elm.json` from [04-ports-localstorage](../examples/04-ports-localstorage/elm.json) is a minimal real-world example.

## The Package Registry

Elm has its own package registry at [package.elm-lang.org](https://package.elm-lang.org). Every package published there must adhere strictly to semantic versioning - the compiler automatically enforces this by comparing the public API of a new version with the previous one and refusing to publish if the version bump is incorrect [1].

All packages on the registry must be open source, and every package must have documentation for every exposed function. These requirements are enforced by the registry itself, not by convention [1].

As the package surface is smaller than that of npm, it is generally easier to find the canonical package for a given task. For HTTP requests there is `elm/http`. For JSON decoding there is `elm/json`. For time and dates there is `elm/time`. The core abstractions are stable and well documented [1].

## elm-format

`elm-format` is the official code formatter for Elm. It enforces a single, non-configurable style across all Elm code, with no options for adjustment [4].

```bash
elm-format src/Main.elm --yes
```

Because the format is universal, all Elm code looks the same in all projects. This eliminates the need for style discussions during code reviews entirely and makes unfamiliar codebases easier to read [4].

## Ellie

[Ellie](https://ellie-app.com) is a browser-based Elm editor and compiler. It requires no local installation and supports the sharing of runnable examples via a URL. Four out of five examples in this repository include an Ellie link for this very reason - readers can open the example, read the code, and run it without installing anything [5].

The one exception is [04-ports-localstorage](../examples/04-ports-localstorage/README.md), which requires a custom `index.html` to connect the JavaScript port subscribers. This glue code cannot be provided in Ellie, so the example must be run locally.

## Core Packages

The following packages are included with every Elm project and are widely used [1][3]:

`elm/core` provides the standard library: basic types (`Int`, `Float`, `String`, `Bool`), collections (`List`, `Dict`, `Set`, `Array`), and foundational abstractions (`Maybe`, `Result`, `Task`).

`elm/html` provides functions for building HTML elements and attributes. Every call to `div`, `button`, `input`, and so on comes from this package.

`elm/browser` provides the `Browser.sandbox` and `Browser.element` entry points used in all five examples, as well as `Browser.application` for single-page applications with URL routing.

`elm/http` provides the `Http.get`, `Http.post`, and related functions for making HTTP requests. It is used in [05-weather-app/Main.elm](../examples/05-weather-app/Main.elm).

`elm/json` provides `Json.Decode` and `Json.Encode` for working with JSON. The decoder pattern - building typed decoders that fail explicitly rather than returning null - is central to how Elm safely handles external data. It is used alongside `elm/http` in [05-weather-app/Main.elm](../examples/05-weather-app/Main.elm).

## The Deliberate Small Surface

The Elm ecosystem is intentionally narrow in scope. The language has not had any new features added to it for several years, and this is by design. The compiler is built to produce small, optimised assets and clear error messages rather than regularly shipping new syntax [2]. A smaller language is easier to learn, easier to teach, and easier to maintain [1].

This philosophy extends to the package ecosystem. There is no Elm equivalent of a UI component mega-library with hundreds of configurable options. Instead, the community tends to build small, composable packages with well-defined boundaries [1].

For teams that need a predictable, low-churn technology choice, this is an advantage. However, for teams that want to adopt the latest language features quickly, it can feel limiting. It is important to understand this trade-off when evaluating Elm for a project [1].

## Sources

[1] Czaplicki, E. *An Introduction to Elm*. Official Elm Guide.
    https://guide.elm-lang.org/

[2] Czaplicki, E. *Small Assets without the Headache*. elm-lang.org (2018).
    https://elm-lang.org/news/small-assets-without-the-headache

[3] Czaplicki, E. *Installing elm packages*. Official Elm Guide.
    https://guide.elm-lang.org/install/elm.html

[4] avh4. *elm-format*. GitHub.
    https://github.com/avh4/elm-format

[5] Westby, L. *Ellie - The Elm Live Editor*.
    https://ellie-app.com

---
<sub>Previous | [The Elm Architecture](03-the-elm-architecture.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [Comparison Overview](../03-comparison/01-comparison-overview.md)</sub>