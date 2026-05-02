module View exposing (view)

import Html exposing (Html, button, div, h1, h2, input, label, li, p, span, text, textarea, ul, select, option)
import Html.Attributes exposing (class, placeholder, value, selected)
import Html.Events exposing (onClick, onInput)
import Json.Decode
import Model exposing (Model)
import Msg exposing (Msg(..))
import Types exposing (FilterState(..), Priority(..), Ticket, TicketStatus(..))



-- Root view. Renders the full application layout and, when needed, the modal overlay.


view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ viewHeader
        , viewBody model
        , -- The modal sits outside the normal document flow and covers the entire screen.
          -- It is only rendered when showForm is True.
          if model.showForm then
            viewFormModal model

          else
            text ""
        ]



-- Top header bar.


viewHeader : Html Msg
viewHeader =
    div [ class "header" ]
        [ h1 [] [ text "IT Service Desk" ]
        , p [] [ text "Ticket Management System" ]
        ]



-- Determines which main panel to render based on whether a ticket is selected.


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


-- A function used by the main ticket list.


visibleTickets : FilterState -> String -> List Ticket -> List Ticket
visibleTickets filterState query tickets =
    applyFilter filterState query tickets



-- The main ticket list with filter toolbar, search bar, create button, and ticket cards.


viewTicketList : Model -> Html Msg
viewTicketList model =
    div [ class "main" ]
        [ viewToolbar model.filter model.tickets
        , div [ class "list-header" ]
            [ input
                [ placeholder "Search tickets..."
                , value model.searchQuery
                , onInput UpdateSearch
                , class "search-input"
                ]
                []
            , button [ onClick OpenForm, class "btn-create" ]
                [ text "+ New Ticket" ]
            ]
        , ul [ class "ticket-list" ]
            (List.map viewTicketCard
                (visibleTickets model.filter model.searchQuery model.tickets)
            )
        ]



-- Filter toolbar.
-- The active FilterState is compared against each button's target so the
-- matching button receives the "filter-btn-active" class.


viewToolbar : FilterState -> List Ticket -> Html Msg
viewToolbar active tickets =
    div [ class "toolbar" ]
        [ filterBtn ("All (" ++ String.fromInt (List.length tickets) ++ ")") All active
        , filterBtn ("Open (" ++ String.fromInt (countByStatus Open tickets) ++ ")") (ByStatus Open) active
        , filterBtn ("In Progress (" ++ String.fromInt (countByStatus InProgress tickets) ++ ")") (ByStatus InProgress) active
        , filterBtn ("Resolved (" ++ String.fromInt (countByStatus Resolved tickets) ++ ")") (ByStatus Resolved) active
        , filterBtn ("Closed (" ++ String.fromInt (countByStatus Closed tickets) ++ ")") (ByStatus Closed) active
        ]



-- A single filter button.
-- Compares its target against the currently active FilterState to decide
-- whether to apply the highlighted style.


filterBtn : String -> FilterState -> FilterState -> Html Msg
filterBtn lbl target active =
    let
        isActive =
            target == active

        cls =
            if isActive then
                "filter-btn filter-btn-active"

            else
                "filter-btn"
    in
    button
        [ onClick (SetFilter target)
        , class (cls ++ " " ++ filterClass target)
        ]
        [ text lbl ]


-- Changes the color of the button depending on the filter status.


filterClass : FilterState -> String
filterClass filter =
    case filter of
        All ->
            ""

        ByStatus Open ->
            "status-open"

        ByStatus InProgress ->
            "status-inprogress"

        ByStatus Resolved ->
            "status-resolved"

        ByStatus Closed ->
            "status-closed"

        ByPriority _ ->
            ""


-- Applies the active filter and search query to the full ticket list.
-- Pure function: no side effects, always returns the same output for the same input.


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


countByStatus : TicketStatus -> List Ticket -> Int
countByStatus status tickets =
    List.filter (\t -> t.status == status) tickets
        |> List.length



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
            [ viewStatusDropdown ticket
            , button [ onClick (SelectTicket ticket.id), class "btn-secondary" ]
                [ text "View Details" ]
            ]
        ]



-- Renders the status selector based on the current ticket state.
-- Pattern matching ensures every status variant is handled.


