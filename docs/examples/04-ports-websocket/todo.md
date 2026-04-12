# Example 04 — Ports and localStorage (The JS Interop Trade-off)

## Concept

This example demonstrates **ports** — Elm's only mechanism for communicating with JavaScript. It shows that any interaction with browser APIs outside Elm's core (localStorage, WebSockets, third-party JS libraries, etc.) requires explicit glue code on both sides. This is intentional, not an oversight.

## What to Build

A simple note that persists across page reloads using `localStorage`.

- A text input where the user types a note
- The note is saved to `localStorage` whenever it changes
- On page load, the saved note is read from `localStorage` and pre-filled into the input
- If no note is saved yet, the input starts empty

## What to Show

**On the Elm side:**
- An outgoing port (`port saveNote : String -> Cmd msg`) to send the note to JS
- An incoming port (`port loadNote : (String -> msg) -> Sub msg`) to receive it on load
- The model and update handling the incoming value

**On the JavaScript side:**
- A `<script>` block in `index.html` that subscribes to `saveNote` and calls `localStorage.setItem`
- A startup call that reads `localStorage.getItem` and sends the value into Elm via `loadNote`

## Key Point

Elm cannot touch `localStorage` directly. The boundary is explicit and intentional — Elm guarantees no runtime errors within its own code, and enforcing a hard border with JS is how that guarantee is maintained. The trade-off is verbosity: something that takes one line in JavaScript takes two files and a message-passing protocol in Elm.

This is not a flaw — it is a design decision. But it is a real cost that should inform the choice of whether to use Elm for a given project.

## Where This Is Referenced

- `docs/02-elm-theory/06-strengths-limitations.md` — as a concrete illustration of the JS interop constraint
- `docs/03-comparison/06-when-elm-is-not-a-good-choice.md` — as the primary argument for when Elm's constraints outweigh its benefits

## Ellie Link

> Ellie does not support ports (no access to a custom index.html). This example must be run locally.
> See setup instructions in [prototype/README.md](../../prototype/README.md).

## Implementation Notes

- Keep the Elm code minimal — the point is the ports boilerplate, not the application logic
- Show both files side by side in the documentation: the Elm port declarations and the JS subscription code
- Comment every line of the JS glue code — this is what readers are least likely to be familiar with
- Mention explicitly that this same pattern applies to WebSockets, third-party libraries, and any other browser API Elm does not natively support