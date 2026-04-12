# Example 05 - Weather Lookup (HTTP and JSON Decoding)

## Concept

This example demonstrates how Elm communicates with external data sources using **HTTP requests** and **JSON decoding**. It shows that Elm does not silently accept data from the outside world - every value coming in through an API must be explicitly decoded into a known Elm type. If the decoding fails, the failure is handled as a typed value, not a runtime crash.

## What to Build

A minimal weather lookup app that fetches the current temperature for a fixed location using the [Open-Meteo API](https://open-meteo.com/) (no API key required).

- A **Fetch Weather** button triggers an HTTP request
- While the request is in flight, a loading message is displayed
- On success, the current temperature in Celsius is shown
- On failure, a human-readable error message is shown
- The app never crashes regardless of what the API returns

## What to Show

- `Browser.element` is required instead of `Browser.sandbox` because the app has side effects (an HTTP request)
- `Http.get` produces a `Cmd msg`, not a result directly - the response arrives later as a `Msg`
- The response is handled as `Result Http.Error Temperature` - success and failure are both typed values
- A `Json.Decode` pipeline extracts the temperature field from the API response
- If the JSON structure does not match the decoder, the app receives a typed error, not a crash
- The `update` function handles three states: initial, loading, and done (success or error)

## Key Point

Elm treats external data as inherently untrustworthy. A JSON decoder is not optional glue code - it is the boundary between the untyped outside world and Elm's type-safe interior. This is what makes Elm applications reliable even when APIs change: a structural mismatch produces a clear decode error at the boundary, not undefined behavior deep inside the application.

This is also the point where `Browser.sandbox` is no longer sufficient. Any application that performs HTTP requests, reads from localStorage, or interacts with the outside world must use `Browser.element` or `Browser.document`, which introduce `Cmd` and `Sub` into the architecture.

## Where This Is Referenced

- `docs/02-elm-theory/05-json-and-http.md` - as the concrete implementation of HTTP and JSON decoding
- `docs/02-elm-theory/03-the-elm-architecture.md` - as an example of `Cmd` and the full TEA cycle with effects
- `docs/03-comparison/02-elm-vs-javascript.md` - as a contrast to JavaScript's untyped `fetch` and JSON parsing

## Ellie Link

> Add the Ellie link here once the example is implemented: https://ellie-app.com/...

## API Used

Open-Meteo current weather endpoint (no API key, no account required):

```
https://api.open-meteo.com/v1/forecast?latitude=46.23&longitude=7.36&current_weather=true
```

The relevant field in the response is `current_weather.temperature`.

## Implementation Notes

- Use `Browser.element` with `init`, `update`, `view`, and `subscriptions` (subscriptions can return `Sub.none`)
- Model the loading state explicitly: `type State = Idle | Loading | Loaded Float | Failed String`
- Decode only the `temperature` field - there is no need to decode the full API response
- Use `Json.Decode.at [ "current_weather", "temperature" ] Json.Decode.float` for the decoder
- Map `Http.Error` to a human-readable string in the view, covering at least `NetworkError` and `BadBody`
- Add inline comments on the decoder, the `Http.get` call, and each branch of the `Result` handling in update
- Keep the view minimal - the focus is the HTTP and decode logic, not the UI
