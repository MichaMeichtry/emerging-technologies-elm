# When Elm Is Not a Good Choice

The same properties that make Elm a strong fit in the right context become genuine blockers in others. This is not a list of weaknesses to apologise for. It is the cost side of the same trade-offs documented across the comparison section, applied to the situations where those costs are not justified by the benefits Elm provides in return.

A technology that is honest about where it does not fit is more useful than one that claims universal applicability.

---

## Projects Requiring Heavy Third-Party JavaScript Library Integration

The [comparison with JavaScript](02-elm-vs-javascript.md) and the [comparison with TypeScript frameworks](03-elm-vs-typescript-frameworks.md) both identified JavaScript interoperability as the most concrete practical difference between Elm and its alternatives. Elm communicates with JavaScript exclusively through ports. Every interaction with a browser API, a third-party library, or any code outside Elm's type system requires a declared port on the Elm side and a subscriber on the JavaScript side.

[Example 04](../examples/04-ports-localstorage/README.md) demonstrates this cost directly. Persisting a string to `localStorage`, a single line in JavaScript, requires a port declaration, a JavaScript subscriber, a `Msg` variant, and a branch in `update`. That overhead is manageable for occasional interactions with the outside world. It becomes a serious constraint for applications that depend on frequent or deep integration with JavaScript libraries, such as rich text editors, charting libraries, drag-and-drop frameworks, or map rendering tools.

The [comparison with ReScript](04-elm-vs-other-functional-options.md) made this distinction precise. ReScript allows direct JavaScript calls through `external` declarations, meaning any npm package is accessible with a single binding. For applications where the JavaScript ecosystem is a dependency rather than an occasional integration point, that difference in interoperability is not a minor inconvenience but a fundamental architectural constraint.

If a significant portion of the application's functionality depends on third-party JavaScript libraries that Elm does not natively support, the port overhead will accumulate to the point where the development model works against the application rather than for it.

---

## Teams or Organisations Where Hiring From an Existing Pool Is a Constraint

The team suitability findings across all three comparison files arrived at the same conclusion. Elm developers are rare. The Stack Overflow Developer Survey 2024 placed Elm's usage at 1.4% of respondents. Most teams adopting Elm will need to train developers from scratch, and most job postings looking for Elm experience will draw from a narrow pool.

For organisations where the ability to hire quickly matters, whether due to growth, turnover, or the need to scale a team on short notice, this is a concrete constraint rather than an abstract risk. React with TypeScript was used by 39.5% of respondents in 2024 and 44.7% in 2025 according to the [Stack Overflow Developer Survey](../99-resources/01-resources.md). The difference in available talent between the two technologies is not marginal.

The onboarding cost compounds this. A developer joining an Elm project without a functional programming background needs to learn TEA, the type system, and a syntax that differs substantially from JavaScript before they can contribute meaningfully. The bounded language surface makes that learning finite, but the initial investment is real and cannot be compressed below a certain threshold regardless of the developer's experience level.

For teams that need to onboard developers quickly, maintain a broad hiring pool, or operate in environments where specialist knowledge is a staffing risk, the practical constraints around Elm's adoption outweigh its technical benefits.

---

## Projects with Short Timelines or Rapid Prototyping Requirements

The [comparison with JavaScript](02-elm-vs-javascript.md) established that JavaScript allows rapid prototyping. There is no compilation step, no type annotations to write, and no architecture to adopt before producing a working result. The [comparison with React and TypeScript](03-elm-vs-typescript-frameworks.md) made the same point: Create React App and Vite provide working scaffolding in minutes, and the component model makes it straightforward to build something visible quickly.

Elm front-loads its costs. A developer who does not yet know TEA cannot write meaningful Elm code before understanding the pattern. A developer who does know TEA still needs to define types, write decoders for any external data, and work within the architecture before the application does anything useful. These are not avoidable steps, they are the entry price.

For short-lived projects, throwaway prototypes, or proof-of-concept work where the goal is to produce something quickly and discard it, that entry price does not pay for itself. The reliability guarantees Elm provides are most valuable in applications that will run in production for a significant time. A prototype that will be rewritten has no long-term maintenance burden to protect against.

---

## Applications Driven Heavily by Browser APIs or Native JS Behaviour

Certain categories of application depend on browser APIs that Elm does not natively support and that require ports to access. File system access, clipboard operations, WebSockets, WebGL, audio processing, and direct DOM manipulation all fall outside what Elm's standard packages cover. Each one requires the port infrastructure described in [Example 04](../examples/04-ports-localstorage/README.md), replicated for every API the application needs.

This is distinct from third-party library integration. The concern here is not npm packages but native browser capabilities that JavaScript accesses directly and Elm accesses only through a declared boundary. For a content editing application, a media processing tool, a game, or any application whose core functionality is built on browser APIs, the cumulative port overhead becomes the dominant architectural fact of the project.

The [comparison with ReScript](04-elm-vs-other-functional-options.md) noted that ReScript's direct FFI makes it a more practical choice precisely in these scenarios. The [comparison with JavaScript](02-elm-vs-javascript.md) put it plainly: JavaScript can call any browser API directly, with no protocol and no overhead. For applications where that directness is not an occasional convenience but a fundamental requirement, Elm is not the right tool.

---

## Large Teams With Mixed Backgrounds and No Appetite for a Learning Investment

The admiration data from the Stack Overflow Developer Survey 2024 showed that 52.4% of developers who had used Elm wanted to continue using it. That figure reflects developers who had already committed to learning it. It says nothing about the experience of developers who are required to use it without that commitment.

Elm enforces a single architecture and a strict type system. For a developer who understands and values those constraints, they are productive guardrails. For a developer who is unfamiliar with functional programming and has not chosen to adopt Elm, the same constraints read as obstacles. The compile errors that guide an experienced Elm developer through a refactor can be demoralising to a developer encountering the type system for the first time under deadline pressure.

Large teams with mixed experience levels, high turnover, or no organisational investment in a structured learning program are likely to find that Elm's constraints generate friction rather than clarity. The [comparison with React and TypeScript](03-elm-vs-typescript-frameworks.md) noted that React's large hiring pool and extensive documentation make it easier to bring new developers up to speed quickly, even if the resulting codebase is less architecturally consistent. For teams where speed of onboarding is the primary constraint, that trade-off works in React's favour.

---

## Summary

| Condition                                                                   | Why Elm does not fit                                                                    |
| --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| Application depends heavily on third-party JavaScript libraries             | Port overhead accumulates to the point of working against the application               |
| Organisation needs to hire from a broad talent pool                         | Elm usage at 1.4% means the available pool is narrow and onboarding is slow             |
| Short timeline or throwaway prototype                                       | Front-loaded costs do not pay for themselves without a long-term maintenance benefit    |
| Application built primarily on browser APIs outside Elm's standard packages | Every native API requires port infrastructure, which compounds across the application   |
| Large team with mixed backgrounds and no structured learning investment     | Enforced constraints generate friction for developers who have not chosen to adopt them |

None of these are arguments that Elm is poorly designed. They are the natural consequence of a language that optimises for a specific set of properties. The constraints that eliminate runtime errors and enforce architectural consistency are the same constraints that make JavaScript interop verbose and onboarding slow. Recognizing where those constraints are a poor fit is part of evaluating the technology honestly.

---

<sub>Previous | [When Elm Is a Good Choice](05-when-elm-is-a-good-choice.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [Summary](07-summary.md)</sub>
