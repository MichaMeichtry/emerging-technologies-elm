module View exposing (view)

import Html exposing (Html, button, div, h1, li, text, ul)
import Html.Events exposing (onClick)
import Model exposing (Model, Ticket, Status(..), Page(..))
import Msg exposing (Msg(..))
import Html.Attributes exposing (class)
import Html exposing (h2, p)


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ nav
        , content model
        ]


content : Model -> Html Msg
content model =
    case model.page of
        Dashboard ->
            viewDashboard model

        TicketsPage ->
            viewTickets model

nav : Html Msg
nav =
    div []
        [ button [ onClick GoToDashboard ] [ text "Dashboard" ]
        , button [ onClick GoToTickets ] [ text "Tickets" ]
        ]


viewDashboard : Model -> Html Msg
viewDashboard model =
    div []
        [ viewHeader
        , viewIntro
        , viewStats
        ]

viewHeader : Html Msg
viewHeader =
    div [ class "header" ]
        [ h1 [] [ text "IT Service Desk" ]
        , Html.p [] [ text "Ticket Management System" ]
        ]


viewIntro : Html Msg
viewIntro =
    div [ class "intro" ]
        [ Html.h2 [] [ text "Overview" ]
        , Html.p [] [ text "This application allows IT support agents to create, track, and resolve support tickets." ]
        , Html.p [] [ text "Use the filters to browse tickets by status or priority, search by keyword, and update ticket states as work progresses." ]
        ]


viewStats : Html Msg
viewStats =
    div [ class "stats" ]
        [ statCard "Open" "3" "card-open"
        , statCard "In Progress" "2" "card-inprogress"
        , statCard "Resolved" "1" "card-resolved"
        , statCard "Closed" "0" "card-closed"
        ]


statCard : String -> String -> String -> Html Msg
statCard label count cardClass =
    div [ class ("stat-card " ++ cardClass) ]
        [ div [ class "stat-count" ] [ text count ]
        , div [ class "stat-label" ] [ text label ]
        ]


viewTickets : Model -> Html Msg
viewTickets model =
    div []
        [ h1 [] [ text "Tickets" ]
        , button [ onClick TakeTicket ] [ text "Take a ticket" ]
        , ul [] (List.map viewTicket model.tickets)
        ]


viewTicket : Ticket -> Html Msg
viewTicket ticket =
    li []
        [ text
            ("Ticket "
                ++ String.fromInt ticket.id
                ++ " - "
                ++ statusToString ticket.status
            )
        , button [ onClick (ChangeStatus ticket.id) ]
            [ text "Next status" ]
        
        , button [ onClick (ToggleStatusCloseOrOpen ticket.id) ]
            [ text "Close/Open" ]

        , button [ onClick (SelectTicket ticket) ]
            [ text "See details" ]
        ]



statusToString : Status -> String
statusToString status =
    case status of
        Open ->
            "Open"

        InProgress ->
            "In Progress"

        Resolved ->
            "Resolved"
        
        Closed ->
            "Closed"