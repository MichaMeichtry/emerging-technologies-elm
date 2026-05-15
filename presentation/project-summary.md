# Project Summary

## What Is Elm?

Elm is a purely functional programming language that compiles to JavaScript. It is designed exclusively for browser applications and is built around three guarantees: no runtime errors, a strict type system, and a single enforced architecture.

It was created by Evan Czaplewski as his 2012 Harvard thesis, motivated by the gap between academic programming language research and mainstream web development. Czaplewski's core observation was that the most reliable ideas from academic computer science rarely reached mainstream developers. Elm was his attempt to bridge that gap by bringing functional programming principles into the browser in a form that was accessible without a computer science background.

Full coverage: [What is Elm?](../docs/02-elm-theory/01-what-is-elm.md)

---

## The Problem Elm Addresses

JavaScript was not designed for large front-end applications. It was originally created in ten days in 1995 as a lightweight scripting language for simple browser interactions. As web applications grew in complexity, JavaScript was stretched far beyond that original scope without the language itself gaining the structural guarantees needed to manage that complexity reliably.

The three most costly failure modes in JavaScript development are runtime crashes from null references and undefined values (errors that only surface when the exact code path is executed, often in production), unpredictable mutable state (where any part of the codebase can modify shared data, making it difficult to understand why the UI is in a particular state), and ecosystem fragility (where achieving reliability requires combining many separate libraries such as React, Redux, TypeScript, and Babel, each of which introduces its own complexity and upgrade risk).

Elm addresses all three at the language level. Null does not exist. Mutation is not possible. The architecture is not a choice. These are not features that a team opts into - they are properties of every Elm program by construction.

---

## Core Concepts

The following concepts underpin everything in this project. They are not independent ideas, each one reinforces the others and together they produce the properties Elm is known for.

### Immutability

In Elm, all values are immutable. Once a value is created, it cannot be changed. If a state change is needed, a new value is produced incorporating the desired change, and the old value is discarded. This is not a convention or a best practice, it is enforced by the language. There is no mechanism in Elm to mutate a value in place.

The practical consequence is predictability. At any point in an Elm program, a value means exactly what it was assigned. It cannot have been changed by a distant part of the codebase, by a side effect, or by a concurrent process. This eliminates an entire category of bugs that are common in JavaScript: values changing unexpectedly, state becoming inconsistent, and debugging requiring the reconstruction of what mutations happened and in what order.

Immutability also makes the update function in TEA straightforward to reason about. Because the existing model cannot be modified, every state transition is explicit: the old model goes in, a new model comes out.

### Pure Functions

A pure function always produces the same output given the same input, and has no side effects, it does not read from or write to anything outside its own scope. All functions in Elm are pure by design. There is no mechanism to perform a side effect directly from within a function.

This has two important consequences. First, pure functions are trivially testable. Given the same input, the output is always the same, with no need to mock external state or worry about the order of execution. Second, the compiler can reason about pure functions completely. It knows exactly what a function does and does not do.

Side effects in Elm (HTTP requests, reading from localStorage, generating random numbers) are not prohibited, they are handled differently. Instead of calling a side effect directly, a function returns a description of the side effect it wants performed. The Elm runtime receives that description and executes it, then delivers the result back as a message. This keeps user code pure while still allowing the application to interact with the outside world.

### Static Typing with Type Inference

Elm is statically typed, meaning the compiler verifies that every value in the program has a known, consistent type before the program runs. Unlike TypeScript, where types are optional and can be bypassed, Elm's type system covers the entire language with no escape hatches.

Type inference means that type annotations are not required in most cases - the compiler can deduce the type of a value from how it is used. Annotations are encouraged for documentation purposes but are not mandatory for type checking to work.

The practical effect is that a class of errors common in JavaScript, passing the wrong type to a function, calling a method on a value that does not have it, mismatching the shape of a record, are caught at compile time and reported with specific, actionable error messages before the program can run. Elm's compiler error messages are notably clear compared to most compilers: they name the exact problem, explain the consequence, and suggest a fix.

### Custom Types and Pattern Matching

Custom types (also called union types or algebraic data types) allow a value to be exactly one of several explicitly named variants. A `TicketStatus` can be `Open`, `InProgress`, `Resolved`, or `Closed` and nothing else. There is no way to represent an invalid status, no string that might contain a typo, no integer that might be out of range.

Pattern matching via `case` expressions is the mechanism for working with custom types. Every `case` expression must cover all variants of the type being matched. If a developer adds a new variant to a custom type and forgets to handle it in a `case` expression, the program will not compile. The compiler names the missing variant and reports every location in the codebase where it is unhandled.

This combination, custom types plus exhaustive pattern matching, is one of Elm's most powerful features. It makes it structurally impossible to forget a case. In a ticket system, if a fifth status is added, every status badge, every dropdown, every filter button, and every update branch must be updated before the code will compile. No case can silently fall through.

### Maybe and Result

Elm has no `null` and no exceptions. These two language features, present in most mainstream languages, are responsible for a large proportion of runtime errors. `null` causes crashes when code assumes a value is present and it is not. Exceptions cause crashes when an error case is not anticipated or caught.

Elm replaces both with explicit types. `Maybe` represents a value that may or may not exist. It has two variants: `Just value` when the value is present, and `Nothing` when it is absent. The compiler requires that both cases are handled wherever a `Maybe` is used. It is not possible to accidentally treat a `Maybe String` as a plain `String`.

`Result` represents an operation that can succeed or fail. It has two variants: `Ok value` when the operation succeeded, and `Err error` when it failed. Like `Maybe`, both cases must be handled. This is how Elm handles HTTP responses, JSON decoding failures, and any other operation that might not produce the expected output.

The key insight is that `Maybe` and `Result` make absence and failure visible in the type system. A function that might not return a value says so in its type signature. A function that might fail says so in its return type. There are no surprises at runtime.

### Tuples

Tuples are fixed-size collections of values that can hold different types. Unlike lists, which must contain values of the same type, a tuple can hold a `String` and an `Int` together. Unlike records, tuples have no field names, the position carries the meaning. Elm limits tuples to three elements; anything larger should use a named record instead.

Tuples appear most commonly as a way to return multiple values from a function. This pattern appears in TEA itself: the `update` function in `Browser.element` returns a tuple of `(Model, Cmd Msg)`, a new model paired with a command for the runtime to execute.

Full coverage: [Core Concepts](../docs/02-elm-theory/02-core-concepts.md)

---

## The Elm Architecture (TEA)

![The Elm Architecture loop](../docs/images/tea_loop.svg)

The Elm Architecture is the mandatory pattern that every Elm application is built on. It is not a framework or a library, it is the only way to structure an Elm application. It emerged naturally from the constraints of a purely functional, immutable language: when mutation and side effects are prohibited in user code, a structured way of managing state changes is not optional.

Every Elm application consists of exactly three parts that form a loop driven by the Elm runtime.

**Model** - the complete application state, stored in a single record. Everything the application needs to remember between interactions lives here. Nothing lives outside it. Because values in Elm are immutable, the model is never modified directly, the `update` function always produces a new model based on the existing one.

**Msg** - a custom type listing every possible user action or system event. The naming convention is important: variants describe what has happened (`SubmitTicket`, `ChangeStatus`), not what should happen. Because `Msg` is a custom type, the compiler requires that every variant is handled in the `update` function. Adding a new interaction requires adding a `Msg` variant, and the compiler will report any location where it is not yet handled.

**Update** - a pure function that takes the current model and a message and returns a new model. It is the only place in an Elm application where state can change. Because it is pure, every state transition is testable in isolation: given the same model and the same message, `update` always returns the same new model.

**View** - a pure function that takes the current model and returns a description of the HTML to render. Because it is pure, the same model always produces the same HTML. There is no direct DOM manipulation, the Elm runtime compares the previous and current virtual DOM trees and applies only the changes that are necessary.

For applications that need to communicate with the outside world, `Browser.element` extends the pattern with two additional concepts. `Cmd` (Command) is a value that describes a side effect the Elm runtime should perform - an HTTP request, a write to localStorage, a request for the current time. The `update` function returns a `(Model, Cmd Msg)` pair instead of just a `Model`. `Sub` (Subscription) instructs the runtime to listen for external events and deliver them as messages, a timer firing, a WebSocket message arriving, a value coming in through a port.

The architectural benefits of TEA are concrete. There is a single source of truth for all state. Data flows in one direction only: a message enters `update`, a new model comes out, `view` renders it. Every possible action is declared upfront as a `Msg` variant. Every state transition is a branch in `update`. The compiler verifies that all cases are covered.

Full coverage: [The Elm Architecture](../docs/02-elm-theory/03-the-elm-architecture.md)

---

## The Elm Ecosystem

Elm ships as a single binary that covers everything needed to build and run an Elm application: compilation (`elm make`), a development server (`elm reactor`), an interactive REPL (`elm repl`), and package management (`elm install`). There is no separate build pipeline to configure, no bundler to set up, and no plugin ecosystem to manage. This is a deliberate design choice that prioritises a reliable out-of-the-box experience over extensibility.

`elm make` compiles an Elm application to a plain JavaScript file that can be loaded with a `<script>` tag. No runtime dependencies are required. The `--optimize` flag enables dead-code elimination and produces significantly smaller output for production.

`elm reactor` starts a local development server that compiles Elm files on demand in the browser. Navigating to a `.elm` file compiles and runs it immediately with no build step.

`elm-format` is the official code formatter. It enforces a single, non-configurable style across all Elm code. Because the format is universal, all Elm code looks the same in all projects, eliminating style discussions in code review and making unfamiliar codebases easier to read.

[Ellie](https://ellie-app.com) is a browser-based Elm editor and compiler that requires no local installation and supports sharing runnable examples via a URL. Four of the five code examples in this project include an Ellie link for this reason.

The package registry at [package.elm-lang.org](https://package.elm-lang.org) enforces semantic versioning automatically. The compiler verifies that a major version bump accompanies any breaking API change. Every published package must document all exposed functions. The registry is smaller than npm but more uniform in its quality guarantees.

The ecosystem is intentionally narrow. The language has not had new features added for several years, and this is by design. A smaller language is easier to learn, easier to teach, and easier to maintain. For teams that value a predictable, low-churn technology choice, this is an advantage. For teams that want to adopt the latest language features quickly, it can feel limiting.

Full coverage: [The Elm Ecosystem](../docs/02-elm-theory/04-elm-ecosystem.md)

---

## Comparison with Other Technologies

The comparison section evaluates Elm against the technologies a developer would realistically consider for a browser application. The criteria used consistently across all comparisons are: type safety, runtime error prevention, architecture and state management, learning curve, ecosystem and library availability, JavaScript interoperability, team suitability, and development speed.

### Elm vs. JavaScript

JavaScript is the default language of the web. Every browser runs it natively, no build step is required, and every frontend developer already knows it. Elm compiles to JavaScript and targets the same environment but makes fundamentally different choices about how that environment is used.

JavaScript has no static type system. Variables can hold any value at any time, function arguments are not checked, and there is nothing preventing a caller from passing the wrong type to a function. Errors caused by type mismatches only appear at runtime, and only if the code path that triggers them is actually executed. Elm has a static type system that covers the entire language with no opt-out.

JavaScript imposes no structure on state management. State can live anywhere and be mutated from anywhere. Understanding why the UI is in a particular state often requires tracing mutations across multiple files. Elm enforces The Elm Architecture on every application with no alternative. All state lives in one model, all changes go through one update function, and there is exactly one place to look for any state change.

JavaScript allows rapid prototyping with no compilation step and no architecture to adopt before producing a working result. For larger applications the trade-off shifts: JavaScript's lack of structure means more time spent debugging runtime errors and tracing state mutations as the application grows. Elm's compiler acts as a continuous check, and refactoring is safer because the compiler reports every affected location when a type or function signature changes.

| Criterion                 | JavaScript             | Elm                                       |
| ------------------------- | ---------------------- | ----------------------------------------- |
| Type safety               | None                   | Full, no opt-out                          |
| Runtime errors            | Common class of errors | Eliminated by design                      |
| Architecture              | None enforced          | TEA enforced                              |
| Learning curve            | Low initial barrier    | High initial barrier, finite surface area |
| Ecosystem                 | Very large             | Small but curated and reliable            |
| JS interoperability       | Direct                 | Through ports only                        |
| Team suitability          | Universal              | Specialist knowledge required             |
| Development speed (small) | Fast                   | Slower initial setup                      |
| Development speed (large) | Degrades with scale    | More stable with scale                    |

[Full comparison](../docs/03-comparison/02-elm-vs-javascript.md)

---

### Elm vs. TypeScript Frameworks (React, Vue)

React with TypeScript is the dominant combination for building frontend applications in the industry. Vue with TypeScript occupies a similar space with a gentler learning curve. Both use TypeScript as an opt-in type layer on top of JavaScript.

TypeScript adds static typing to JavaScript, but the type system is opt-in and has intentional escape hatches. A developer can use `any` to bypass type checking entirely, cast values with `as`, or leave large portions of a codebase untyped. TypeScript's type system is also structurally typed, two types are interchangeable if they have the same shape, regardless of their declared names. Elm uses nominal typing for custom types: `TicketStatus` and `Priority` are distinct types even if they happened to share the same set of variants.

For TypeScript to approach Elm's level of coverage, a team needs explicit discipline: banning `any`, configuring strict mode, avoiding type assertions, and enforcing these rules consistently across contributors. Elm provides these guarantees without requiring that discipline, because the compiler enforces them unconditionally.

React is a UI rendering library, not a framework for managing application state. State management is the developer's responsibility, with options ranging from component-local state to context to external libraries. Each has different rules and trade-offs, and a React codebase can use multiple approaches simultaneously. This flexibility is useful when an application has genuinely different state requirements across sections. It becomes a maintenance problem when the team has not agreed on a consistent approach. Elm enforces TEA on every application with no alternative.

Vue has a more opinionated structure than React. The Composition API and single-file components provide defined patterns for organising component logic, making Vue codebases more consistent across teams than React codebases, without going as far as TEA's enforcement.

| Criterion                 | React + TypeScript             | Vue + TypeScript               | Elm                                  |
| ------------------------- | ------------------------------ | ------------------------------ | ------------------------------------ |
| Type safety               | Partial, opt-out available     | Partial, opt-out available     | Full, no opt-out                     |
| Runtime errors            | Reduced but not eliminated     | Reduced but not eliminated     | Eliminated by design                 |
| Architecture              | None enforced, many options    | Conventions, not enforcement   | TEA enforced                         |
| Learning curve            | Large surface, gradual mastery | Gentler than React, still wide | Steep initially, finite surface area |
| Ecosystem                 | Very large                     | Large                          | Small but curated and reliable       |
| JS interoperability       | Direct                         | Direct                         | Through ports only                   |
| Team suitability          | Universal, large hiring pool   | Common, good hiring pool       | Specialist knowledge required        |
| Development speed (small) | Fast                           | Fast                           | Slower initial setup                 |
| Development speed (large) | Depends on discipline          | Depends on discipline          | More stable with scale               |

[Full comparison](../docs/03-comparison/03-elm-vs-typescript-frameworks.md)

---

### Elm vs. ReScript and PureScript

ReScript and PureScript are both functional languages that compile to JavaScript and offer stronger type guarantees than TypeScript. They represent different points on the spectrum between practical JavaScript integration and theoretical type-system expressiveness.

ReScript originated as BuckleScript, the JavaScript backend for the OCaml compiler. Its type system is derived from OCaml, one of the more mature functional type systems in production use. Unlike Elm, ReScript allows direct JavaScript calls through `external` declarations, meaning any npm package is accessible with a single binding. This makes it significantly more practical for projects that need deep JavaScript integration. The trade-off is that the type system's guarantees weaken at every JavaScript boundary: the developer declares the type of the JavaScript function, and the compiler trusts that declaration without verifying the actual JavaScript implementation. ReScript also imposes no application architecture, typically deferring to React-based patterns.

PureScript is a purely functional language closely related to Haskell. It supports higher-kinded types and type classes, abstractions that allow writing a single function that works over any container type implementing a given interface, such as `Functor` or `Monad`. Elm deliberately excludes these abstractions to keep the language approachable without a computer science background. PureScript has the steepest learning curve of the three, the smallest ecosystem, and is rarely used in commercial frontend development. It is primarily used by developers with a Haskell background who want to apply those skills in a JavaScript environment.

Elm sits between them: less flexible than ReScript in terms of JavaScript integration, less expressive than PureScript in terms of type-system depth, but bounded in scope, intentionally teachable, and with a single enforced architecture that makes every Elm codebase structurally familiar.

| Criterion                 | Elm                                  | ReScript                                      | PureScript                                          |
| ------------------------- | ------------------------------------ | --------------------------------------------- | --------------------------------------------------- |
| Type safety               | Full, no opt-out                     | Very high, seam at JS boundary                | Maximum expressiveness, Haskell-style               |
| Runtime errors            | Eliminated by design                 | Eliminated in pure code, seam at JS FFI       | Eliminated in pure code, seam at JS FFI             |
| Architecture              | TEA enforced                         | None enforced, typically React-based          | None enforced, Halogen or custom                    |
| Learning curve            | Steep initially, finite surface area | Lower initially, deeper at intermediate level | Steepest, assumes functional programming background |
| Ecosystem                 | Small, curated, reliable             | Full npm access via FFI                       | Small, limited UI library support                   |
| JS interoperability       | Through ports only                   | Direct via external declarations              | Via FFI, two-file binding required                  |
| Team suitability          | Specialist knowledge required        | Easier if React background exists             | Rare in commercial use                              |
| Development speed (small) | Slower initial setup                 | Fast, especially with React experience        | Slow, high initial conceptual overhead              |
| Development speed (large) | More stable with scale               | Stable within typed code                      | Stable but steep ongoing learning investment        |

[Full comparison](../docs/03-comparison/04-elm-vs-other-functional-options.md)

---

### When Elm Fits

Elm is a strong fit in the following conditions.

**Complex, long-lived UI state** - TEA enforces a single location for all state and a single path for all changes. For applications where understanding why the UI is in a particular state is a recurring debugging task, this constraint eliminates an entire category of maintenance work.

**Reliability is a hard requirement** - A program that compiles in Elm has null errors, unhandled case branches, type mismatches, and missing validation on external data structurally ruled out. This guarantee is unconditional, not dependent on configuration or discipline.

**Teams prepared to front-load the learning investment** - Elm's language surface is finite and does not grow. There are no competing state management libraries to evaluate, no architectural patterns to debate, no configuration options for the type system. Once TEA and the type system are understood, the structure of any Elm application is immediately familiar.

**Educational or architecture-driven contexts** - Elm was designed with teachability as an explicit goal. Every concept is explicit and traceable. The examples in this project demonstrate this: the counter shows the entire TEA loop in under fifty lines, and the traffic light shows exactly what happens when a new variant is added without updating every pattern match.

**Small teams where consistency matters more than hiring breadth** - Because all Elm applications follow TEA, a developer familiar with the pattern can read any Elm codebase and understand its structure immediately. In React, the same is not true.

[Full breakdown](../docs/03-comparison/05-when-elm-is-a-good-choice.md)

---

### When Elm Does Not Fit

Elm is not the right choice in the following conditions.

**Heavy third-party JavaScript library integration** - Elm communicates with JavaScript exclusively through ports. Every interaction with a browser API or a third-party library requires a declared port on the Elm side and a subscriber on the JavaScript side. For applications that depend on frequent or deep integration with JavaScript libraries, this overhead accumulates to the point of working against the application.

**Organisations that need to hire quickly from a broad pool** - Elm's usage in the Stack Overflow Developer Survey 2024 was 1.4% of respondents. Most teams adopting Elm will need to train developers from scratch, and the hiring pool for existing Elm experience is narrow.

**Short timelines or throwaway prototypes** - Elm front-loads its costs. A developer who does not yet know TEA cannot write meaningful Elm code before understanding the pattern. For short-lived projects where the goal is to produce something quickly and discard it, that entry price does not pay for itself.

**Applications built primarily on browser APIs** - File system access, clipboard operations, WebSockets, WebGL, and direct DOM manipulation all fall outside what Elm's standard packages cover. Each one requires port infrastructure, which compounds across the application.

**Large teams with mixed backgrounds and no structured learning investment** - The compiler's constraints are productive guardrails for a developer who has chosen to adopt Elm. For a developer required to use it without that commitment, the same constraints generate friction. Large teams with high turnover or no organisational investment in a learning program are likely to find that Elm's constraints slow them down rather than help them.

[Full breakdown](../docs/03-comparison/06-when-elm-is-not-a-good-choice.md)

---

### Key Data Point

The Stack Overflow Developer Survey 2024 placed Elm's usage at 1.4% of respondents, but 52.4% of those who had used it said they wanted to continue, one of the highest admiration rates in the survey. The gap between those two numbers is the trade-off in data form: the upfront cost is real and front-loaded, and the value is real but only visible after it has been paid.

[Comparison summary](../docs/03-comparison/07-summary.md)

---

## Code Examples

Five standalone examples cover specific Elm concepts. Four run directly in the browser via Ellie with no local setup.

| #   | Example                                                                      | Concept                           | Link                                         |
| --- | ---------------------------------------------------------------------------- | --------------------------------- | -------------------------------------------- |
| 01  | [Counter](../docs/examples/01-counter/README.md)                             | The Elm Architecture              | [Ellie](https://ellie-app.com/ytSFnWVDs5ka1) |
| 02  | [Traffic Light](../docs/examples/02-traffic-light/README.md)                 | Custom types and pattern matching | [Ellie](https://ellie-app.com/ytTZN6D7h47a1) |
| 03  | [Temperature Converter](../docs/examples/03-temperature-converter/README.md) | Maybe and input validation        | [Ellie](https://ellie-app.com/ytVm6tFpwSLa1) |
| 04  | [Persistent Note](../docs/examples/04-ports-localstorage/README.md)          | Ports and localStorage            | local only                                   |
| 05  | [Weather App](../docs/examples/05-weather-app/README.md)                     | HTTP and JSON decoding            | [Ellie](https://ellie-app.com/yvk66GngrgZa1) |

**Example 01** shows the complete TEA loop in under fifty lines. **Example 02** demonstrates how adding a new custom type variant forces updates across every pattern match in the codebase. **Example 03** shows how `Maybe` forces explicit handling of invalid input - `String.toFloat` returns `Maybe Float`, not `Float`. **Example 04** demonstrates the port system and why the JS boundary exists. **Example 05** shows HTTP requests, JSON decoding, and `Result`-based error handling in a real API call.

---

## Prototype

The prototype is an IT Service Desk Ticket Management System built entirely in Elm using `Browser.sandbox`. It runs in the browser with no backend, all data lives in the Elm model in memory.

### Why This Application

The ticket domain maps naturally onto Elm's strengths: structured data with typed fields, a defined lifecycle (Open, In Progress, Resolved, Closed) that fits custom types and pattern matching, and enough complexity to demonstrate real Elm features without requiring a backend.

### Features

The application supports creating tickets with title, description, priority, category, and optional due date; filtering by status with live counts; keyword search across title and description; a detail view with full ticket metadata; status changes from both the list and the detail view; per-ticket comments; a full status history timeline; and overdue badge display based on a hardcoded reference date.

### Elm Concepts Demonstrated

| Concept                  | Where it appears                                           |
| ------------------------ | ---------------------------------------------------------- |
| TEA                      | Entire application - Model, Msg, update, view              |
| Custom types             | `TicketStatus`, `Priority`, `FilterState`                  |
| Pattern matching         | Status badges, dropdowns, filter logic, update branches    |
| Maybe                    | `selectedTicket`, `dueDate`, `formError`                   |
| Immutable record updates | Every branch of `update`                                   |
| List operations          | `List.filter`, `List.map` for filtering and status changes |
| Pure functions           | All view helpers, `applyFilter`, `validateForm`            |
| Conditional rendering    | Modal overlay, detail vs. list view                        |

### Source Files

```
prototype/src/
├── Main.elm     # Entry point: wires TEA together via Browser.sandbox
├── Types.elm    # All custom type definitions
├── Model.elm    # Model record, init, and seed data
├── Msg.elm      # All Msg variant declarations
├── Update.elm   # update function and all state transition logic
└── View.elm     # All view functions and HTML rendering
```

### Intentional Simplifications

There is no backend, no persistent storage, and no real-time clock. Timestamps and the overdue reference date (`today = "2026-04-24"` in `View.elm`) are hardcoded strings. A production application would use `elm/time` via a `Task` and a subscription, which would require `Browser.element`. These simplifications are deliberate to keep the prototype focused on demonstrating core Elm concepts.

### Running the Prototype

```bash
cd prototype
elm make src/Main.elm --output=public/app.js
```

Then open `public/index.html` in a browser. Full instructions: [prototype/README.md](../prototype/README.md)

### Documentation

[Prototype Overview](../docs/04-prototype/01-prototype-overview.md) - [Data Model](../docs/04-prototype/02-data-model.md) - [Messages and Update](../docs/04-prototype/03-messages-and-update.md) - [View](../docs/04-prototype/04-view.md) - [Test Scenarios](../docs/04-prototype/05-test-scenarios.md)

---

## Repository Navigation

| Goal                                 | Where to look                                                                     |
| ------------------------------------ | --------------------------------------------------------------------------------- |
| Set up the environment               | [docs/00-setup/01-environment-setup.md](../docs/00-setup/01-environment-setup.md) |
| Understand what Elm is               | [docs/02-elm-theory/](../docs/02-elm-theory/)                                     |
| See how Elm compares to alternatives | [docs/03-comparison/](../docs/03-comparison/)                                     |
| Run a focused code example           | [docs/examples/](../docs/examples/)                                               |
| Run the prototype                    | [prototype/README.md](../prototype/README.md)                                     |
| Read the prototype documentation     | [docs/04-prototype/](../docs/04-prototype/)                                       |
| Find all sources and further reading | [docs/99-resources/01-resources.md](../docs/99-resources/01-resources.md)         |

---

<sub>Back to the Top | [README](../README.md)</sub>
