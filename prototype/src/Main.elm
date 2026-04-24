module Main exposing (main)

import Browser
import Model exposing (Model)
import Msg exposing (Msg)
import Update exposing (update)
import View exposing (view)



-- Entry point. Wires together the three parts of The Elm Architecture:
-- init supplies the starting model,
-- update handles all messages,
-- view renders the current model to HTML.


main : Program () Model Msg
main =
    Browser.sandbox
        { init = Model.init
        , update = update
        , view = view
        }