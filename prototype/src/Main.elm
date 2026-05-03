module Main exposing (main)

import Browser
import Model exposing (Model)
import Msg exposing (Msg)
import Update exposing (update)
import View exposing (view)



-- Entry point of the application.
-- This wires together The Elm Architecture (TEA):
-- - init: provides the initial application state (Model)
-- - update: handles all incoming messages (state transitions)
-- - view: renders the current state as HTML


main : Program () Model Msg
main =
    Browser.sandbox
        { init = Model.init
        , update = update
        , view = view
        }