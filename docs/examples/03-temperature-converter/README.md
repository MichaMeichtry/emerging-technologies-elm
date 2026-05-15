# Example 03 - Temperature Converter (Maybe and Input Validation)

A live temperature converter from Celsius to Fahrenheit and Kelvin. It demonstrates how Elm handles **uncertain values** using the `Maybe` type, and why the compiler forces you to deal with invalid input explicitly rather than letting it silently propagate.

## Run It Instantly (No Installation Needed)

Open the example directly in your browser: **[ellie-app.com/ytVm6tFpwSLa1](https://ellie-app.com/ytVm6tFpwSLa1)**

Click **▶ Compile** to run it. No account or local setup required.

## What This Example Does

A single text input accepts a Celsius value. As the user types, three results appear:

- The equivalent in **Fahrenheit**
- The equivalent in **Kelvin**
- The input echoed back as **Celsius**

Each result is followed by the formula used to compute it. All values are rounded to two decimal places. If the input is not a valid number, a clear error message is shown instead. No button press is needed - the output updates live.

## Conversion Formulas

| From | To         | Formula                |
| ---- | ---------- | ---------------------- |
| °C   | Fahrenheit | `°F = (°C × 9/5) + 32` |
| °C   | Kelvin     | `K = °C + 273.15`      |

Celsius is used as the common base. Both target values are derived from it directly.

## How the Code Is Structured

### Model

```elm
type alias Model =
    { input : String }
```

The raw input is stored as a `String`, not a parsed number. This avoids fighting the input field when the value is mid-edit (for example `"-"` or `"3."`). Parsing happens only in the view, at the point where the result is needed.

### String.toFloat and Maybe

`String.toFloat` returns a `Maybe Float`, not a `Float`. Elm does not allow using a `Maybe Float` where a `Float` is expected - the compiler enforces that both branches are handled. There is no way to accidentally skip the error case.

`Maybe` has exactly two variants:

- `Just celsius` - the string parsed successfully, `celsius` is a usable `Float`
- `Nothing` - the string could not be parsed, no number is available

```elm
case String.toFloat model.input of
    Nothing ->
        -- input is empty or not a valid number

    Just celsius ->
        -- celsius is a plain Float, safe to pass to toFahrenheit and toKelvin
```

The `case` is the only way to get to the `Float` inside a `Maybe`. There is no way to skip it or bypass it - if you try to use a `Maybe Float` as a `Float` directly, the code will not compile. This is what makes it different from JavaScript's `null` or `undefined`, which can be passed into functions silently and only fail later at runtime.

In JavaScript, `parseFloat("abc")` returns `NaN`, which propagates silently through arithmetic and can appear as `NaN` in the UI or corrupt downstream logic without any warning.

### Conversions

```elm
toFahrenheit : Float -> Float
toFahrenheit celsius =
    (celsius * 9 / 5) + 32

toKelvin : Float -> Float
toKelvin celsius =
    celsius + 273.15
```

Both functions take a plain `Float` - not a `Maybe Float`. They only receive a value after the `Maybe` has already been unwrapped in the view. This keeps the conversion logic clean and free of null-handling.

### Rounding

```elm
round2 : Float -> Float
round2 n =
    toFloat (round (n * 100)) / 100
```

All three results are passed through `round2` before display. This avoids floating-point noise like `32.00000000000001` appearing in the output.

### View Helpers

Two helper functions render each row of output:

- `resultRow` renders a label and a computed value on one line
- `formulaRow` renders the formula used in a smaller, muted style below it

These are pure functions that take strings and return `Html Msg`. They are called once per result in the `Just celsius` branch of the view.

### View Branching

```elm
case String.toFloat model.input of
    Nothing ->
        if String.isEmpty model.input then
            -- neutral prompt, no error shown yet
        else
            -- red error message

    Just celsius ->
        -- all three results with formulas
```

The empty and invalid cases are handled separately so a blank input on page load does not immediately show an error. Once the user types something that cannot be parsed, the error appears.

## Key Takeaway

`Maybe` makes the possibility of a missing or invalid value visible in the type. You cannot pass a `Maybe Float` where a `Float` is expected - the compiler will not allow it. This eliminates an entire class of bugs that are common in JavaScript: unexpected `NaN` in calculations, `undefined` passed into functions, and silent failures that reach the UI undetected.

## Files

```
03-temperature-converter/
├── README.md   ← you are here
└── Main.elm    ← the full source code
```
