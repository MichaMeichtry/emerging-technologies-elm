module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h1, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)


-- MODEL: the complete state of the app (just a number)

type alias Model =
    Int


init : Model
init =
    0


-- MSG: every possible user action

type Msg
    = Increment
    | Decrement
    | Reset


-- UPDATE: how state changes in response to messages

update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1

        Reset ->
            0


-- VIEW: what the user sees (produces Html that can emit Msg)

view : Model -> Html Msg
view model =
    div [ style "text-align" "center", style "font-family" "sans-serif", style "margin-top" "60px" ]
        [ h1 [] [ text (String.fromInt model) ]
        , button [ onClick Decrement ] [ text "−" ]
        , button [ onClick Reset, style "margin" "0 12px" ] [ text "Reset" ]
        , button [ onClick Increment ] [ text "+" ]
        ]


-- MAIN: wires Model / update / view together

main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }