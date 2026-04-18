# Elm vs JavaScript

JavaScript is the default language of the web. Every browser runs it natively, no build step is required, and every frontend developer already knows it. Elm compiles to JavaScript [1], which means it targets the same environment but makes fundamentally different choices about how that environment should be used.

This comparison focuses on plain JavaScript - no frameworks, no TypeScript. That baseline makes the contrast with Elm clearest. The criteria used here match those defined in the [Comparison Overview](01-comparison-overview.md).

---

## Type Safety

JavaScript has no static type system. Variables can hold any value at any time, function arguments are not checked, and there is nothing preventing a caller from passing the wrong type to a function. Errors caused by type mismatches only appear at runtime, and only if the code path that triggers them is actually executed.

```javascript
function getTicketTitle(ticket) {
  return ticket.title.toUpperCase();
}

getTicketTitle(null);
// TypeError at runtime: Cannot read properties of null
// This error only surfaces when the function is actually called with null
```

Elm has a static type system that covers the entire language. Every value has a known type and the compiler rejects programs where types do not match. The equivalent error in Elm is caught before the application runs.

```elm
getTicketTitle : Ticket -> String
getTicketTitle ticket =
    String.toUpper ticket.title
-- passing the wrong type here is a compile error, not a runtime crash
-- the compiler reports the mismatch before the program can run
```

There is no opt-out in Elm. Every value in an Elm program is type-checked. This is a deliberate constraint, the guarantee of no runtime type errors only holds if it is universal [2].

---

## Runtime Error Prevention

Several categories of JavaScript error appear repeatedly in real-world applications [3, 4]:

- `TypeError: Cannot read properties of undefined`
- `TypeError: x is not a function`
- Silent `NaN` propagation through arithmetic
- Missing `case` branches that fall through silently
- Unhandled `null` references

Consider a realistic example. A ticket system needs to display the assigned agent's name. In JavaScript, the field might be absent:

```javascript
// assignedTo may be null or undefined at runtime
function renderAssignee(ticket) {
  return ticket.assignedTo.toUpperCase(); // crashes if assignedTo is null
}

// a defensive version requires the developer to remember to check every time
function renderAssignee(ticket) {
  if (ticket.assignedTo !== null && ticket.assignedTo !== undefined) {
    return ticket.assignedTo.toUpperCase();
  }
  return "Unassigned";
}
```

In Elm, the optional field is modelled as `Maybe String`. The compiler will not allow `assignedTo` to be used as a plain `String` without first handling the `Nothing` case:

```elm
-- the type system makes the optional nature of assignedTo explicit
renderAssignee : Ticket -> String
renderAssignee ticket =
    case ticket.assignedTo of
        Just name ->
            String.toUpper name

        Nothing ->
            "Unassigned"
-- forgetting the Nothing branch is a compile error
-- the developer cannot accidentally skip the absent case
```

The same principle applies to exhaustive pattern matching on custom types. In the ticket system, every possible status must be handled wherever `TicketStatus` is pattern matched:

```javascript
// a new status added later may silently produce undefined behaviour
function statusLabel(status) {
  switch (status) {
    case "open":
      return "Open";
    case "inProgress":
      return "In Progress";
    case "resolved":
      return "Resolved";
    // forgetting "closed" produces no warning - the function returns undefined
  }
}
```

```elm
-- adding a new TicketStatus variant without updating this function
-- is a compile error reported at every pattern match that is missing the case
statusLabel : TicketStatus -> String
statusLabel status =
    case status of
        Open       -> "Open"
        InProgress -> "In Progress"
        Resolved   -> "Resolved"
        Closed     -> "Closed"
```

Elm programs can still have logic errors, but the entire class of errors caused by missing null checks, wrong types, and unhandled cases is structurally prevented [2].

---

## Architecture and State Management

JavaScript imposes no structure on how state is managed. An application can mix global variables, local state, DOM mutation, and event listeners in any combination. This works well for small scripts but becomes a maintenance problem as an application grows. Understanding why the UI is in a particular state often requires tracing mutations across multiple files.

```javascript
// state can live anywhere and be mutated from anywhere
let tickets = [];
let filterState = "all";

function addTicket(ticket) {
  tickets.push(ticket); // direct mutation
  renderTicketList(); // manually triggering a re-render
}

function setFilter(filter) {
  filterState = filter; // another mutation elsewhere
  renderTicketList();
}
```

Elm enforces The Elm Architecture on every application [2]. All state lives in one `Model`. All state changes go through one `update` function. The `view` is a pure function of the model. There is no other way to write an Elm application.

```elm
-- state can only change through the update function
-- the compiler enforces this structure at every level
update : Msg -> Model -> Model
update msg model =
    case msg of
        AddTicket ticket ->
            { model | tickets = ticket :: model.tickets }

        SetFilter filter ->
            { model | filter = filter }
```

This constraint means that to understand how the application state changes, there is exactly one place to look.  
The data flow is always: user action produces a `Msg`, `update` produces a new `Model`, `view` renders it. This predictability is valuable in team environments and in long-lived codebases.

---

## Learning Curve

JavaScript is one of the most widely known programming language. Most developers entering frontend work already have some familiarity with it. The initial barrier is low. A script tag and a few lines are enough to produce a working result.

Elm requires learning functional programming, a static type system, and a fixed architecture simultaneously. Most web developers come from an imperative programming background, where code describes step-by-step instructions that change program state [9], which makes Elm's declarative, expression-based style unfamiliar at first. The syntax reflects this difference and takes time to read fluently. The initial setup also requires installing the Elm compiler and understanding the build process.

