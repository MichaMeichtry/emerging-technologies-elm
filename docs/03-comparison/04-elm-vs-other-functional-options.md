# Elm vs. Other Functional Options

JavaScript and TypeScript are not the only alternatives to Elm for building browser applications with functional programming principles. ReScript and PureScript occupy a related but distinct space. Both compile to JavaScript, both bring stronger type guarantees than TypeScript, and both are aimed at developers who want more correctness than the mainstream ecosystem provides. Understanding where Elm, ReScript, and PureScript differ in practice requires looking at more than just their type systems.

This comparison is structured around the same criteria defined in the [Comparison Overview](01-comparison-overview.md). ReScript receives a fuller treatment because it is the more practically relevant alternative for teams evaluating Elm today. PureScript is covered more concisely, as its primary value is theoretical depth rather than practical adoption.

---

## Elm vs. ReScript

ReScript is a statically typed language that compiles to readable JavaScript. It originated as BuckleScript [2], the JavaScript backend for the OCaml compiler [3], and was rebranded and repositioned in 2020 under the ReScript name [1]. Its type system is derived from OCaml, which is one of the more mature functional type systems in production use. Unlike Elm, ReScript is not limited to browser applications and can be used anywhere JavaScript runs, including Node.js [1].

### Type Safety

Both Elm and ReScript have sound, static type systems with full type inference. Neither requires explicit type annotations for most code, and both catch type errors before the program runs.

The structural difference is in escape hatches. ReScript provides a typed FFI (foreign function interface) that allows calling JavaScript directly from ReScript code. This is more ergonomic than Elm's ports, but it introduces a boundary where the type system's guarantees weaken. The `external` declaration that wires a ReScript function to a JavaScript implementation is typed by the developer, not verified by the compiler [4]. A developer can declare an incorrect type for a JavaScript function and the compiler will accept it.

```elm
-- Elm: no direct JS call is possible from within typed Elm code.
-- All JS interaction goes through ports, which are declared and type-checked
-- on the Elm side, even if the JS side is untyped.
port saveData : String -> Cmd msg
```

```rescript
// ReScript: the external declaration is written by the developer.
// The compiler trusts the declared type without verifying the JS implementation.
// If the actual JS value does not match Dom.Storage.t at runtime, the error
// surfaces at runtime, not at compile time.
@val external localStorage: Dom.Storage.t = "localStorage"
```

Elm's type system covers 100% of Elm code because there is no mechanism to bypass it from within the language. ReScript's coverage is very high for pure ReScript code but has a seam at every JavaScript boundary that depends on developer discipline to type correctly [4].

### Runtime Error Prevention

ReScript eliminates the same broad categories of runtime errors as Elm: no null references within typed code, exhaustive pattern matching on variants, and no implicit type coercions [4]. For applications written entirely in ReScript, the practical safety level is comparable to Elm.

The difference appears in integration scenarios. ReScript's JavaScript interoperability is more direct than Elm's ports, which means values from untyped JavaScript can enter the ReScript type system through an `external` declaration without being explicitly decoded. If the declared type is wrong, the runtime value will not match, and the error surfaces as a runtime failure rather than a compile error.

Consider fetching data from an external API. In ReScript, a developer can bind to `JSON.parse` directly and declare its return type:

```rescript
// ReScript: the return type is declared by the developer, not verified.
// If the actual API response does not match myRecord, the mismatch is a runtime error.
@val external parseJson: string => myRecord = "JSON.parse"
```

Elm requires an explicit decoder that handles the mismatch case structurally:

```elm
-- Elm: the decoder defines exactly what shape is acceptable.
-- A mismatch between the expected and actual JSON structure is a typed error
-- caught at the boundary, not a runtime crash deeper in the application.
ticketDecoder : Decoder Ticket
ticketDecoder =
    Decode.map3 Ticket
        (Decode.field "id" Decode.int)
        (Decode.field "title" Decode.string)
        (Decode.field "status" statusDecoder)
```

Elm's decoder pattern, as demonstrated in [Example 05 - Weather App](../../docs/examples/05-weather-app/README.md), treats all external data as inherently untrustworthy and requires explicit decoding before a value can enter the type system. This is more verbose but structurally safer. A mismatch between the expected and actual shape of external data is always caught at the boundary, never later.

