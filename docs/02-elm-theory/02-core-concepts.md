# Core Concepts

## 1. Immutability

In Elm, values are immutable by design. This means that once values have been created, they cannot be modified. Elm is designed to produce new values that incorporate the desired changes, rather than modifying existing data. [1].

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
- **Predictability** - The values are consistent and consistent only throughout the programme
- **Easier debugging** - It is not possible for data to be mutated from a distant part of the codebase unexpectedly.
- **Safer concurrency** - The absence of a shared mutable state eliminates the possibility of race conditions.

As you can see in every example, immutability is in full effect. In
[01-counter/Main.elm](../examples/01-counter/Main.elm), the `update` function never modifies the existing
model; it always returns a brand new one.

```elm
update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment -> model + 1  -- returns a new Int, does not mutate model
        Decrement -> model - 1
        Reset     -> 0
```

## 2. Pure Functions

A pure function always produces the same output given the same input, and has no side effects [2]. All functions in Elm are pure by design.

```elm
add : Int -> Int -> Int
add a b = a + b
-- add 3 4 always returns 7, no matter when or where it is called
```

The following are direct practical benefits [2]:
- **Easy to test** - It is not necessary to mock external state or to worry about side effects.
- **Easy to debug** - Should an unexpected output be produced by a function, then the issue must lie within that function's logic and not in any external factors.
- **Composable** - Simple, pure functions can be combined to solve complex problems.

An excellent example of pure helper functions can be found in [02-traffic-light/Main.elm](../examples/02-traffic-light/Main.elm),
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

It should be noted that the language itself does not handle side effects (HTTP requests, randomness, etc.). These are managed by the Elm runtime via *commands* and
*subscriptions* [3]. Please refer to [05-weather-app/Main.elm](../examples/05-weather-app/Main.elm) for a comprehensive illustration of
HTTP as a side effect expressed as a `Cmd`.

## 3. Static Typing with Type Inference

Elm is statically typed, meaning the compiler verifies types before the program ever runs. Type annotations are optional since Elm infers types automatically, but they are strongly encouraged for the purpose of documentation [3].

```elm
-- Type annotation (optional but recommended)
greet : String -> String
greet name = "Hello, " ++ name
```

Types in Elm include primitives (`Int`, `Float`, `String`, `Bool`), and
compound structures such as lists, tuples, and records. Custom types allow
developers to model domain data precisely [3].

## 4. Custom Types and Pattern Matching

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

The [02-traffic-light/Main.elm](../examples/02-traffic-light/Main.elm) file provides the clearest demonstration of this. The
`TrafficLight` custom type has exactly three variants, and the compiler
verifies that every `case` expression covers all three - in `update`,
`lightColor`, and `label` independently. The [README](../examples/02-traffic-light/README.md) for the example also
shows what happens when you add a fourth variant: the code refuses to compile
until every case is handled everywhere.

The same principle applies to the request lifecycle in [05-weather-app/Main.elm](../examples/05-weather-app/Main.elm). The `State` type makes every phase explicit:

```elm
type State
    = Idle
    | Loading City
    | Loaded City Float
    | Failed City String
```

There is no boolean `isLoading` flag or nullable field. The compiler enforces
that `viewResult` handles all four variants.

## 5. Maybe and Result - No Null, No Exceptions

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

[03-temperature-converter/Main.elm](../examples/03-temperature-converter/Main.elm) is a practical example of the use of the `Maybe` function. Please note that `String.toFloat` returns a `Maybe Float`, not a `Float`. The view
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

[05-weather-app/Main.elm](../examples/05-weather-app/Main.elm) shows `Result` within a real HTTP context. The response
from the Open-Meteo API is returned as an `Result Http.Error Float`. The system has been configured to handle both success and failure, and the compiler verifies that both are handled in `update`.

## Sources

[1] elmprogramming.com. *Immutability*.
    https://elmprogramming.com/immutability.html

[2] elmprogramming.com. *Pure Functions*.
    https://elmprogramming.com/pure-functions.html

[3] Czaplicki, E. *An Introduction to Elm*. Official Elm Guide.
    https://guide.elm-lang.org/

[4] exercism.org. *Pattern Matching in Elm*.
    https://exercism.org/tracks/elm/concepts/pattern-matching

---
<sub>Previous | [What is Elm?](01-what-is-elm.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [Elm Architecture](03-the-elm-architecture.md)</sub>