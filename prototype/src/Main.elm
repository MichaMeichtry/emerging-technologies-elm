module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class)


{-| The entry point of the application.
Browser.sandbox is the simplest TEA setup - no side effects, no HTTP,
just init, update, and view wired together.
-}
main : Program () () ()
main =
    Browser.sandbox
        { init = ()
        , update = \_ model -> model
        , view = \_ -> view
        }


{-| The root view function.
Renders the app layout with all sub-views.
-}
view : Html ()
view =
    div [ class "app" ]
        [ viewHeader
        , viewIntro
        , viewStats
        ]


{-| Renders the top header bar with the app title and subtitle.
-}
viewHeader : Html ()
viewHeader =
    div [ class "header" ]
        [ h1 [] [ text "IT Service Desk" ]
        , p [] [ text "Ticket Management System" ]
        ]


{-| Renders the intro section with a title and two description paragraphs.
-}
viewIntro : Html ()
viewIntro =
    div [ class "intro" ]
        [ h2 [] [ text "Overview" ]
        , p [] [ text "This application allows IT support agents to create, track, and resolve support tickets." ]
        , p [] [ text "Use the filters to browse tickets by status or priority, search by keyword, and update ticket states as work progresses." ]
        ]


{-| Renders a row of four stat cards, one per ticket status.
Each card gets a CSS class that controls its background and text color.
-}
viewStats : Html ()
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
statCard : String -> String -> String -> Html ()
statCard label count cardClass =
    div [ class ("stat-card " ++ cardClass) ]
        [ div [ class "stat-count" ] [ text count ]
        , div [ class "stat-label" ] [ text label ]
        ]