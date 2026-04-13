# Example 02 - Traffic Light (Custom Types and Pattern Matching)

A traffic light that cycles through its states on button click. It demonstrates **custom types** and **exhaustive pattern matching** - two of Elm's core mechanisms for making invalid states impossible to represent.

## Run it instantly (no installation needed)

Open the example directly in your browser: **[ellie-app.com/ytTZN6D7h47a1](https://ellie-app.com/ytTZN6D7h47a1)**

Click **▶ Compile** to run it. No account or local setup required.

## What this example does

A traffic light with a single **Next** button.

- Starts at `Red`
- Each click advances the state: `Red → Green → Yellow → Red`
- The circle color and label update to reflect the current state

## How the code is structured

### Custom Type

```elm
type TrafficLight
    = Red
    | Green
    | Yellow
```

`TrafficLight` is a custom type with exactly three variants. There is no string, no integer, no boolean - the type itself encodes every valid state. It is impossible to represent an invalid traffic light state like `"orange"` or `4`.

### Update

```elm
update : Msg -> Model -> Model
update msg model =
    case msg of
        Next ->
            case model of
                Red    -> Green
                Green  -> Yellow
                Yellow -> Red
```

Every transition is listed explicitly. The compiler verifies that all variants of `TrafficLight` are handled. If you add a new variant and forget to handle it here, the code will not compile.

### View

```elm
let
    ( color, label ) =
        case model of
            Red    -> ( "#e74c3c", "Red - Stop" )
            Green  -> ( "#2ecc71", "Green - Go" )
            Yellow -> ( "#f1c40f", "Yellow - Caution" )
```

The same exhaustiveness rule applies in the view. Both `update` and `view` must handle every variant - the compiler checks both independently.

## What happens when you add a fourth state

Add `Flashing` to the custom type:

```elm
type TrafficLight
    = Red
    | Green
    | Yellow
    | Flashing
```

The code will not compile until you handle `Flashing` in both `update` and `view`. The compiler tells you exactly which cases are missing. In JavaScript, a missing `case` in a `switch` silently falls through or does nothing - the bug reaches production undetected.

## Key takeaway

Custom types combined with exhaustive pattern matching make it structurally impossible to forget a case. This is most valuable in long-lived or team-maintained applications where new states are added over time.

## Files

```
02-traffic-light/
├── README.md   ← you are here
└── Main.elm    ← the full source code
```
