module View exposing (view)

import Html exposing (Html, button, div, h1, li, text, ul)
import Html.Events exposing (onClick)
import Model exposing (Model, Ticket, Status(..), Page(..))
import Msg exposing (Msg(..))


view : Model -> Html Msg
view model =
    div []
        [ nav
        , case model.page of
            Dashboard ->
                viewDashboard model

            TicketsPage ->
                viewTickets model
        ]


nav : Html Msg
nav =
    div []
        [ button [ onClick GoToDashboard ] [ text "Dashboard" ]
        , button [ onClick GoToTickets ] [ text "Tickets" ]
        ]


viewDashboard : Model -> Html Msg
viewDashboard model =
    div []
        [ h1 [] [ text "Dashboard" ]
        , div [] [ text ("Total tickets: " ++ String.fromInt (List.length model.tickets)) ]
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