### Architecture and State Management

ReScript does not prescribe an application architecture [4]. It is a language, not a framework. Most ReScript browser applications use ReScript with React (via the `rescript-react` bindings), which means the architecture question for ReScript is substantially the same as for React: flexible, with many valid approaches, and no single enforced pattern.

```rescript
// ReScript with rescript-react: state management follows React patterns.
// There is no enforced structure; useState, useReducer, context, or external
// state libraries are all valid choices and can be combined freely.
@react.component
let make = () => {
  let (tickets, setTickets) = React.useState(() => [])
  let (filter, setFilter) = React.useState(() => "all")
  // state can live in components, context, or wherever the developer decides
}
```

Elm enforces The Elm Architecture on every application without exception. For a team that values architectural consistency across a codebase, Elm's constraint is an advantage. For a team that already has established React patterns and wants to add type safety, ReScript's compatibility with that ecosystem is a practical benefit.

### Learning Curve

ReScript is designed to be approachable for developers familiar with JavaScript and React [1]. Its syntax is closer to JavaScript than Elm's, and the `rescript-react` library maps closely to how React components are written in TypeScript. A developer who knows React can become productive in ReScript more quickly than in Elm, because fewer new concepts are required simultaneously.

Elm requires learning functional programming, a fixed architecture, and a new syntax at the same time. The initial investment is larger. However, Elm's language surface is intentionally small and does not grow. Once The Elm Architecture and the type system are understood, there is nothing further to learn in terms of architecture or language structure.

ReScript's surface area is larger. It inherits OCaml's type system concepts, including parametric polymorphism, variant types, and module signatures, which go beyond what most frontend developers encounter in TypeScript [3]. The learning curve is lower than Elm's at the start but potentially steeper at the intermediate level for developers who have not worked with ML-family languages before.

ML-family refers to a lineage of programming languages descended from ML (Meta Language), developed at the University of Edinburgh in the 1970s [3]. The family includes OCaml, Standard ML, F#, and Haskell, among others. These languages share a set of common characteristics: strong static typing, type inference, algebraic data types, and pattern matching. ReScript inherits this tradition through its OCaml heritage. Elm is also influenced by this family - its type system and syntax draw heavily from Haskell - but it deliberately strips away the more advanced concepts to make the language accessible without a computer science background.

### Ecosystem and Library Availability

ReScript has access to the entire JavaScript ecosystem through its FFI. Any npm package can be called from ReScript with an `external` declaration, and typed bindings exist for many popular libraries including React, Next.js, and common utility libraries [1]. This is a significant practical advantage over Elm, where integrating a JavaScript library requires writing ports.

Elm's package registry contains several hundred packages with enforced semantic versioning [5]. Packages that require JavaScript interop, such as clipboard access, drag-and-drop, or browser storage, require ports. For applications that stay within what Elm's native packages cover, the smaller registry is not a bottleneck. For applications that depend on specific JavaScript libraries, the difference is significant.

### JavaScript Interoperability

This is the most concrete difference between Elm and ReScript. ReScript allows direct JavaScript calls through `external` declarations and compiles to readable, predictable JavaScript output [4]. The JS output is intentionally human-readable, which makes debugging and integration with existing JavaScript tooling straightforward.

Calling `localStorage` in ReScript is a single declaration:

```rescript
// ReScript: one external declaration, then use it directly anywhere in the file.
@val @scope("localStorage") external getItem: string => Js.Nullable.t<string> = "getItem"

let savedFilter = getItem("ticket-filter")
```

The equivalent in Elm requires a port declaration on the Elm side, a subscriber on the JavaScript side, and a `Msg` variant to receive the response, as demonstrated in [Example 04 - Ports and localStorage](../../docs/examples/04-ports-localstorage/README.md):

```elm
-- Elm side: declare an incoming port to receive the value from JS.
port loadFilter : (String -> msg) -> Sub msg
```

```javascript
// JavaScript side: read from localStorage and send the value into Elm.
var saved = localStorage.getItem("ticket-filter") || "";
app.ports.loadFilter.send(saved);
```