The learning investment is front-loaded. Once a developer understands the type system and TEA, the language surface area does not grow. Elm has no inheritance, no implicit conversions, no exceptions, and no mutation. The things that need to be learned are finite, and the compiler guides the developer through mistakes with specific, actionable error messages [5]. Developers familiar with other functional languages tend to find Elm unusually approachable compared to alternatives like Haskell or PureScript, precisely because of this limited surface area [5].

---

## Ecosystem and Library Availability

JavaScript has the largest library ecosystem of any language. As of 2022, the npm registry contained over 2.1 million packages, making it the biggest single-language code repository in existence [6]. Nearly every API integration, UI component, and tool has a JavaScript package available.

Elm's package registry contains several hundred packages [7]. Every published Elm package is guaranteed to follow semantic versioning enforced by the compiler. A major version bump is required whenever a breaking change is introduced, and the tooling verifies this automatically. There are no packages that silently break on update.

For projects that depend heavily on third-party JavaScript libraries, the small Elm ecosystem is a real constraint. For projects whose logic can be expressed in Elm directly, the smaller but more reliable ecosystem is less of a problem.

---

## JavaScript Interoperability

JavaScript can call any browser API, any third-party library, and any native function directly. There are no boundaries involved.

Elm communicates with JavaScript exclusively through ports [2]. A port is a declared, typed channel that passes values between Elm and JavaScript. Calling a JavaScript library from Elm requires a port declaration on the Elm side and a subscriber on the JavaScript side.

```elm
-- Elm side: declare the outgoing port
port saveNote : String -> Cmd msg
```

```javascript
// JavaScript side: subscribe to the port
app.ports.saveNote.subscribe(function (note) {
  localStorage.setItem("elm-note", note);
});
```

See [Example 04 - Ports and localStorage](../../docs/examples/04-ports-localstorage/README.md) for a complete working demonstration of this pattern.

This boundary is intentional. Elm cannot guarantee no runtime errors if arbitrary JavaScript can affect its state directly. Ports are the mechanism that keeps the guarantee intact while still allowing integration with the outside world [2].

The cost is verbosity. Something that takes one line in JavaScript requires a port declaration, a JS subscriber, a `Msg` variant, and an `update` branch in Elm. Whether that cost is acceptable depends on how much JavaScript interoperability the project requires [8].

---

## Team Suitability

Every frontend developer knows JavaScript. Finding developers, onboarding new team members, and reviewing code requires no specialist knowledge.

Elm developers are rare. Most teams adopting Elm will need to train developers who have no prior exposure to functional programming or static typing. However, because Elm's language surface is small and intentionally beginner-friendly, onboarding a motivated developer is more feasible than it might seem [8]. The harder challenge is hiring. The pool of developers with existing Elm experience is narrow, and most job postings looking for Elm expertise go unfilled for longer than equivalent JavaScript or TypeScript roles [5].

---

## Development Speed

JavaScript allows rapid prototyping. There is no compilation step, no type annotations to write, and no architecture to follow. For small scripts or quick experiments, JavaScript produces results faster than Elm.

For larger applications, the trade-off shifts. JavaScript's lack of structure means that as an application grows, more time is spent debugging runtime errors and tracing state mutations. Elm's compiler acts as a continuous check: a program that compiles has an entire class of bugs ruled out. Refactoring in Elm is safer because the compiler reports every affected location when a type or function signature changes [2].

---

## Overall Assessment

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

JavaScript and Elm represent opposite ends of a spectrum between flexibility and correctness. JavaScript optimises for getting something working quickly with minimal constraints. Elm optimises for building something that stays correct as it grows.

Although Elm offers advantages over JavaScript, such as type safety, the absence of runtime errors and enforced architecture, these benefits come at the cost of a steeper learning curve, a smaller ecosystem and more complex interoperability. These drawbacks are tangible and immediate. However, the benefits are most evident in larger applications that are maintained over time.

For a full picture of where these trade-offs favour Elm and where they do not, see:

- [When Elm Is a Good Choice](05-when-elm-is-a-good-choice.md)
- [When Elm Is Not a Good Choice](06-when-elm-is-not-a-good-choice.md)

---

## Sources

[1] Elm Language - What is Elm? https://elm-lang.org/

[2] Evan Czaplicki - An Introduction to Elm. https://guide.elm-lang.org/

[3] Codenova - The 10 Most Common JavaScript Issues Developers Face. https://medium.com/@codenova/the-10-most-common-javascript-issues-developers-face-4f56d90b979e

[4] jliter - Common JavaScript Mistakes and How to Fix Them. https://dev.to/jliter/common-javascript-mistakes-and-how-to-fix-them-52mc

[5] Marcio Frayze - Why is Elm such a delightful programming language? https://dev.to/marciofrayze/why-is-elm-such-a-delightful-programming-language-2em8

[6] Node.js - An introduction to the npm package manager. https://nodejs.org/learn/getting-started/an-introduction-to-the-npm-package-manager

[7] Elm Package Registry. https://package.elm-lang.org/

[8] Sam Ritchie - The Case for Elm. https://samritchie.net/posts/the-case-for-elm/

[9] Lahiru Rajapakshe - Understanding the Imperative Programming Paradigm in Software Development. https://medium.com/@lahirurajapakshe.stack/understanding-the-imperative-programming-paradigm-in-software-development-ec04a4ee5f02

---

<sub>Previous | [Comparison Overview](01-comparison-overview.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [Elm vs TypeScript Frameworks](03-elm-vs-typescript-frameworks.md)</sub>
