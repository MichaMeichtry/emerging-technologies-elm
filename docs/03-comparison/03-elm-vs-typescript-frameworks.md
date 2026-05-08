# Elm vs. TypeScript Frameworks

React with TypeScript is a dominant combination for building frontend applications in the industry. Vue with TypeScript occupies a similar space with a different set of trade-offs. Both use TypeScript as an opt-in type layer on top of JavaScript. Elm takes a different position entirely: it is a separate language with a type system that is non-optional and structurally different from TypeScript's.

This comparison focuses on React with TypeScript as the primary subject. Vue with TypeScript is covered in a shorter section at the end. The criteria used here match those defined in the [Comparison Overview](01-comparison-overview.md).

---

## Elm vs. React + TypeScript

### Type Safety

TypeScript adds static typing to JavaScript, but the type system is opt-in and has intentional escape hatches. A developer can use `any` to bypass type checking entirely, cast values with `as`, or leave large portions of a codebase untyped [1]. Even a well-typed TypeScript codebase can have runtime failures that the type system did not catch, because TypeScript types are erased at compile time and do not constrain runtime behaviour.

```typescript
// TypeScript allows explicit escape hatches
function getTicketStatus(ticket: any): string {
  return ticket.status; // no type checking, compiles without error
}

// Type assertions can override the compiler's judgment
const status = (someValue as Ticket).status; // trusted at face value
```

Elm has no equivalent escape hatches. There is no `any` type, no type assertion, and no way to tell the compiler to skip checking a value. Every value in an Elm program has a known, compiler-verified type [2].

```elm
-- The compiler infers or checks every expression.
-- There is no way to mark a value as untyped.
getTicketStatus : Ticket -> TicketStatus
getTicketStatus ticket =
    ticket.status
-- Using ticket.status as a String where TicketStatus is expected
-- is a compile error, not a runtime failure.
```

TypeScript's type system is structurally typed. In a structural type system, the compiler checks whether a value has the right shape - the right fields with the right types - regardless of what name or declaration it came from. If two types have identical structures, they are considered interchangeable. In a nominal type system, the name of the type is what matters: two types declared separately are distinct even if their fields are identical [10].

```typescript
// TypeScript: structural typing - these two types are interchangeable
// because they have the same shape
type Ticket = { id: number; title: string; status: string };
type Note = { id: number; title: string; status: string };

function renderTicket(t: Ticket): string {
  return t.title;
}

const note: Note = { id: 1, title: "follow up", status: "open" };
renderTicket(note); // compiles without error - same shape, treated as compatible
```

Elm's custom types use nominal typing. `TicketStatus` and `Priority` are distinct types even if they happened to share the same set of variants - the compiler distinguishes them by their declared names, not their contents. This means accidentally passing a `Priority` value where a `TicketStatus` is expected is always a compile error, regardless of any structural similarity.

```elm
-- Elm: nominal typing - Open used as TicketStatus vs. Priority would be
-- separate declarations; the compiler tracks them by name, not shape.
-- Passing the wrong custom type to a function is a compile error.
changeStatus : Int -> TicketStatus -> Model -> Model
changeStatus id newStatus model =
    -- passing a Priority value here is rejected by the compiler
    -- even if Priority happened to have variants with the same names
```

For TypeScript to approach Elm's level of coverage, a team needs explicit discipline: banning `any`, configuring strict mode, avoiding type assertions, and enforcing these rules consistently across contributors [1]. Elm provides these guarantees without requiring that discipline, because the compiler enforces them unconditionally.

### Runtime Error Prevention

TypeScript catches a large class of errors at compile time, but a number of runtime failures remain possible. The most common are null and undefined references: TypeScript's strict null checking helps, but values arriving from external sources (API responses, localStorage, third-party libraries) are often typed as `unknown` or `any` and require manual narrowing before use.

```typescript
// Without strict null checks, this compiles but crashes at runtime
function renderAssignee(ticket: Ticket): string {
  return ticket.assignedTo.toUpperCase(); // crashes if assignedTo is null
}

// With strict null checks, the developer must handle the absence explicitly
function renderAssignee(ticket: Ticket): string {
  if (ticket.assignedTo !== null && ticket.assignedTo !== undefined) {
    return ticket.assignedTo.toUpperCase();
  }
  return "Unassigned";
}
```

