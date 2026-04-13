# Example 01 — Counter (The Elm Architecture)

A minimal Elm counter that demonstrates **The Elm Architecture (TEA)**: the fundamental pattern every Elm application is built on.

## Run it instantly (no installation needed)

Open the example directly in your browser: **[ellie-app.com/ytSFnWVDs5ka1](https://ellie-app.com/ytSFnWVDs5ka1)**

Click **▶ Compile** to run it. No account or local setup required.

## What this example does

A counter with three buttons: **−**, **Reset**, and **+**.

- **−** subtracts 1 from the count
- **+** adds 1 to the count
- **Reset** sets the count back to 0

## How the code is structured

Every Elm application is made of exactly three parts.

### Model

```elm
type alias Model =
    Int

init : Model
init =
    0
```

The `Model` holds the entire state of the application. Here it is just an `Int` — the current count. There is no other place where state lives; no global variables, no hidden fields.

### Msg

```elm
type Msg
    = Increment
    | Decrement
    | Reset
```

`Msg` is a custom type that lists every possible action the user can trigger. The compiler enforces that `update` handles all of them — if you add a new `Msg` variant and forget to handle it, the code will not compile.

### Update

```elm
update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment -> model + 1
        Decrement -> model - 1
        Reset     -> 0
```

The `update` function takes the current model and a message, and returns a **new** model — it never mutates the existing one. Pattern matching on `msg` makes every possible state transition explicit and exhaustive. There are no side effects.

### View

```elm
view : Model -> Html Msg
view model =
    div [ ... ]
        [ h1 [] [ text (String.fromInt model) ]
        , button [ onClick Decrement ] [ text "−" ]
        , button [ onClick Reset ]     [ text "Reset" ]
        , button [ onClick Increment ] [ text "+" ]
        ]
```

The `view` function takes the current model and returns HTML. It is a pure function — the same model always produces the same HTML. Clicking a button emits a `Msg` (e.g. `onClick Increment`), which the Elm runtime passes to `update`, which returns a new model, which triggers a new `view` call — and so on in a loop.

### Main

```elm
main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }
```

`Browser.sandbox` wires the three parts together and hands control to the Elm runtime. The `sandbox` variant is the simplest entry point — it has no access to the outside world (no HTTP, no ports), which keeps this example focused purely on the TEA loop.

## Key takeaway

The architecture is not a convention — it is the only way to write an Elm application. This constraint is what makes Elm predictable: you always know where state lives and how it can change.

## Files

```
01-counter/
├── README.md   ← you are here
├── Main.elm    ← the full source code
└── todo.md     ← original exercise brief
```