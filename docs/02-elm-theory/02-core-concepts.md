# Core Concepts

## Immutability

In Elm, values are immutable by design. This means that once values have been created, they cannot be modified. Elm is designed to produce new values that incorporate the desired changes, rather than modifying existing data [1].

```elm
counter : Int
counter = 1

-- This would cause a compiler error:
-- counter = counter + 1  -- Cannot redefine 'counter'

-- Correct approach - create a new value:
newCounter : Int
newCounter = counter + 1
```

The advantages of immutability are concrete [1][2]:

- **Predictability**: The values are predictable and stable throughout the program.
- **Easier debugging**: It is not possible for data to be mutated from a distant part of the codebase unexpectedly.
- **Safer concurrency**: The absence of a shared mutable state eliminates the possibility of race conditions.

Immutability is demonstrated in every example. In
[01-counter/README.md](../examples/01-counter/README.md), the `update` function never modifies the existing
model; it always returns a brand new one.

```elm
update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment -> model + 1  -- returns a new Int, does not mutate model
        Decrement -> model - 1
        Reset     -> 0
```

## Pure Functions

A pure function always produces the same output given the same input, and has no side effects [2]. All functions in Elm are pure by design.

```elm
add : Int -> Int -> Int
add a b = a + b
-- add 3 4 always returns 7, no matter when or where it is called
```

The following are direct practical benefits [2]:

- **Easy to test**: It is not necessary to mock external state or to worry about side effects.
- **Easy to debug**: Should an unexpected output be produced by a function, then the issue must lie within that function's logic and not in any external factors.
- **Composable**: Simple, pure functions can be combined to solve complex problems.

An excellent example of pure helper functions can be found in [02-traffic-light/README.md](../examples/02-traffic-light/README.md),
where `lightColor` and `label` are defined outside the view and called once
per render. The system functions by taking values in and returning values out, with no side effects or shared state.

```elm
label : TrafficLight -> String
label model =
    case model of
        Red    -> "Red - Stop"
        Yellow -> "Yellow - Caution"
        Green  -> "Green - Go"
```

The language itself does not handle side effects (HTTP requests, randomness, etc.). These are managed by the Elm runtime via _commands_ and
_subscriptions_ [3]. See [05-weather-app/README.md](../examples/05-weather-app/README.md) for a comprehensive illustration of
HTTP as a side effect expressed as a `Cmd`.

## Static Typing with Type Inference

Elm is statically typed, meaning the compiler verifies types before the program ever runs. Type annotations are optional since Elm infers types automatically, but they are strongly encouraged for the purpose of documentation [3].

```elm
-- Type annotation (optional but recommended)
greet : String -> String
greet name = "Hello, " ++ name
```

Types in Elm include primitives (`Int`, `Float`, `String`, `Bool`), and
compound structures such as lists, tuples, and records. Custom types allow
developers to model domain data precisely [3].

## Tuples

Tuples store a fixed number of values of potentially different types. They are created with parentheses and comma-separated elements [5].

```elm
-- A pair of strings
( "Lausanne", "Switzerland" )

-- A mixed-type triple: name, age, active status
( "Alice", 30, True )
```

Unlike lists, tuples can hold values of different types. Unlike records, they have no field names - position carries the meaning. Elm limits tuples to a maximum of three elements; use a record for anything larger [5].

Tuples are commonly used to return multiple values from a function. This pattern appears in TEA itself: `update` returns `( Model, Cmd Msg )` whenever commands are involved.

```elm
-- Returning a result and a display colour from one function
validateEmail : String -> ( String, String )
validateEmail email =
    if String.contains "@" email then
        ( "Valid email", "green" )
    else
        ( "Invalid email", "red" )
```

Values are extracted either with `Tuple.first` / `Tuple.second` for pairs, or via pattern matching for all sizes:

```elm
-- Pattern matching to name each element
( city, country ) = ( "Lausanne", "Switzerland" )

-- Three-element destructuring
( name, age, active ) = ( "Alice", 30, True )
```

Tuples are immutable like everything else in Elm. There are no functions to add or remove elements - the size is fixed at creation time and is part of the type. `( Int, String )` and `( Int, String, Bool )` are entirely distinct types [5].

## Custom Types and Pattern Matching

Custom types, also known as union types, enable a value to be assigned to one of several explicit variants. Pattern matching via `case` expressions requires developers to consider every possible variant. The compiler will not accept a program that contains any missing branches [4].

