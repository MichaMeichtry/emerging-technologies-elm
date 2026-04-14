port module Main exposing (main)

-- "port module" instead of "module" is required whenever the module declares ports.
-- A regular module cannot have ports; the compiler enforces this.

import Browser
import Html exposing (Html, div, h1, p, textarea, text)
import Html.Attributes exposing (placeholder, style, value)
import Html.Events exposing (onInput)


-- PORTS
-- Ports are the only mechanism for communicating with JavaScript.
-- Each port declaration generates a function that Elm can call (outgoing)
-- or a subscription the app can listen to (incoming).

-- Outgoing port: Elm → JavaScript
-- Calling saveNote sends a String to the JS side.
-- JS subscribes to this port and writes to localStorage.
port saveNote : String -> Cmd msg

-- Incoming port: JavaScript → Elm
-- JS calls app.ports.loadNote.send(value) on startup.
-- Elm subscribes to this port and receives the stored value as a Msg.
port loadNote : (String -> msg) -> Sub msg


-- MODEL: the note content as a plain String

type alias Model =
    { note : String }


-- init takes flags (unused here) and returns (Model, Cmd Msg).
-- Browser.element requires this signature; Browser.sandbox does not support Cmd.
-- We start with an empty note - the real value arrives via the loadNote subscription.

init : () -> ( Model, Cmd Msg )
init _ =
    ( { note = "" }, Cmd.none )


-- MSG

type Msg
    = NoteChanged String   -- user typed in the textarea
    | NoteLoaded String    -- JS sent back the stored note on startup


-- UPDATE
-- update now returns (Model, Cmd Msg) instead of just Model.
-- This is required to issue the saveNote command when the user types.

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoteChanged newNote ->
            -- Store the new value in the model AND send it to JS via the port.
            -- saveNote returns a Cmd - the Elm runtime delivers it to JS asynchronously.
            ( { model | note = newNote }, saveNote newNote )

        NoteLoaded stored ->
            -- The note arrived from JS on startup. No need to save it again.
            ( { model | note = stored }, Cmd.none )


-- SUBSCRIPTIONS
-- Browser.element requires a subscriptions function.
-- Here we subscribe to the incoming loadNote port, mapping each value to NoteLoaded.
-- Without this subscription, values sent from JS on startup would be silently ignored.

subscriptions : Model -> Sub Msg
subscriptions _ =
    loadNote NoteLoaded


-- VIEW

view : Model -> Html Msg
view model =
    div
        [ style "font-family" "sans-serif"
        , style "max-width" "480px"
        , style "margin" "60px auto"
        , style "text-align" "center"
        ]
        [ h1 [] [ text "Persistent Note" ]
        , p [ style "color" "#666", style "font-size" "14px" ]
            [ text "Your note is saved automatically and survives page reloads." ]
        , textarea
            [ value model.note
            , onInput NoteChanged
            , placeholder "Start typing your note…"
            , style "width" "100%"
            , style "height" "180px"
            , style "font-size" "16px"
            , style "padding" "12px"
            , style "box-sizing" "border-box"
            , style "border" "1px solid #ccc"
            , style "border-radius" "6px"
            , style "resize" "vertical"
            ]
            []
        , p [ style "font-size" "13px", style "color" "#aaa", style "margin-top" "8px" ]
            [ text
                (if String.isEmpty model.note then
                    "Nothing saved yet."
                 else
                    String.fromInt (String.length model.note) ++ " character(s) saved."
                )
            ]
        ]


-- MAIN
-- Browser.element is required here because the app has side effects (Cmd, Sub).
-- Browser.sandbox has no Cmd or Sub support and cannot be used with ports.

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }