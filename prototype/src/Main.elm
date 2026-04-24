module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (class)

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
    | SelectTicket Ticket
    | CloseDetail
    "
-}


viewStats : Html msg
viewStats =
    div [ class "stats" ]
        [ statCard "Open" "3" "card-open"
        , statCard "In Progress" "2" "card-inprogress"
        , statCard "Resolved" "1" "card-resolved"
        , statCard "Closed" "0" "card-closed"
        ]


{-| A single stat card showing a count and a label.
The cardClass argument is concatenated onto the base "stat-card" class
to apply the correct color theme for each status.
-}
statCard : String -> String -> String -> Html msg
statCard label count cardClass =
    div [ class ("stat-card " ++ cardClass) ]
        [ div [ class "stat-count" ] [ text count ]
        , div [ class "stat-label" ] [ text label ]
        ]

        

{-| The root view function.
Renders the app layout with all sub-views.
-}
view : Html msg
view =
    div [ class "app" ]
        [ viewHeader
        , viewIntro
        , viewStats
        ]


{-| Renders the top header bar with the app title and subtitle.
-}
viewHeader : Html msg
viewHeader =
    div [ class "header" ]
        [ h1 [] [ text "IT Service Desk" ]
        , p [] [ text "Ticket Management System" ]
        ]


{-| Renders the intro section with a title and two description paragraphs.
-}
viewIntro : Html msg
viewIntro =
    div [ class "intro" ]
        [ h2 [] [ text "Overview" ]
        , p [] [ text "This application allows IT support agents to create, track, and resolve support tickets." ]
        , p [] [ text "Use the filters to browse tickets by status or priority, search by keyword, and update ticket states as work progresses." ]
        ]