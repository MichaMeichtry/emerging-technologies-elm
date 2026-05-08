# Comparison Summary

The comparison section set out to answer one question: compared to the technologies a developer would realistically consider for a browser-based frontend application, when does Elm's approach make sense, and when does it not?

To answer that, six comparisons were made across a consistent set of criteria - type safety, runtime error prevention, architecture, learning curve, ecosystem, JavaScript interoperability, team suitability, and development speed.

---

## Comparisons Carried Out

| File                                                                           | What it covers                                |
| ------------------------------------------------------------------------------ | --------------------------------------------- |
| [01 - Comparison Overview](01-comparison-overview.md)                          | Criteria and technologies considered          |
| [02 - Elm vs. JavaScript](02-elm-vs-javascript.md)                             | Elm compared to plain JavaScript              |
| [03 - Elm vs. TypeScript Frameworks](03-elm-vs-typescript-frameworks.md)       | Elm compared to React and Vue with TypeScript |
| [04 - Elm vs. Other Functional Options](04-elm-vs-other-functional-options.md) | Elm compared to ReScript and PureScript       |
| [05 - When Elm Is a Good Choice](05-when-elm-is-a-good-choice.md)              | Scenarios where Elm is a strong fit           |
| [06 - When Elm Is Not a Good Choice](06-when-elm-is-not-a-good-choice.md)      | Scenarios where Elm is not the right tool     |

---

## Where Each Technology Stands

| Technology         | Type safety                | Runtime errors          | Architecture              | Ecosystem       | JS interop         | Team suitability              |
| ------------------ | -------------------------- | ----------------------- | ------------------------- | --------------- | ------------------ | ----------------------------- |
| JavaScript         | None                       | Common class of errors  | None enforced             | Very large      | Direct             | Universal                     |
| TypeScript         | Partial, opt-out available | Reduced, not eliminated | None enforced             | Very large      | Direct             | Very common                   |
| React + TypeScript | Partial, opt-out available | Reduced, not eliminated | None enforced             | Very large      | Direct             | Large hiring pool             |
| Vue + TypeScript   | Partial, opt-out available | Reduced, not eliminated | Conventions, not enforced | Large           | Direct             | Good hiring pool              |
| ReScript           | Very high, seam at JS FFI  | Eliminated in pure code | None enforced             | Full npm access | Direct via FFI     | Easier with React background  |
| PureScript         | Maximum, Haskell-style     | Eliminated in pure code | None enforced             | Small           | Two-file FFI       | Rare in commercial use        |
| Elm                | Full, no opt-out           | Eliminated by design    | TEA enforced              | Small, curated  | Through ports only | Specialist knowledge required |

---

## The Pattern That Emerges

Elm is the only language in this comparison where the type system has no escape hatch, the architecture is not a choice, and the guarantee of no runtime errors is unconditional rather than dependent on configuration or discipline. Every other option on the list involves a trade-off between flexibility and coverage - TypeScript lets a developer use `any`, React leaves architecture to the team, ReScript trusts the developer to type JavaScript bindings correctly. Elm removes those choices entirely.

The cost of that removal is consistent across every comparison: a smaller ecosystem, a more verbose path to JavaScript integration, and a narrower pool of developers with existing experience. These are not incidental drawbacks - they follow directly from the same design decisions that produce the guarantees.

---

## Adoption vs. Admiration

The Stack Overflow Developer Survey 2024 captures Elm's position more precisely than any comparison criterion can.

![Stack Overflow Developer Survey 2024 - Elm admired at 52.4% versus desired at 1.4%](../images/stackoverflow-dev-survey-2024.png)
<sub>(Note: this image has intentionally been cropped to only include the top and bottom parts of the survey. For the full graphic, follow the source)</sub>

Elm was used by 1.4% of respondents - a figure that reflects the upfront cost documented across the comparison section. Among those who had used it, 52.4% said they wanted to continue, placing it among the most admired frameworks in the survey. The gap between those two numbers is the trade-off in data form: the cost is real and front-loaded, and the value is real but only visible after it has been paid.

---

## When Elm Fits and When It Does Not

| Elm tends to fit well when                                                     | Elm tends to fit poorly when                                                       |
| ------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- |
| The application has complex, long-lived UI state that must remain predictable  | The application depends heavily on third-party JavaScript libraries                |
| Reliability matters more than flexibility and runtime errors have a real cost  | The project timeline does not allow for a front-loaded learning investment         |
| The team is prepared to invest in a defined learning period                    | The organisation needs to hire quickly from a broad talent pool                    |
| Architectural consistency across contributors matters more than hiring breadth | The application is built primarily on browser APIs outside Elm's standard packages |
| The project has an educational or architecture-driven goal                     | The team has mixed backgrounds with no appetite for adopting a new paradigm        |

For the full reasoning behind each of these conditions, see [When Elm Is a Good Choice](05-when-elm-is-a-good-choice.md) and [When Elm Is Not a Good Choice](06-when-elm-is-not-a-good-choice.md).

---

## Reading the Trade-off

The comparisons do not produce a verdict. They produce a set of conditions. No technology in this comparison is universally better - each one reflects a different answer to the same underlying question: what is the acceptable cost for the guarantees you want?

Elm's answer is the most explicit. It trades flexibility, ecosystem breadth, and interoperability for correctness guarantees that are unconditional. Whether that trade is worth making depends entirely on what the project actually needs.

---

<sub>Previous | [When Elm Is Not a Good Choice](06-when-elm-is-not-a-good-choice.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [Prototype Overview](../04-prototype/01-prototype-overview.md)</sub>