viewStatusDropdown : Ticket -> Html Msg
viewStatusDropdown ticket =
    select
        [ value (statusToString ticket.status)
        , onInput (\s -> ChangeStatus ticket.id (stringToStatus s))
        , class ("status-select status-" ++ statusClass ticket.status)
        ]
        [ option [ value "Open", selected (ticket.status == Open) ] [ text "Open" ]
        , option [ value "InProgress", selected (ticket.status == InProgress) ] [ text "In Progress" ]
        , option [ value "Resolved", selected (ticket.status == Resolved) ] [ text "Resolved" ]
        , option [ value "Closed", selected (ticket.status == Closed) ] [ text "Closed" ]
        ]

-- Helper function for conversion


stringToStatus : String -> TicketStatus
stringToStatus str =
    case str of
        "Open" ->
            Open

        "InProgress" ->
            InProgress

        "Resolved" ->
            Resolved

        "Closed" ->
            Closed

        _ ->
            Open


statusToString : TicketStatus -> String
statusToString status =
    case status of
        Open ->
            "Open"

        InProgress ->
            "InProgress"

        Resolved ->
            "Resolved"

        Closed ->
            "Closed"



-- The modal overlay for the create-ticket form.
-- Clicking the dark backdrop sends CloseForm so the user can dismiss it by clicking outside.
-- Clicks inside the modal box are stopped from bubbling to the backdrop via stopPropagationOn.


viewFormModal : Model -> Html Msg
viewFormModal model =
    div [ class "modal-backdrop", onClick CloseForm ]
        [ div
            [ class "modal-box"
            , Html.Events.stopPropagationOn "click" (Json.Decode.succeed ( NoOp, True ))
            ]
            [ div [ class "modal-header" ]
                [ h2 [] [ text "New Ticket" ]
                , button [ onClick CloseForm, class "modal-close" ] [ text "x" ]
                ]
            , viewFormError model.formError
            , label [ class "form-label" ] [ text "Title" ]
            , input
                [ placeholder "Min 5 characters"
                , value model.formTitle
                , onInput UpdateFormTitle
                , class "form-input"
                ]
                []
            , label [ class "form-label" ] [ text "Description" ]
            , textarea
                [ placeholder "Min 10 characters"
                , value model.formDescription
                , onInput UpdateFormDescription
                , class "form-input form-textarea"
                ]
                []
            , div [ class "form-row" ]
                [ viewPrioritySelector model.formPriority
                , viewCategorySelector model.formCategory
                ]
            , div [ class "modal-footer" ]
                [ button [ onClick CloseForm, class "btn-secondary" ] [ text "Cancel" ]
                , button [ onClick SubmitTicket, class "btn-primary" ] [ text "Submit Ticket" ]
                ]
            ]
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
        [ p [ class "selector-label" ] [ text "Priority" ]
        , div [ class "selector-btns" ]
            [ priorityBtn Low current
            , priorityBtn Medium current
            , priorityBtn High current
            , priorityBtn Critical current
            ]
        ]


priorityBtn : Priority -> Priority -> Html Msg
priorityBtn target current =
    button
        [ onClick (UpdateFormPriority target)
        , class
            (if target == current then
                "btn-active"

             else
                "btn-option"
            )
        ]
        [ text (priorityLabel target) ]



-- Category selector.


viewCategorySelector : String -> Html Msg
viewCategorySelector current =
    div [ class "selector" ]
        [ p [ class "selector-label" ] [ text "Category" ]
        , select
            [ value current
            , onInput UpdateFormCategory
            , class "form-input"
            ]
            [ option [ value "Hardware" ] [ text "Hardware" ]
            , option [ value "Software" ] [ text "Software" ]
            , option [ value "Network" ] [ text "Network" ]
            , option [ value "Access" ] [ text "Access" ]
            , option [ value "Other" ] [ text "Other" ]
            ]
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
-- Wires the Back button to CloseDetail and status controls to ChangeStatus.


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
            [ label [] [ text "Assigned to: " ]
            , input
                [ value (Maybe.withDefault "" ticket.assignedTo)
                , onInput (\v -> ChangeAssignedTo ticket.id v)
                , placeholder "Assign agent..."
                ]
                []
            ]
        , p [ class "detail-description" ] [ text ticket.description ]
        , div [ class "detail-actions" ]
            [ viewStatusDropdown ticket ]
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