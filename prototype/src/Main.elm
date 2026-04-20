module Main exposing (main)

import Browser
import Model
import Update
import View


main =
    Browser.sandbox
        { init = Model.init
        , update = Update.update
        , view = View.view
        }

{- 
    Message Variant :
    "TakeTicket
    | ChangeStatus Int
    | ToggleStatusCloseOrOpen Int
    | GoToDashboard
    | GoToTickets
    "
-}