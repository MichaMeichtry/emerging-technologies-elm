module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h1, p, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode


-- CITIES
-- A fixed list of cities with their coordinates.
-- To add a city, just add a record here - no other code needs to change.

type alias City =
    { name : String
    , latitude : Float
    , longitude : Float
    }

cities : List City
cities =
    [ { name = "Sion, Switzerland",       latitude = 46.23,  longitude = 7.36   }
    , { name = "Lausanne, Switzerland",   latitude = 46.52,  longitude = 6.63   }
    , { name = "Tokyo, Japan",            latitude = 35.68,  longitude = 139.69 }
    , { name = "New York, USA",           latitude = 40.71,  longitude = -74.01 }
    , { name = "Cape Town, South Africa", latitude = -33.93, longitude = 18.42  }
    , { name = "Reykjavik, Iceland",      latitude = 64.13,  longitude = -21.93 }
    , { name = "Singapore",               latitude = 1.29,   longitude = 103.85 }
    , { name = "São Paulo, Brazil",       latitude = -23.55, longitude = -46.63 }
    ]


-- MODEL
-- The state has four variants that represent the full lifecycle of an HTTP request.
-- Using a custom type instead of booleans or nullable fields makes every state explicit
-- and forces the view to handle all of them.

type State
    = Idle                 -- initial state, no city selected yet
    | Loading City         -- request is in flight for this city
    | Loaded City Float    -- request succeeded: city and temperature are available
    | Failed City String   -- request failed: city and error message are available


type alias Model =
    { state : State }


-- init returns (Model, Cmd Msg).
-- Browser.element requires this signature.
-- No request is made on startup - the user must select a city.

init : () -> ( Model, Cmd Msg )
init _ =
    ( { state = Idle }, Cmd.none )


-- MSG

type Msg
    = FetchWeather City                             -- user clicked a city button
    | GotWeather City (Result Http.Error Float)     -- The City is carried in GotWeather so update knows which city the response belongs to.


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchWeather city ->
            -- Transition to Loading for the selected city and issue the HTTP request.
            -- Http.get returns a Cmd - the response arrives later as GotWeather.
            ( { model | state = Loading city }
            , Http.get
                { url = buildUrl city
                , expect = Http.expectJson (GotWeather city) temperatureDecoder
                -- Http.expectJson runs temperatureDecoder on the response body.
                -- If decoding fails, GotWeather receives an Err with Http.BadBody.
                -- If the request fails, GotWeather receives an Err with the relevant Http.Error.
                }
            )

        GotWeather city (Ok temperature) ->
            -- The request succeeded and the decoder extracted a Float.
            ( { model | state = Loaded city temperature }, Cmd.none )

        GotWeather city (Err error) ->
            -- The request failed or the JSON did not match the decoder.
            -- httpErrorToString converts the typed error into a human-readable message.
            ( { model | state = Failed city (httpErrorToString error) }, Cmd.none )


-- URL BUILDER
-- Builds the Open-Meteo API URL for a given city using its coordinates.

buildUrl : City -> String
buildUrl city =
    "https://api.open-meteo.com/v1/forecast"
        ++ "?latitude=" ++ String.fromFloat city.latitude
        ++ "&longitude=" ++ String.fromFloat city.longitude
        ++ "&current_weather=true"


-- DECODER
-- temperatureDecoder navigates the JSON structure and extracts the temperature field.
-- It only decodes what the app needs - the rest of the response is ignored.
--
-- The API returns:
-- { "current_weather": { "temperature": 12.3, ... }, ... }
--
-- Decode.at descends through a list of keys before applying the inner decoder.
-- If any key is missing or the value is not a Float, decoding fails with a typed error.

temperatureDecoder : Decode.Decoder Float
temperatureDecoder =
    Decode.at [ "current_weather", "temperature" ] Decode.float


-- ERROR HELPER
-- Http.Error is a custom type with five variants.
-- Pattern matching here covers all of them with readable messages.
-- The compiler enforces that all variants are handled.

httpErrorToString : Http.Error -> String
httpErrorToString error =
    case error of
        Http.NetworkError ->
            "Network error - check your internet connection."

        Http.Timeout ->
            "The request timed out - try again."

        Http.BadStatus status ->
            "The server returned an error (status " ++ String.fromInt status ++ ")."

        Http.BadBody message ->
            "Unexpected response format: " ++ message

        Http.BadUrl url ->
            "Invalid URL: " ++ url


-- VIEW

view : Model -> Html Msg
view model =
    div
        [ style "font-family" "sans-serif"
        , style "max-width" "480px"
        , style "margin" "60px auto"
        , style "text-align" "center"
        ]
        [ h1 [] [ text "World Weather" ]
        , p [ style "color" "#666", style "font-size" "14px" ]
            [ text "Current temperature from Open-Meteo (no API key required)" ]
        , div
            [ style "display" "flex"
            , style "flex-wrap" "wrap"
            , style "gap" "8px"
            , style "justify-content" "center"
            , style "margin-bottom" "32px"
            ]
            -- List.map renders one button per city.
            -- Each button emits FetchWeather with its city when clicked.
            (List.map (cityButton model.state) cities)
        , viewResult model.state
        ]


-- cityButton renders a single city button.
-- The currently active city is highlighted so the user can see which is selected.

cityButton : State -> City -> Html Msg
cityButton state city =
    let
        isActive =
            case state of
                Loading c   -> c.name == city.name
                Loaded c _  -> c.name == city.name
                Failed c _  -> c.name == city.name
                Idle        -> False
    in
    button
        [ onClick (FetchWeather city)
        , style "font-size" "14px"
        , style "padding" "8px 14px"
        , style "cursor" "pointer"
        , style "border-radius" "6px"
        , style "border" (if isActive then "2px solid #2980b9" else "1px solid #ccc")
        , style "background-color" (if isActive then "#eaf4fb" else "white")
        , style "font-weight" (if isActive then "bold" else "normal")
        ]
        [ text city.name ]


-- viewResult renders the result area below the city buttons.
-- Each State variant produces different content.
-- The compiler verifies all four variants are handled.

viewResult : State -> Html Msg
viewResult state =
    case state of
        Idle ->
            p [ style "color" "#aaa" ]
                [ text "Select a city to fetch its current temperature." ]

        Loading city ->
            p [ style "color" "#666" ]
                [ text ("Loading weather for " ++ city.name ++ "…") ]

        Loaded city temperature ->
            div []
                [ p [ style "color" "#666", style "margin-bottom" "4px" ]
                    [ text city.name ]
                , p
                    [ style "font-size" "56px"
                    , style "font-weight" "bold"
                    , style "margin" "0"
                    ]
                    [ text (String.fromFloat temperature ++ " °C") ]
                ]

        Failed city message ->
            div []
                [ p [ style "color" "#666", style "margin-bottom" "4px" ]
                    [ text city.name ]
                , p [ style "color" "#e74c3c" ]
                    [ text message ]
                ]


-- SUBSCRIPTIONS
-- No subscriptions are needed here, but Browser.element requires the field.

subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


-- MAIN
-- Browser.element is required because the app performs an HTTP request (a side effect).
-- Browser.sandbox has no Cmd support and cannot be used here.

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }