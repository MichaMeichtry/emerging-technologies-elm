# Example 01 - Counter (The Elm Architecture)

## Concept

This example demonstrates **The Elm Architecture (TEA)** in its simplest possible form. It shows how every Elm application is structured around three parts: a **Model** (the state), an **Update** function (how state changes), and a **View** function (what the user sees).

## What to Build

A counter with three buttons: **Increment**, **Decrement**, and **Reset**.

- Clicking Increment adds 1 to the count
- Clicking Decrement subtracts 1 from the count
- Clicking Reset sets the count back to 0

## What to Show

- The `Model` is just an `Int` - the simplest possible state
- The `Msg` type defines every possible action (`Increment | Decrement | Reset`)
- The `update` function handles each message explicitly with pattern matching
- The `view` function renders the current model and produces messages on click
- There are **no side effects**, no global variables, no shared mutable state

## Key Point

The architecture is not optional or a convention - it is the only way to write an Elm application. This constraint is what makes Elm applications predictable: you always know where state lives and how it can change.

## Where This Is Referenced

- `docs/02-elm-theory/03-the-elm-architecture.md` - as the concrete implementation of the TEA pattern

## Ellie Link

> Add the Ellie link here once the example is implemented: https://ellie-app.com/...

## Implementation Notes

- Keep it under ~40 lines
- Do not add extra features - the value of this example is its simplicity
- Add inline comments explaining each part (Model, Msg, update, view, main)