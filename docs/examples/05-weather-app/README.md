# Example 05 - Weather Lookup (HTTP and JSON Decoding)

A minimal weather app that fetches the current temperature for cities around the world. It demonstrates how Elm communicates with external APIs using **HTTP requests** and **JSON decoding**, and why every value crossing the boundary from the outside world must be explicitly decoded into a known Elm type.

## Run It Instantly (No Installation Needed)

Open the example directly in your browser: **[ellie-app.com/yvjRFMXKfhFa1](https://ellie-app.com/yvk66GngrgZa1)**

Click **▶ Compile** to run it. No account or local setup required.

## What This Example Does

A grid of city buttons triggers HTTP requests to the [Open-Meteo API](https://open-meteo.com/) (no API key required).

- Before any city is selected, a neutral prompt is shown
- Clicking a city button highlights it and shows **Loading…**
- On success, the current temperature in Celsius is displayed
- On failure, a human-readable error message is shown in red
- The app never crashes regardless of what the API returns

The cities list is fixed in the source code. To add a city, add one record to the `cities` list with a name, latitude, and longitude - no other code needs to change.

## API Used

```
https://api.open-meteo.com/v1/forecast?latitude=46.23&longitude=7.36&current_weather=true
```

The latitude and longitude are substituted per city by `buildUrl`. The relevant field in the response is `current_weather.temperature`. No API key or account is required.

## How the Code Is Structured

### The City Record

```elm
type alias City =
    { name : String
    , latitude : Float
    , longitude : Float
    }
```

Each city is a plain record. The `cities` list holds all of them. `List.map` renders one button per city in the view, and the selected city is passed through the messages and state so the app always knows which city a response belongs to.

### Why `Browser.element` is Required

This example performs an HTTP request, which is a side effect. Side effects in Elm are expressed as `Cmd` values. `Browser.sandbox` has no `Cmd` support - it can only handle pure state transformations. `Browser.element` is the minimum entry point that supports `Cmd` and `Sub`.

Compared to `Browser.sandbox`, two things change:

- `init` returns `(Model, Cmd Msg)` instead of `Model`
- `update` returns `(Model, Cmd Msg)` instead of `Model`

### Modelling Loading State Explicitly

The model uses a custom type to represent every phase of the request lifecycle. Each variant carries exactly the data that is available in that state:

```elm
type State
    = Idle
    | Loading City
    | Loaded City Float
    | Failed City String
```

There is no boolean `isLoading` flag, no nullable `temperature`, no separate `error` string. The compiler enforces that the view handles all four variants - a missing case will not compile.

### HTTP Request

```elm
Http.get
    { url = buildUrl city
    , expect = Http.expectJson (GotWeather city) temperatureDecoder
    }
```

`Http.get` returns a `Cmd Msg`, not a result. The response arrives later as a `GotWeather` message. The city is passed into `GotWeather` so `update` knows which city the response belongs to. `Http.expectJson` runs `temperatureDecoder` on the response body and wraps the outcome in a `Result Http.Error Float`.

### Result: Typed Success and Failure

`GotWeather` carries a `Result Http.Error Float`:

```elm
GotWeather city (Ok temperature) ->
    ( { model | state = Loaded city temperature }, Cmd.none )

GotWeather city (Err error) ->
    ( { model | state = Failed city (httpErrorToString error) }, Cmd.none )
```

`Result` has exactly two variants - `Ok` and `Err`. The compiler does not allow using the value inside an `Ok` without unwrapping it first. There is no equivalent of JavaScript's unchecked `.json()` call that silently returns `undefined` on failure.

### JSON Decoder

```elm
temperatureDecoder : Decode.Decoder Float
temperatureDecoder =
    Decode.at [ "current_weather", "temperature" ] Decode.float
```

`Decode.at` navigates through a list of keys and applies the inner decoder at that path. If any key is missing, or if the value at that path is not a `Float`, decoding fails with a typed `Http.BadBody` error. Only the `temperature` field is decoded - the rest of the API response is ignored entirely.

### Error Handling

`Http.Error` is a custom type with five variants. Pattern matching converts each one into a readable string:

```elm
httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.NetworkError -> "Network error - check your internet connection."
        Http.Timeout      -> "The request timed out - try again."
        Http.BadStatus s  -> "The server returned an error (status " ++ String.fromInt s ++ ")."
        Http.BadBody msg  -> "Unexpected response format: " ++ msg
        Http.BadUrl url   -> "Invalid URL: " ++ url
```

The compiler verifies all five variants are covered.

## Key Takeaway

Elm treats external data as inherently untrustworthy. A JSON decoder is not optional glue - it is the boundary between the untyped outside world and Elm's type safe interior. A structural mismatch produces a clear, typed error at the boundary rather than undefined behavior deep inside the application. Combined with `Result`, this makes it structurally impossible to accidentally use a failed HTTP response as if it had succeeded.

## Files

```
05-weather-app/
├── README.md   ← you are here
└── Main.elm    ← the full source code
```