TypeScript also does not verify exhaustiveness of `switch` statements on union types by default. A developer must opt into exhaustiveness checking using a `never` pattern or a third-party utility [3].

```typescript
// TypeScript does not warn about missing cases unless configured to do so
function statusLabel(status: TicketStatus): string {
  switch (status) {
    case "Open":
      return "Open";
    case "InProgress":
      return "In Progress";
    case "Resolved":
      return "Resolved";
    // "Closed" is missing - TypeScript may return undefined silently
  }
}
```

Elm eliminates this class of problem structurally. The `Maybe` type makes absent values explicit in the type signature, and pattern matching on custom types is exhaustive by requirement of the compiler [2].

```elm
-- The compiler rejects this unless all TicketStatus variants are covered.
statusLabel : TicketStatus -> String
statusLabel status =
    case status of
        Open       -> "Open"
        InProgress -> "In Progress"
        Resolved   -> "Resolved"
        Closed     -> "Closed"

-- Elm's Maybe makes the absent case explicit in the type.
renderAssignee : Ticket -> String
renderAssignee ticket =
    case ticket.assignedTo of
        Just name -> String.toUpper name
        Nothing   -> "Unassigned"
```

The practical difference is that Elm's guarantees are automatic. TypeScript's coverage depends on compiler settings, team conventions, and consistent enforcement.

### Architecture and State Management

React imposes no architecture. It is a UI rendering library, not a framework for managing application state [4]. State management is the developer's responsibility. The options range from component-local `useState`, to context-based shared state, to external libraries. Each has different rules, different trade-offs, and different learning curves. A React codebase can use multiple approaches simultaneously.

```typescript
// React state can live in components, context, or external stores.
// There is no single right answer, and the choice changes between projects.
const [tickets, setTickets] = useState<Ticket[]>([]);
const [filter, setFilter] = useState<FilterState>("All");

// A status change can be triggered from anywhere that has access to setTickets.
const changeStatus = (id: number, newStatus: TicketStatus) => {
  setTickets((prev) =>
    prev.map((t) => (t.id === id ? { ...t, status: newStatus } : t)),
  );
};
```

This flexibility is useful when an application has genuinely different state requirements across sections. It becomes a maintenance problem when the team has not agreed on a consistent approach, when new contributors make different choices, or when tracing why the UI is in a particular state requires understanding multiple state systems.

Elm enforces The Elm Architecture (TEA) on every application, with no alternative [2]. All state lives in one `Model`. All changes go through one `update` function. The `view` is a pure function of the model. There is exactly one place to look for any state change.

```elm
-- In Elm, the state management structure is not a choice.
-- Every application looks like this.
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeStatus id newStatus ->
            let
                updateTicket ticket =
                    if ticket.id == id then
                        { ticket | status = newStatus }
                    else
                        ticket
            in
            ( { model | tickets = List.map updateTicket model.tickets }
            , Cmd.none
            )

        SetFilter filter ->
            ( { model | filter = filter }, Cmd.none )
```

For a ticket system with multiple state concerns - ticket list, active filter, search query, selected ticket, form state - TEA keeps every concern in one place and every change traceable to one function.

### Learning Curve

React with TypeScript is one of the most widely taught frontend stacks. There is an extensive body of tutorials, courses, documentation, and community support [4]. Most frontend developers entering the field today encounter React early, which lowers the initial barrier significantly.

The learning surface is large, however. React itself requires understanding hooks, component lifecycle, rendering behaviour, and reconciliation. TypeScript adds type annotations, generics, and configuration. State management libraries add their own APIs and mental models. A developer can be productive in React with TypeScript quickly, but mastering the full ecosystem takes considerably longer.

Elm has a narrower but steeper initial learning curve. The functional style, the type system, and TEA are unfamiliar to developers coming from imperative or object-oriented backgrounds. The Elm guide is the primary learning resource [2], and the ecosystem around it is smaller. The initial productivity dip is real.

Once past the initial barrier, Elm's surface area stabilises. There are no additional state management libraries to evaluate, no competing patterns for organising code, and no configuration options for the type system. The compiler's error messages are notably specific and actionable [5], which makes the learning process more guided than in TypeScript, where errors can be harder to interpret.

### Ecosystem and Library Availability

React's ecosystem is one of the largest frontend framework. Component libraries, animation tools, data visualisation packages, form libraries, routing solutions, and integrations with virtually every third-party service are available as maintained npm packages [4]. The package count is not just large, many of the packages are mature, well-documented, and used in production at scale.

Elm's package registry contains several hundred packages [6]. The scope is smaller, and some categories that are well-covered in React have limited or no equivalent in Elm. UI component libraries in particular are sparse compared to what is available for React.

The quality signal works differently, however. Elm packages are published with enforced semantic versioning: the compiler verifies that a major version bump accompanies any breaking API change [2]. In the npm ecosystem, packages can introduce breaking changes in minor versions, and the registry contains a high volume of abandoned or low-quality packages alongside the well-maintained ones. The Elm registry is smaller but more uniform in its guarantees.

For applications that depend heavily on third-party React components or JS integrations, Elm's ecosystem is a genuine constraint. For applications whose logic can be expressed in Elm directly, the smaller registry is less limiting.

### JavaScript Interoperability

React components are JavaScript (or TypeScript). Calling a JavaScript library, a browser API, or a third-party package is direct. There is no protocol, no boundary, and no overhead.

```typescript
// Calling a JS library from React is direct.
import Sortable from "sortablejs";

useEffect(() => {
  Sortable.create(listRef.current, { animation: 150 });
}, []);
```

Elm communicates with JavaScript only through ports [2]. Every interaction with the outside world requires a declared port on the Elm side and a subscriber on the JavaScript side. The boundary is explicit by design. It is what allows Elm to maintain its no-runtime-errors guarantee even when the application integrates with untyped code.

```elm
-- Elm side: declare an outgoing port
port saveFilter : String -> Cmd msg
```

```javascript
// JavaScript side: subscribe to the port
app.ports.saveFilter.subscribe(function (filter) {
  localStorage.setItem("ticket-filter", filter);
});
```

See [Example 04 - Ports and localStorage](../../docs/examples/04-ports-localstorage/README.md) for a full working demonstration of this pattern.

The cost is verbosity. A one-line JavaScript operation requires a port declaration, a JS subscriber, a `Msg` variant, and an `update` branch in Elm. For applications that require frequent interaction with JS libraries or browser APIs not covered by Elm's standard packages, this overhead accumulates.

### Team Suitability

React with TypeScript is the most commonly used frontend stack in the industry. According to the Stack Overflow Developer Survey, React was used by 39.5% of all respondents in 2024 and 44.7% in 2025, making it the most widely adopted web framework in both years. TypeScript itself was used by approximately 38% of respondents in 2024 and 43.6% in 2025 [7]. The hiring pool is large, onboarding is fast for most experienced frontend developers, and code review requires no specialist knowledge beyond the project's own conventions.

Elm developers are rare. Most teams adopting Elm will need to train developers from scratch. The onboarding cost is real, and the hiring pool for developers with existing Elm experience is narrow. However, because Elm's language surface is small and intentionally approachable [5], a motivated developer with a functional programming background can become productive in weeks rather than months.

The structural constraint also has a team benefit. Because all Elm applications follow TEA, a developer familiar with the pattern can read any Elm codebase and understand its structure immediately. In React, the same is not true, state management approaches, component patterns, and folder structures vary significantly between teams.

### Development Speed

React with TypeScript allows fast initial setup. Create React App and Vite provide working scaffolding in minutes, and the component model makes it straightforward to build a visible result quickly [4]. For short-lived projects or prototypes, this advantage is significant.

For larger or longer-lived applications, the trade-off shifts. React's flexibility means architectural decisions are deferred, and those decisions eventually need to be made or revisited. TypeScript configuration gaps and runtime errors surface over time. Refactoring is less safe than in Elm, because the type system does not cover all failure cases.

Elm's initial setup requires understanding TEA before writing any meaningful code. This front-loads the learning investment. Once the pattern is understood, however, Elm's compiler-guided development tends to accelerate: a compiling Elm program has an entire class of bugs structurally ruled out [2], and refactoring across a large codebase is safer because the compiler reports every affected location when a type or function signature changes.

---

## Elm vs. Vue + TypeScript

Vue with TypeScript occupies a similar position to React with TypeScript. The same type-system trade-offs apply: TypeScript adds optional static typing on top of JavaScript, with the same escape hatches and the same reliance on team discipline to enforce coverage.

Vue has a more opinionated structure than React. The Composition API and Options API provide defined patterns for organising component logic, and Vue's single-file component format keeps template, script, and styles co-located [8]. This makes Vue codebases more consistent across teams than React codebases, without going as far as TEA's enforcement.

Vue's ecosystem is smaller than React's but larger than Elm's. Vue was used by 15.4% of respondents in 2024 and 17.6% in 2025 [11]. The community is active, documentation is thorough, and component libraries like Vuetify and PrimeVue provide extensive UI coverage [8].

The learning curve for Vue with TypeScript is generally considered gentler than React with TypeScript [9]. Vue's template syntax is closer to HTML, the reactivity model is more intuitive for developers coming from a traditional web background, and TypeScript integration in Vue 3 is tighter than in earlier versions.

Compared to Elm, Vue with TypeScript shares the same fundamental characteristics as React with TypeScript: optional typing, no enforced architecture at the language level, a much larger ecosystem, and direct JavaScript interoperability. Where Vue differs from React, the differences are in ergonomics and conventions, not in the structural guarantees Elm provides.

---

## Overall Assessment

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

React and Vue with TypeScript offer a practical middle ground: a large ecosystem, direct JavaScript interoperability, and a type system that reduces errors without imposing hard constraints. The guarantees are conditional on team discipline and consistent configuration.

Elm offers harder guarantees: no runtime errors by design, a type system with no escape hatches, and an architecture that is uniform across every application - at the cost of a smaller ecosystem, more verbose JavaScript integration, and a narrower hiring pool.

The comparison does not produce a universal winner. It produces a set of trade-offs that are more or less acceptable depending on the project's requirements, the team's familiarity with functional programming, and the value placed on correctness versus flexibility.

For a full picture of where these trade-offs favour Elm and where they do not, see:

- [When Elm Is a Good Choice](05-when-elm-is-a-good-choice.md)
- [When Elm Is Not a Good Choice](06-when-elm-is-not-a-good-choice.md)

---

## Sources

[1] TypeScript documentation - TypeScript for JavaScript Programmers. https://www.typescriptlang.org/docs/handbook/typescript-in-5-minutes.html

[2] Evan Czaplicki - An Introduction to Elm. https://guide.elm-lang.org/

[3] TypeScript documentation - Narrowing. https://www.typescriptlang.org/docs/handbook/2/narrowing.html

[4] React documentation - Quick Start. https://react.dev/learn

[5] Marcio Frayze - Why is Elm such a delightful programming language? https://dev.to/marciofrayze/why-is-elm-such-a-delightful-programming-language-2em8

[6] Elm Package Registry. https://package.elm-lang.org/

[7] Stack Overflow Developer Survey 2024 - Most popular web frameworks and languages. https://survey.stackoverflow.co/2024/technology

[8] Vue documentation - Introduction. https://vuejs.org/guide/introduction.html

[9] Sam Ritchie - The Case for Elm. https://samritchie.net/posts/the-case-for-elm/

[10] Jamie Kyle - Type Systems: Structural vs. Nominal typing explained. https://medium.com/@thejameskyle/type-systems-structural-vs-nominal-typing-explained-56511dd969f4

[11] Stack Overflow Developer Survey 2025 - Most popular web frameworks and languages. https://survey.stackoverflow.co/2025/technology

---

<sub>Previous | [Elm vs JavaScript](02-elm-vs-javascript.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [Elm vs. Other Functional Options](04-elm-vs-other-functional-options.md)</sub>
