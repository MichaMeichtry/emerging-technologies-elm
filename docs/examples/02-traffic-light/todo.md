# Example 02 - Traffic Light (Custom Types and Pattern Matching)

## Concept

This example demonstrates **custom types** and **exhaustive pattern matching**. It shows how the Elm compiler enforces that every possible state is handled, making it structurally impossible to forget a case.

## What to Build

A traffic light that cycles through its states on button click.

- The light starts at `Red`
- Clicking **Next** advances it: `Red → Green → Yellow → Red`
- The current state is displayed visually (colored circle or text)

## What to Show

- A custom type `TrafficLight = Red | Green | Yellow` models the states
- The `update` function uses pattern matching to define every transition
- The `view` function uses pattern matching to render each state differently
- **Adding a fourth state** (e.g. `Flashing`) causes a compiler error at every unhandled case - show this in the documentation as a screenshot or code snippet

## Key Point

The compiler does not let you ship code that ignores a possible state. In JavaScript, a missing `case` in a `switch` silently does nothing. In Elm, it is a compile error. This is the core argument for Elm in long-lived, team-maintained applications.

## Where This Is Referenced

- `docs/02-elm-theory/04-type-system-and-safety.md` - as a demonstration of custom types and pattern matching
- `docs/03-comparison/05-when-elm-is-a-good-choice.md` - as the concrete argument for compiler-enforced exhaustiveness

## Ellie Link

> Add the Ellie link here once the example is implemented: https://ellie-app.com/...

## Implementation Notes

- Keep the visual simple - colored text or a styled div is enough, no need for SVG
- The "adding a fourth state" moment is the most important part - make sure it is documented with the compiler error message shown
- Add inline comments on the pattern match branches