For applications that need to call browser APIs, integrate third-party JavaScript widgets, or interoperate with an existing JavaScript codebase, ReScript's direct interop is a meaningful advantage. For applications that can be built primarily within the language's own packages, Elm's port system is manageable.

### Team Suitability

ReScript is more widely known than Elm among functional programming practitioners, partly due to its OCaml lineage and partly due to its React compatibility [1]. However, both languages represent a small fraction of the overall frontend developer market. Neither is commonly encountered in job postings or standard bootcamp curricula.

The onboarding difference is primarily in background requirements. A developer with React experience can transfer much of that knowledge to ReScript. A developer coming to Elm needs to adopt a different mental model for how applications are structured before writing meaningful code.

### Development Speed

For applications that need JavaScript library integration, ReScript is faster to set up because any npm package can be used directly. The initial scaffolding for a ReScript React application is faster than an equivalent Elm application that requires ports for the same integrations.

For applications with complex internal state that do not require heavy JavaScript integration, the comparison is closer. Elm's compiler-guided development and enforced architecture produce a stable refactoring experience. ReScript provides similar stability in pure ReScript code, with additional speed from direct npm access.

---

## Elm . PureScript

PureScript is a purely functional, strongly typed language that compiles to JavaScript [6]. It is more closely related to Haskell than to Elm. Where Elm deliberately limits its language surface to reduce the learning barrier, PureScript embraces the full theoretical power of a Haskell-style type system, including higher-kinded types, type classes, and effect systems [7].

PureScript is not aimed at beginners or at teams seeking a pragmatic TypeScript alternative. It is aimed at developers who want the maximum type-theoretic guarantees available in a JavaScript-targeting language.

### Type Safety

PureScript's type system is strictly more expressive than Elm's. It supports higher-kinded types and type classes, which allow abstractions that Elm's type system cannot express [7]. Concepts like `Functor`, `Applicative`, and `Monad` are first-class in PureScript and are used throughout its standard library. Elm deliberately excludes these abstractions to keep the language approachable [8].

A higher-kinded type is a type that takes another type constructor as a parameter - one level of abstraction above a regular generic type. A regular generic type like `List a` is parameterised over a concrete value type: `a` can be `Int`, `String`, or any other type. A higher-kinded type is parameterised over something that is itself generic - over a type constructor like `List`, `Maybe`, or `Result`.

In practice, this allows writing a single function that works over any container type as long as that container implements a given interface, called a type class. The canonical example is `Functor`, which abstracts over the concept of mapping:

```purescript
-- PureScript: map works over any type that implements Functor.
-- The same function applies whether f is Array, Maybe, Result, or a custom type.
-- `forall f` means f can be any type constructor that has a Functor instance.
map :: forall f a b. Functor f => (a -> b) -> f a -> f b
```

Elm has `List.map`, `Maybe.map`, and `Result.map` as separate functions because its type system does not support this level of abstraction:

```elm
-- Elm: separate map functions per type. Each works only on its specific type.
-- There is no way to write a single map that works over all of them,
-- because higher-kinded types are not part of the language by design.
List.map   : (a -> b) -> List a     -> List b
Maybe.map  : (a -> b) -> Maybe a    -> Maybe b
Result.map : (a -> b) -> Result x a -> Result x b
```

This is a deliberate design choice in Elm. The additional abstraction power in PureScript is real, but it requires understanding type class hierarchies before writing typical application code. For the use cases covered by this project, the practical difference in type safety is small: both languages prevent null references, require exhaustive pattern matching, and eliminate the common runtime error categories found in JavaScript. PureScript's additional expressiveness becomes relevant in large, highly abstracted codebases, not in typical frontend applications of moderate complexity.

### Runtime Error Prevention

Both Elm and PureScript eliminate runtime errors within their own typed code. PureScript's effect system, based on the `Effect` monad, provides a more granular way of tracking which effects a function is allowed to perform [6]. Elm handles effects through `Cmd` and `Sub`, which is simpler but less fine-grained.

For practical frontend development, the runtime safety of both languages is comparable. The difference is in how effects are modelled, not in whether errors escape into production.

### Architecture and State Management

PureScript does not enforce an application architecture [6]. Several UI frameworks exist for PureScript, including Halogen, which provides a component-based architecture with typed component interfaces. Unlike Elm's single enforced pattern, PureScript applications can be structured in multiple ways depending on the chosen framework.

Halogen's architecture has similarities to TEA but is more complex, involving component slots, queries, and typed message passing between components [9]. The additional expressiveness comes with additional conceptual overhead.

### Learning Curve

PureScript has the steepest learning curve of the three languages in this comparison. A developer new to Haskell-style functional programming will encounter type classes, do-notation, the effect system, and a large standard library before writing a functioning component [7]. The PureScript documentation assumes familiarity with functional programming concepts that Elm actively avoids requiring.

Elm's learning curve is front-loaded but bounded. The Elm guide covers the entire language surface in a linear reading [8]. PureScript's learning surface is not bounded in the same way: a developer can continue going deeper into type theory indefinitely, and the community tooling and documentation assume a higher baseline knowledge than Elm's.

### Ecosystem and Library Availability

PureScript has a smaller ecosystem than both Elm and ReScript [6]. The package registry contains fewer packages, and the available UI frameworks, particularly Halogen, have less documentation and community support than Elm's standard packages. Many PureScript packages are maintained by a small number of contributors.

PureScript does have JavaScript FFI, similar in spirit to ReScript's but less ergonomic [6]. Calling JavaScript from PureScript is possible but requires more boilerplate than ReScript's `external` declarations.

### JavaScript Interoperability

PureScript's FFI requires writing both a PureScript type signature and a separate JavaScript implementation file for each binding [6]. Where ReScript needs a single `external` declaration, PureScript splits the responsibility across two files.

```purescript
-- PureScript side: declare the foreign import with its type.
foreign import getItem :: String -> Effect (Nullable String)
```

```javascript
// JavaScript side: a separate .js file must implement the function.
export const getItem = (key) => () => localStorage.getItem(key);
```

This is more explicit than ReScript's approach but more verbose, and requires maintaining two files in sync for every JavaScript binding. The boundary is explicit but not as structured as Elm's port system, which enforces the typed channel on both sides through the Elm runtime.

### Team Suitability

PureScript is rarely used in commercial frontend development. It is primarily used by developers with a Haskell background who want to apply those skills in a JavaScript environment. Finding developers with PureScript experience is harder than finding developers with Elm experience, and onboarding a developer without a functional programming background is significantly more difficult than with either Elm or ReScript [7].

---

## Overall Assessment

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

Of the three languages, Elm occupies a deliberate middle ground. It does not offer the JavaScript interoperability flexibility of ReScript or the type-theoretic depth of PureScript. What it offers is a single, enforced architecture and a bounded language surface that makes it predictable and teachable without requiring a functional programming background.

ReScript is the more practical choice for teams that need to integrate deeply with the JavaScript and React ecosystem while gaining stronger type guarantees than TypeScript provides. PureScript is the more appropriate choice for developers with a Haskell background who want maximum type safety and are prepared to invest in a steeper learning process.

For a full picture of where these trade-offs favour Elm and where they do not, see:

- [When Elm Is a Good Choice](05-when-elm-is-a-good-choice.md)
- [When Elm Is Not a Good Choice](06-when-elm-is-not-a-good-choice.md)

---

## Sources

[1] ReScript documentation - Introduction to ReScript. https://rescript-lang.org/docs/manual/introduction

[2] ReScript Blog - BuckleScript & Reason Rebranding. https://rescript-lang.org/blog/bucklescript-is-rebranding

[3] OCaml - About OCaml. https://ocaml.org/about

[4] ReScript documentation - External (Bind to Any JS Library). https://rescript-lang.org/docs/manual/external/

[5] Elm Package Registry. https://package.elm-lang.org/

[6] PureScript documentation - The PureScript Book. https://book.purescript.org/

[7] Jordan Martinez - PureScript: Jordan's Reference. https://github.com/JordanMartinez/purescript-jordans-reference

[8] Evan Czaplicki - An Introduction to Elm. https://guide.elm-lang.org/

[9] Halogen documentation - Guide. https://purescript-halogen.github.io/purescript-halogen/guide/

---

<sub>Previous | [Elm vs. TypeScript Frameworks](03-elm-vs-typescript-frameworks.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [When Elm Is a Good Choice](05-when-elm-is-a-good-choice.md)</sub>