```elm
type Shape
    = Circle Float
    | Rectangle Float Float

area : Shape -> Float
area shape =
    case shape of
        Circle radius ->
            pi * radius * radius

        Rectangle width height ->
            width * height
```

This results in unhandled cases being flagged as a compile-time error rather than a runtime issue [4].

The files from example [02-traffic-light/README.md](../examples/02-traffic-light/README.md) provide the clearest demonstration of this. The
`TrafficLight` custom type has exactly three variants, and the compiler
verifies that every `case` expression covers all three - in `update`,
`lightColor`, and `label` independently. The [README](../examples/02-traffic-light/README.md) for the example also
shows what happens when you add a fourth variant: the code refuses to compile
until every case is handled everywhere.

## Friendly Compiler Error Messages

One of Elm's distinguishing qualities is the clarity of its error messages. When a `case` expression does not cover all variants, the compiler does not produce a generic failure - it names the exact missing branch and explains what to do next.

For example, adding an `Blue` variant to the `TrafficLight` type without updating the `case` expressions produces:

```
Missing Patterns
Line 41, Column 13

This `case` does not have branches for all possibilities:

    case model of
        Red ->
            Green

        Green ->
            Yellow

        Yellow ->
            Red

Missing possibilities include:

    Blue

I would have to crash if I saw one of those. Add branches for them!

Hint: If you want to write the code for each branch later,
use `Debug.todo` as a placeholder.
```

The compiler identifies the unhandled variant by name, explains the consequence (a crash), and offers a concrete workaround (`Debug.todo`). This is representative of how Elm treats compiler output as developer guidance rather than a bare failure report [3].

The same principle applies to the request lifecycle in [05-weather-app/README.md](../examples/05-weather-app/README.md). The `State` type makes every phase explicit:

```elm
type State
    = Idle
    | Loading City
    | Loaded City Float
    | Failed City String
```

There is no boolean `isLoading` flag or nullable field. The compiler enforces
that `viewResult` handles all four variants.

## Maybe and Result - No Null, No Exceptions

Elm is a language without `null`, `undefined`, or exceptions. Instead, the absence of
a value or the possibility of failure is made explicit in the type system
using `Maybe` and `Result` [3].

**Maybe** represents a value that may or may not exist:

```elm
type Maybe a = Just a | Nothing

-- Finding the first element of a list
List.head [1, 2, 3]  -- Just 1
List.head []          -- Nothing
```

**Result** represents an operation that can succeed or fail:

```elm
type Result error value = Ok value | Err error

-- Parsing a string as an integer
String.toInt "42"    -- Ok 42
String.toInt "abc"   -- Err "could not convert string 'abc' to an Int"
```

The compiler ensures that developers must address both `Just`/`Nothing` and
`Ok`/`Err` cases through pattern matching. It is impossible to overlook
an error case [3].

[03-temperature-converter/README.md](../examples/03-temperature-converter/README.md) is a practical example of the use of the `Maybe` type. Note that `String.toFloat` returns a `Maybe Float`, not a `Float`. The view
is required to handle both branches. The conversion functions `toFahrenheit`
and `toKelvin` only ever receive a plain `Float` after the `Maybe` has already
been unwrapped:

```elm
case String.toFloat model.input of
    Nothing ->
        -- input is empty or invalid - show an error message

    Just celsius ->
        -- celsius is a plain Float, safe to pass to conversion functions
```

[05-weather-app/README.md](../examples/05-weather-app/README.md) shows `Result` within a real HTTP context. The response
from the Open-Meteo API is returned as a `Result Http.Error Float`. The system has been configured to handle both success and failure, and the compiler verifies that both are handled in `update`.

## Sources

[1] elmprogramming.com. _Immutability_.
https://elmprogramming.com/immutability.html

[2] elmprogramming.com. _Pure Functions_.
https://elmprogramming.com/pure-functions.html

[3] Czaplicki, E. _An Introduction to Elm_. Official Elm Guide.
https://guide.elm-lang.org/

[4] exercism.org. _Pattern Matching in Elm_.
https://exercism.org/tracks/elm/concepts/pattern-matching

[5] elmprogramming.com. _Tuple_.
https://elmprogramming.com/tuple.html

---

<sub>Previous | [What is Elm?](01-what-is-elm.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [The Elm Architecture](03-the-elm-architecture.md)</sub>
