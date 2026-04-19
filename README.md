# Elm - Emerging Technologies

This repository is the result of a group project carried out as part of the module 63-51 Emerging Technologies of the Business Information Technology degree at HES-SO Valais Wallis.

The goal of the module is to discover, evaluate, and transmit an emerging technology to fellow students and professors. This project covers the **Elm programming language** - from understanding the problem it solves, to comparing it with alternatives, to building a working prototype.

> **Module:** 63-51 Emerging Technologies  
> **Degree:** Business Information Technology - HES-SO Valais Wallis  
> **Repository:** https://github.com/MichaMeichtry/emerging-technologies-elm  
> **Group members:** Bregy Noah, Donnet-Money Mégane, Meichtry Micha  
> **Presentation date:** 28.05.2026

---

## What is Elm?

Elm is a functional programming language that compiles to JavaScript. It is designed for building reliable web applications with no runtime errors, a strong type system, and a clear architecture pattern called The Elm Architecture (TEA).

Find out more in the chapter [What is Elm?](docs/02-elm-theory/01-what-is-elm.md)

Official guide: https://guide.elm-lang.org/

---

## Repository Structure

```
emerging-technologies-elm/
│
├── README.md                                       # This file
├── .gitignore
│
├── docs/
│   ├── 00-setup/                                   # Environment setup and installation
│   │   └── 01-environment-setup.md
│   │
│   ├── 01-project-overview/                        # Project goals and repo navigation
│   │   └── 01-project-overview.md
│   │
│   ├── 02-elm-theory/                              # What Elm is and how it works
│   │   ├── 01-what-is-elm.md
│   │   ├── 02-core-concepts.md
│   │   ├── 03-the-elm-architecture.md
│   │   └── 04-elm-ecosystem.md
│   │
│   ├── 03-comparison/                              # Elm compared to other technologies
│   │   ├── 01-comparison-overview.md
│   │   ├── 02-elm-vs-javascript.md
│   │   ├── 03-elm-vs-typescript.md
│   │   ├── 04-elm-vs-other-functional-options.md
│   │   ├── 05-when-elm-is-a-good-choice.md
│   │   └── 06-when-elm-is-not-a-good-choice.md
│   │
│   ├── 04-prototype/                               # Documentation of the prototype
│   │   ├── 01-prototype-description.md
│   │   ├── 02-architecture.md
│   │   ├── 03-features.md
│   │   ├── 04-how-to-run.md
│   │   └── 05-test-scenarios.md
│   │
│   └── examples/                                   # Small code examples
│   │   ├── 01-counter/                             # Elm Architecture
│   │   ├── 02-traffic-light/                       # Custom types + pattern matching
│   │   ├── 03-temperature-converter/               # Maybe + form input
│   │   └── 04-ports-localstorage/                  # JS interop trade-off
│   │   └── 05-weather-app/                         # External data sources
│   │
│   └── 99-resources/                               # Research sources and further reading
│       └── 01-resources.md
│
└── prototype/                                      # The working Elm application
    ├── README.md                                   # How to install and run the prototype
    ├── elm.json
    ├── package.json
    ├── public/
    │   └── index.html
    └── src/
        ├── Main.elm
        ├── Types.elm
        ├── Model.elm
        ├── Update.elm
        └── View.elm
```

---

## How to Navigate This Project

#### If You Need to Set Up the Environment First

[Environment Setup](docs/00-setup/01-environment-setup.md) - install Node.js, Elm, and elm-live, and verify everything works before running any code.

#### If You Want to Understand Elm

Start with the theory section in order:

1. [What is Elm?](docs/02-elm-theory/01-what-is-elm.md)
2. [Core Concepts](docs/02-elm-theory/02-core-concepts.md)
3. [The Elm Architecture](docs/02-elm-theory/03-the-elm-architecture.md)
3. [The Elm Ecosystem](docs/02-elm-theory/04-elm-ecosystem.md)

#### If You Want to See How Elm Compares to Other Technologies

Go to the comparison section:

1. [Comparison Overview](docs/03-comparison/01-comparison-overview.md)
2. [Elm vs JavaScript](docs/03-comparison/02-elm-vs-javascript.md)
3. [Elm vs TypeScript Frameworks](docs/03-comparison/03-elm-vs-typescript.md)
4. [Elm vs Other Functional Options](docs/03-comparison/04-elm-vs-other-functional-options.md)
5. [When Elm Is a Good Choice](docs/03-comparison/05-when-elm-is-a-good-choice.md)
6. [When Elm Is Not a Good Choice](docs/03-comparison/06-when-elm-is-not-a-good-choice.md)

#### If You Want to Run the Prototype

Go directly to the prototype:

[Prototype README - setup and run instructions](prototype/README.md)

The prototype is an **IT Service Desk Ticket System** built entirely in Elm. It demonstrates The Elm Architecture, custom types, pattern matching, form validation, filtering, and search, all in a browser application with no backend.

#### If You Want to See Focused Code Examples

[Examples](docs/examples/)

Small standalone examples showing specific Elm concepts with explanations. Each example includes a link to run it live in the browser via [Ellie](https://ellie-app.com).

---

## Running the Prototype

### Prerequisites

- [Node.js](https://nodejs.org/) (required for the Elm toolchain)
- Elm compiler: `npm install -g elm`

See [docs/00-setup/01-environment-setup.md](docs/00-setup/01-environment-setup.md) for the full setup guide.

### Run

```bash
# Navigate to the prototype folder
cd prototype

# Compile to a JavaScript file
elm make src/Main.elm --output=public/app.js
```

Then open `public/index.html` directly in your browser.

> **Tip:** Install the [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer)
> extension in VS Code and use "Open with Live Server" on `public/index.html`.
> The browser will automatically refresh after each `elm make` run.

---

## Project Goals

This project covers the following requirements:

| Goal                                     | Where it is covered                                                              |
| ---------------------------------------- | -------------------------------------------------------------------------------- |
| Understand the problem Elm addresses     | [docs/02-elm-theory/01-what-is-elm.md](docs/02-elm-theory/01-what-is-elm.md)     |
| Compare Elm with other solutions         | [docs/03-comparison/](docs/03-comparison/)                                       |
| Try Elm in a basic environment           | [docs/examples/README.md](docs/examples/README.md)                               |
| Test core functionalities                | [docs/04-prototype/05-test-scenarios.md](docs/04-prototype/05-test-scenarios.md) |
| Create a prototype to showcase potential | [prototype/](prototype/)                                                         |
| Document the process                     | [docs/](docs/)                                                                   |

---

## Resources

Research sources and recommended further reading are listed in [docs/99-resources/01-resources.md](docs/99-resources/01-resources.md).

---

<sub>Next | [Project Overview](docs/01-project-overview/01-project-overview.md)</sub>
