# Comparison Overview

This section compares Elm to technologies a developer would realistically consider when building a frontend web application. The goal is not to determine which technology is objectively better, but to understand where Elm's trade-offs work in its favour and where they work against it.

---

## Why Compare Elm to Other Technologies?

Elm is not a general-purpose language. It targets one specific problem: building reliable browser-based user interfaces. Any meaningful comparison has to stay within that scope. Comparing Elm to Python, Java, or SQL would not be useful here, because those tools are not competing for the same use case.

The relevant alternatives are the tools a frontend developer or a small team would evaluate when starting a new web application:

- Plain JavaScript, the default, no build step required
- TypeScript, JavaScript with optional static typing
- React with TypeScript, the dominant framework and type system combination in the industry
- Vue with TypeScript, a second major framework with a similar profile
- ReScript and PureScript, functional alternatives that also compile to JavaScript

---

## Comparison Criteria

The comparisons that follow use a consistent set of criteria. Not every criterion matters equally in every situation, but defining them upfront makes the analysis more transparent.

**Type safety**  
How much does the type system prevent incorrect code from being written in the first place, and how much does it catch at compile time vs. at runtime?

**Runtime error prevention**  
How likely is the application to crash or behave unexpectedly in production due to unhandled states, missing cases, or null-related failures?

**Architecture and state management**  
Does the technology impose a structure for managing application state, or is that left to the developer's discretion?

**Learning curve**  
How long does it take a developer with a standard web development background to become productive, and what is the shape of that learning process?

**Ecosystem and library availability**  
How much can third-party packages cover, and how much needs to be built from scratch or handled through workarounds?

**JavaScript interoperability**  
How easily does the technology integrate with existing JavaScript code, browser APIs, and third-party libraries written in JavaScript?

**Team suitability**  
How easy is it to hire developers who already know the technology, and how steep is onboarding for developers who do not?

**Development speed**  
How quickly can a working application be built, and how does that change over time as the application grows?

---

## Technologies Considered

| Technology         | Category             | Primary strength                                        |
| ------------------ | -------------------- | ------------------------------------------------------- |
| JavaScript         | Language             | Ubiquity, zero setup, maximum flexibility               |
| TypeScript         | Language (typed JS)  | Type safety on top of the JS ecosystem                  |
| React + TypeScript | Framework + language | Dominant ecosystem, large talent pool                   |
| Vue + TypeScript   | Framework + language | Gentler learning curve, strong conventions              |
| ReScript           | Functional language  | Strong types, full JS interop, practical escape hatches |
| PureScript         | Functional language  | Haskell-style type system, maximum theoretical safety   |
| Elm                | Functional language  | No runtime errors by design, enforced architecture      |

---

## Limits of This Comparison

These comparisons reflect the state of each technology at the time of writing. Ecosystems change. The comparisons are also written from the perspective of building a small to medium-sized browser application with a team of two to four developers. A different context, such as a large team, a performance-critical application, or a project requiring heavy JavaScript library integration, would shift some conclusions.

No comparison can be fully objective. The criteria above are weighted toward correctness and reliability, which are the properties Elm's design most visibly prioritises. A technology that values flexibility over strictness will look weaker under these criteria than it might under a different set of priorities.

---

## How This Section Is Organised

| File                                                                       | Content                                                                                                       |
| -------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| [Elm vs JavaScript](./02-elm-vs-javascript.md)                             | The most fundamental comparison - what Elm gives up and what it gains relative to the language it compiles to |
| [Elm vs TypeScript Frameworks](./03-elm-vs-typescript-frameworks.md)       | Type safety, architecture, and ecosystem compared to React and Vue with TypeScript                            |
| [Elm vs Other Functional Options](./04-elm-vs-other-functional-options.md) | How Elm compares to ReScript and PureScript as typed functional alternatives                                  |
| [When Elm Is a Good Choice](./05-when-elm-is-a-good-choice.md)             | Conditions and project types where Elm's trade-offs are worth making                                          |
| [When Elm Is Not a Good Choice](./06-when-elm-is-not-a-good-choice.md)     | Conditions and project types where Elm's trade-offs work against you                                          |

---

<sub>Previous | [Project Overview](../01-project-overview/01-project-overview.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [Elm vs JavaScript](./02-elm-vs-javascript.md)</sub>
