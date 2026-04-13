module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)


-- MODEL: the current state of the traffic light (three variants)

type TrafficLight
    = Red
    | Yellow
    | Green


type alias Model =
    TrafficLight


-- The light starts at Red on page load.

init : Model
init =
    Red


-- MSG: the only action is advancing to the next state

type Msg
    = Next


-- UPDATE: defines every valid state transition explicitly

update : Msg -> Model -> Model
update msg model =
    case msg of
        Next ->
            case model of
                Red ->
                    Green

                Green ->
                    Yellow

                Yellow ->
                    Red


-- lightColor returns the active color for the current state, or a dimmed color for inactive lights.
-- This function is called once per light, so it runs three times per render.

lightColor : TrafficLight -> TrafficLight -> String
lightColor active light =
    if light == active then
        case light of
            Red    -> "#e74c3c"
            Yellow -> "#f1c40f"
            Green  -> "#2ecc71"
    else
        -- inactive lights are rendered dark to simulate an unlit bulb.
        "#333333"


-- label returns a description of the current state.

label : TrafficLight -> String
label model =
    case model of
        Red    -> "Red - Stop"
        Yellow -> "Yellow - Caution"
        Green  -> "Green - Go"


-- circle renders a single light as a styled div.
-- The active model is passed in so lightColor can determine whether this light is on or off.

circle : TrafficLight -> TrafficLight -> Html Msg
circle active light =
    div
        [ style "width" "80px"
        , style "height" "80px"
        , style "border-radius" "50%"
        , style "background-color" (lightColor active light)
        , style "margin" "10px auto"
        ]
        []


-- VIEW: renders all three lights, active light is bright, others are dimmed

view : Model -> Html Msg
view model =
    div
        [ style "text-align" "center"
        , style "font-family" "sans-serif"
        , style "margin-top" "60px"
        ]
        [ div
            [ style "background-color" "#1a1a1a"
            , style "width" "120px"
            , style "padding" "16px 0"
            , style "border-radius" "12px"
            , style "margin" "0 auto 24px"
            ]
            -- Lights are rendered top to bottom: Red, Yellow, Green.
            [ circle model Red
            , circle model Yellow
            , circle model Green
            ]
        , div [] [ text (label model) ]
        , button
            [ onClick Next
            , style "margin-top" "16px"
            ]
            [ text "Next" ]
        ]


-- MAIN: wires Model / update / view together

main : Program () Model Msg
main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }