# Example 03 — Temperature Converter (Maybe and Input Validation)

## Concept

This example demonstrates how Elm handles **uncertain values** using the `Maybe` type. It shows that when user input is involved, Elm forces you to explicitly handle the case where the value is missing or invalid — you cannot accidentally skip it.

## What to Build

A temperature converter from Celsius to Fahrenheit.

- A text input field where the user types a Celsius value
- The converted Fahrenheit value is displayed below
- If the input is not a valid number, a clear message is shown (e.g. "Please enter a valid number")
- No submit button — the conversion updates live as the user types

## What to Show

- `String.toFloat` returns a `Maybe Float`, not a `Float`
- The `view` function must handle both `Just value` and `Nothing` explicitly
- There is no way to display a result without first unwrapping the `Maybe` — the compiler enforces this
- Contrast this with JavaScript where `parseFloat("abc")` returns `NaN` silently and can propagate through the application unnoticed

## Key Point

`Maybe` makes the possibility of an invalid value visible in the type. You cannot pass a `Maybe Float` where a `Float` is expected — the compiler will not allow it. This eliminates an entire class of bugs that are common in JavaScript (`undefined is not a function`, unexpected `NaN` in calculations, etc.).

## Where This Is Referenced

- `docs/02-elm-theory/04-type-system-and-safety.md` — as a demonstration of `Maybe` and handling uncertain values
- `docs/03-comparison/02-elm-vs-javascript.md` — as a concrete contrast to JavaScript's silent failure on invalid input

## Ellie Link

> Add the Ellie link here once the example is implemented: https://ellie-app.com/...

## Implementation Notes

- The model should store the raw input as a `String`, not a parsed value — this avoids fighting the input field
- Parse with `String.toFloat` only in the view when computing the result
- Keep the formula simple: `(celsius * 9/5) + 32`
- Add inline comments explaining why `Maybe` appears and what each branch handles