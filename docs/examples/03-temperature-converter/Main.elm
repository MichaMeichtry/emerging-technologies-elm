module Main exposing (main)

import Browser
import Html exposing (Html, div, h1, input, label, p, text)
import Html.Attributes exposing (placeholder, style, type_, value)
import Html.Events exposing (onInput)


-- MODEL: raw input stored as a String, not a parsed number
-- Storing the string avoids fighting the input field when the value is incomplete (e.g. "-" or "3.")
-- Parsing happens only when the result is needed, in the view.

type alias Model =
    { input : String }


init : Model
init =
    { input = "" }


-- MSG: one message carries the updated input string whenever the user types

type Msg
    = UpdateInput String


-- UPDATE: the model just stores whatever the user typed
-- No validation happens here - the view handles the Maybe from String.toFloat

update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateInput raw ->
            { model | input = raw }


-- CONVERSIONS: all three conversion functions take a Float (Celsius) and return a Float
-- Celsius is used as the common base - every result is derived from it
-- Fahrenheit : °F = (°C × 9/5) + 32
-- Kelvin     : K  = °C + 273.15

toFahrenheit : Float -> Float
toFahrenheit celsius =
    (celsius * 9 / 5) + 32

toKelvin : Float -> Float
toKelvin celsius =
    celsius + 273.15

-- round2 rounds a Float to two decimal places for display

round2 : Float -> Float
round2 n =
    toFloat (round (n * 100)) / 100


-- VIEW HELPERS: resultRow renders a single conversion result as a labeled line

resultRow : String -> String -> Html Msg
resultRow lbl val =
    div
        [ style "margin" "8px 0"
        , style "font-size" "18px"
        ]
        [ label
            [ style "font-weight" "bold"
            , style "margin-right" "8px"
            ]
            [ text lbl ]
        , text val
        ]


-- formulaRow renders a small explanation of the conversion formula used

formulaRow : String -> Html Msg
formulaRow formula =
    p
        [ style "font-size" "13px"
        , style "color" "#888"
        , style "margin" "2px 0 12px"
        ]
        [ text formula ]


-- VIEW: String.toFloat returns a Maybe Float, not a Float
-- Both branches - Just (valid number) and Nothing (invalid input) - handled explicitly
-- The compiler does not allow using a Maybe Float where a Float is expected

view : Model -> Html Msg
view model =
    div
        [ style "font-family" "sans-serif"
        , style "max-width" "360px"
        , style "margin" "60px auto"
        , style "text-align" "center"
        ]
        [ h1 [] [ text "Temperature Converter" ]
        , input
            [ type_ "text"
            , placeholder "Enter °C"
            , value model.input
            , onInput UpdateInput
            , style "font-size" "20px"
            , style "padding" "8px 12px"
            , style "width" "100%"
            , style "box-sizing" "border-box"
            , style "margin-bottom" "24px"
            , style "border" "1px solid #ccc"
            , style "border-radius" "6px"
            ]
            []
        , case String.toFloat model.input of
            -- nothing means the input could not be parsed as a number
            -- this covers empty input, letters, and malformed values like "3..5"
            Nothing ->
                if String.isEmpty model.input then
                    p [ style "color" "#aaa" ] [ text "Type a Celsius value above" ]
                else
                    p [ style "color" "#e74c3c" ] [ text "Please enter a valid number" ]

            -- just celsius means the input parsed successfully
            -- all three results are computed and displayed, each with its formula
            Just celsius ->
                div []
                    [ resultRow "Fahrenheit" (String.fromFloat (round2 (toFahrenheit celsius)) ++ " °F")
                    , formulaRow "°F = (°C × 9/5) + 32"
                    , resultRow "Kelvin" (String.fromFloat (round2 (toKelvin celsius)) ++ " K")
                    , formulaRow "K = °C + 273.15"
                    , resultRow "Celsius" (String.fromFloat (round2 celsius) ++ " °C")
                    , formulaRow "°C = input (base unit)"
                    ]
        ]


-- MAIN: Browser.sandbox is sufficient here with transformation from input string to rendered HTML

main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }