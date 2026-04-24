module View exposing (view)

import Html exposing (Html, button, div, h1, h2, input, li, p, span, text, textarea, ul)
import Html.Attributes exposing (class, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Types exposing (FilterState(..), Priority(..), Ticket, TicketStatus(..))



-- Root view. Renders the full application layout.


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ viewHeader
        , viewNav
        , viewBody model
        ]



-- Top header bar.


viewHeader : Html Msg
viewHeader =
    div [ class "header" ]
        [ h1 [] [ text "IT Service Desk" ]
        , p [] [ text "Ticket Management System" ]
        ]



-- Navigation bar with filter buttons and search input.


viewNav : Html Msg
viewNav =
    div [ class "toolbar" ]
        [ button [ onClick (SetFilter All) ] [ text "All" ]
        , button [ onClick (SetFilter (ByStatus Open)) ] [ text "Open" ]
        , button [ onClick (SetFilter (ByStatus InProgress)) ] [ text "In Progress" ]
        , button [ onClick (SetFilter (ByStatus Resolved)) ] [ text "Resolved" ]
        , button [ onClick (SetFilter (ByStatus Closed)) ] [ text "Closed" ]
        ]



-- Decides which main panel to render based on whether a ticket is selected.


viewBody : Model -> Html Msg
viewBody model =
    case model.selectedTicket of
        Just id ->
            case findTicket id model.tickets of
                Just ticket ->
                    viewDetail ticket

                Nothing ->
                    viewTicketList model

        Nothing ->
            viewTicketList model



-- Finds a ticket by id in a list. Returns Nothing if not found.


findTicket : Int -> List Ticket -> Maybe Ticket
findTicket id tickets =
    List.head (List.filter (\t -> t.id == id) tickets)



-- The main ticket list with search bar, create button, and ticket cards.


viewTicketList : Model -> Html Msg
viewTicketList model =
    let
        visible =
            applyFilter model.filter model.searchQuery model.tickets
    in
    div [ class "main" ]
        [ div [ class "search-row" ]
            [ input
                [ placeholder "Search tickets..."
                , value model.searchQuery
                , onInput UpdateSearch
                , class "search-input"
                ]
                []
            ]
        , viewCreateForm model
        , ul [ class "ticket-list" ] (List.map viewTicketCard visible)
        ]



-- Applies the active filter and search query to the full ticket list.
-- Pure function - no side effects, always returns the same output for the same input.


applyFilter : FilterState -> String -> List Ticket -> List Ticket
applyFilter filterState query tickets =
    let
        afterFilter =
            case filterState of
                All ->
                    tickets

                ByStatus status ->
                    List.filter (\t -> t.status == status) tickets

                ByPriority priority ->
                    List.filter (\t -> t.priority == priority) tickets

        q =
            String.toLower (String.trim query)
    in
    if String.isEmpty q then
        afterFilter

    else
        List.filter
            (\t ->
                String.contains q (String.toLower t.title)
                    || String.contains q (String.toLower t.description)
            )
            afterFilter



-- A single ticket card showing the key fields and action buttons.


viewTicketCard : Ticket -> Html Msg
viewTicketCard ticket =
    li [ class "ticket-card" ]
        [ div [ class "card-top" ]
            [ span [ class "ticket-id" ] [ text ("#" ++ String.fromInt ticket.id) ]
            , span [ class ("badge status-" ++ statusClass ticket.status) ]
                [ text (statusLabel ticket.status) ]
            , span [ class ("badge priority-" ++ priorityClass ticket.priority) ]
                [ text (priorityLabel ticket.priority) ]
            ]
        , div [ class "card-title" ] [ text ticket.title ]
        , div [ class "card-meta" ] [ text ticket.category ]
        , div [ class "card-actions" ]
            [ viewNextStatusButton ticket
            , button [ onClick (SelectTicket ticket.id), class "btn-secondary" ]
                [ text "View Details" ]
            ]
        ]



-- Renders the next-status button based on the current status.
-- Pattern matching ensures every status variant is handled.


viewNextStatusButton : Ticket -> Html Msg
viewNextStatusButton ticket =
    case ticket.status of
        Open ->
            button [ onClick (ChangeStatus ticket.id InProgress), class "btn-primary" ]
                [ text "Start" ]

        InProgress ->
            button [ onClick (ChangeStatus ticket.id Resolved), class "btn-primary" ]
                [ text "Resolve" ]

        Resolved ->
            button [ onClick (ChangeStatus ticket.id Closed), class "btn-primary" ]
                [ text "Close" ]

        Closed ->
            button [ onClick (ChangeStatus ticket.id Open), class "btn-secondary" ]
                [ text "Reopen" ]



-- The create-ticket form panel.
-- Inline validation error is shown when formError is Just a message.


viewCreateForm : Model -> Html Msg
viewCreateForm model =
    div [ class "form-panel" ]
        [ h2 [] [ text "Create New Ticket" ]
        , viewFormError model.formError
        , input
            [ placeholder "Title (min 5 characters)"
            , value model.formTitle
            , onInput UpdateFormTitle
            , class "form-input"
            ]
            []
        , textarea
            [ placeholder "Description (min 10 characters)"
            , value model.formDescription
            , onInput UpdateFormDescription
            , class "form-input"
            ]
            []
        , div [ class "form-row" ]
            [ viewPrioritySelector model.formPriority
            , viewCategorySelector model.formCategory
            ]
        , button [ onClick SubmitTicket, class "btn-primary" ]
            [ text "Submit Ticket" ]
        ]



-- Renders the validation error if present.


viewFormError : Maybe String -> Html Msg
viewFormError maybeError =
    case maybeError of
        Nothing ->
            text ""

        Just msg ->
            div [ class "form-error" ] [ text msg ]



-- Priority radio-style buttons.


viewPrioritySelector : Priority -> Html Msg
viewPrioritySelector current =
    div [ class "selector" ]
        [ p [] [ text "Priority" ]
        , button
            [ onClick (UpdateFormPriority Low)
            , class
                (if current == Low then
                    "btn-active"

                 else
                    "btn-option"
                )
            ]
            [ text "Low" ]
        , button
            [ onClick (UpdateFormPriority Medium)
            , class
                (if current == Medium then
                    "btn-active"

                 else
                    "btn-option"
                )
            ]
            [ text "Medium" ]
        , button
            [ onClick (UpdateFormPriority High)
            , class
                (if current == High then
                    "btn-active"

                 else
                    "btn-option"
                )
            ]
            [ text "High" ]
        , button
            [ onClick (UpdateFormPriority Critical)
            , class
                (if current == Critical then
                    "btn-active"

                 else
                    "btn-option"
                )
            ]
            [ text "Critical" ]
        ]



-- Category buttons.


viewCategorySelector : String -> Html Msg
viewCategorySelector current =
    div [ class "selector" ]
        [ p [] [ text "Category" ]
        , viewCategoryBtn "Hardware" current
        , viewCategoryBtn "Software" current
        , viewCategoryBtn "Network" current
        , viewCategoryBtn "Access" current
        , viewCategoryBtn "Other" current
        ]


viewCategoryBtn : String -> String -> Html Msg
viewCategoryBtn cat current =
    button
        [ onClick (UpdateFormCategory cat)
        , class
            (if cat == current then
                "btn-active"

             else
                "btn-option"
            )
        ]
        [ text cat ]



-- The detail view shown when a ticket is selected.
-- Wires Back to CloseDetail and status buttons to ChangeStatus.


viewDetail : Ticket -> Html Msg
viewDetail ticket =
    div [ class "detail-panel" ]
        [ button [ onClick CloseDetail, class "btn-secondary" ] [ text "Back" ]
        , h2 [] [ text ticket.title ]
        , div [ class "detail-meta" ]
            [ span [ class ("badge status-" ++ statusClass ticket.status) ]
                [ text (statusLabel ticket.status) ]
            , span [ class ("badge priority-" ++ priorityClass ticket.priority) ]
                [ text (priorityLabel ticket.priority) ]
            , span [] [ text ("  Category: " ++ ticket.category) ]
            , span [] [ text ("  ID: #" ++ String.fromInt ticket.id) ]
            , span [] [ text ("  Created: " ++ ticket.createdAt) ]
            ]
        , div [ class "detail-assigned" ]
            [ text
                ("Assigned to: "
                    ++ Maybe.withDefault "Unassigned" ticket.assignedTo
                )
            ]
        , p [ class "detail-description" ] [ text ticket.description ]
        , div [ class "detail-actions" ]
            [ viewNextStatusButton ticket ]
        ]



-- Helper: CSS class suffix for each status.


statusClass : TicketStatus -> String
statusClass status =
    case status of
        Open ->
            "open"

        InProgress ->
            "inprogress"

        Resolved ->
            "resolved"

        Closed ->
            "closed"



-- Helper: human-readable label for each status.


statusLabel : TicketStatus -> String
statusLabel status =
    case status of
        Open ->
            "Open"

        InProgress ->
            "In Progress"

        Resolved ->
            "Resolved"

        Closed ->
            "Closed"



-- Helper: CSS class suffix for each priority.


priorityClass : Priority -> String
priorityClass priority =
    case priority of
        Low ->
            "low"

        Medium ->
            "medium"

        High ->
            "high"

        Critical ->
            "critical"



-- Helper: human-readable label for each priority.


priorityLabel : Priority -> String
priorityLabel priority =
    case priority of
        Low ->
            "Low"

        Medium ->
            "Medium"

        High ->
            "High"

        Critical ->
            "Critical"