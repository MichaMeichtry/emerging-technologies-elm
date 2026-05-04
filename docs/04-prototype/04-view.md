# View

The view layer is responsible for turning the current model into HTML. In Elm, the `view` function is a pure function. Given the same model it always produces the same HTML, with no side effects and no direct DOM manipulation. All view logic for the prototype lives in `View.elm`.

For a general introduction to how the view function works in TEA, see [The Elm Architecture](../02-elm-theory/03-the-elm-architecture.md).

---

## Structure of the View

The root `view` function takes the full `Model` and returns `Html Msg`. Every interactive element in the returned HTML can emit a `Msg` when triggered by a button click, a dropdown change, a text input. The Elm runtime delivers those messages to `update`, which produces a new model, which triggers a new `view` call.

```elm
view : Model -> Html Msg
view model =
    div [ class "app" ]
        [ viewHeader
        , viewBody model
        , if model.showForm then
            viewFormModal model
          else
            text ""
        ]
```

The root view has three parts. The header is a static function with no model dependency. The body is conditional on whether a ticket is selected. The modal overlay is rendered only when `model.showForm` is `True`. When it is `False`, `text ""` produces an empty node that the Elm runtime removes from the DOM.

---

## Conditional Rendering

The most structurally significant decision in the view is how the application switches between the ticket list and the detail panel. This is controlled entirely by `model.selectedTicket`, which is `Maybe Int`.

```elm
viewBody : Model -> Html Msg
viewBody model =
    case model.selectedTicket of
        Just id ->
            case findTicket id model.tickets of
                Just ticket ->
                    viewDetail ticket model

                Nothing ->
                    viewTicketList model

        Nothing ->
            viewTicketList model
```

The outer `case` unwraps `selectedTicket`. If it is `Nothing`, the list view is shown. If it is `Just id`, a second `case` looks up the ticket by ID. If the ticket is found, the detail panel is rendered. If it is not found, which should not occur in normal use but is a possibility the compiler requires be handled, the list view is shown as a fallback.

This double pattern match is a direct consequence of Elm's type system. `selectedTicket` is `Maybe Int`, not `Int`, so the compiler will not allow using it as a plain integer without unwrapping it first. The fallback branch is not defensive programming added by convention, it is a structural requirement of the type. For more on `Maybe`, see [Core Concepts](../02-elm-theory/02-core-concepts.md).

`findTicket` is a pure helper that searches the ticket list:

```elm
findTicket : Int -> List Ticket -> Maybe Ticket
findTicket id tickets =
    List.head (List.filter (\t -> t.id == id) tickets)
```

It returns `Maybe Ticket` because the search may find nothing. The caller must handle both cases.

---

## Filtering and Search

The visible ticket list is derived from the full ticket list on every render. There is no cached filtered list in the model, `update` stores the raw filter state and search query, and `view` applies them when it needs the result.

```elm
visibleTickets : FilterState -> String -> List Ticket -> List Ticket
visibleTickets filterState query tickets =
    applyFilter filterState query tickets
```

`applyFilter` handles both the status filter and the keyword search in a single pass. It first applies the filter, then applies the search query to the filtered result.

```elm
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
```

The `case` on `FilterState` is exhaustive, all three variants are handled. The search comparison uses `String.toLower` on both the query and the ticket fields so the search is case-insensitive. If the query is empty after trimming, the filter result is returned unchanged.

This function is a pure function. It takes a filter state, a query string, and a list of tickets, and returns a filtered list. It has no access to the model and no side effects. It can be understood and tested entirely in isolation.

---

## The Filter Toolbar

The filter toolbar renders one button per filter state. The active filter is passed in so each button can compare itself against it and apply the correct style.

```elm
viewToolbar : FilterState -> List Ticket -> Html Msg
viewToolbar active tickets =
    div [ class "toolbar" ]
        [ filterBtn ("All (" ++ String.fromInt (List.length tickets) ++ ")") All active
        , filterBtn ("Open (" ++ String.fromInt (countByStatus Open tickets) ++ ")") (ByStatus Open) active
        , filterBtn ("In Progress (" ++ String.fromInt (countByStatus InProgress tickets) ++ ")") (ByStatus InProgress) active
        , filterBtn ("Resolved (" ++ String.fromInt (countByStatus Resolved tickets) ++ ")") (ByStatus Resolved) active
        , filterBtn ("Closed (" ++ String.fromInt (countByStatus Closed tickets) ++ ")") (ByStatus Closed) active
        ]
```

Each button label includes a live count. `countByStatus` filters the full ticket list by status and returns the length, the count reflects the total number of tickets in that status, not just the currently visible ones.

`filterBtn` is a pure helper that builds a single button. It compares its `target` against the `active` filter to decide which CSS class to apply.

```elm
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
```

Clicking any filter button emits `SetFilter target`, which `update` stores in `model.filter`. The next render picks up the new filter and `applyFilter` produces the updated list.

---

## Ticket Cards

`viewTicketCard` renders a single ticket as a list item. It is called once per visible ticket via `List.map`.

```elm
viewTicketCard : Ticket -> Html Msg
viewTicketCard ticket =
    li [ class "ticket-card" ]
        [ div [ class "card-top" ]
            [ span [ class "ticket-id" ] [ text ("#" ++ String.fromInt ticket.id) ]
            , span [ class ("badge status-" ++ statusClass ticket.status) ]
                [ text (statusLabel ticket.status) ]
            , span [ class ("badge priority-" ++ priorityClass ticket.priority) ]
                [ text (priorityLabel ticket.priority) ]
            , viewDueDateBadge ticket.dueDate
            ]
        , div [ class "card-title" ] [ text ticket.title ]
        , div [ class "card-meta" ] [ text ticket.category ]
        , div [ class "card-actions" ]
            [ viewStatusDropdown ticket
            , button [ onClick (SelectTicket ticket.id), class "btn-secondary" ]
                [ text "View Details" ]
            ]
        ]
```

The status and priority badges use helper functions `statusClass` and `priorityClass` to produce the correct CSS class suffix. Both are pure functions that pattern match on the respective custom type. Since the types are exhaustive, the CSS class is always valid, there is no fallback string for an unknown variant because an unknown variant cannot exist.

`viewDueDateBadge` takes a `Maybe String` and renders either nothing, a grey due date badge, or a red overdue badge.

```elm
viewDueDateBadge : Maybe String -> Html Msg
viewDueDateBadge maybeDue =
    case maybeDue of
        Nothing ->
            text ""

        Just due ->
            if isOverdue due then
                span [ class "badge due-overdue" ] [ text ("Overdue - " ++ due) ]
            else
                span [ class "badge due-ok" ] [ text ("Due " ++ due) ]
```

The pattern match on `Maybe String` forces both cases to be handled. It is not possible to accidentally render a due date badge when no due date exists. `isOverdue` is a pure helper that compares the due date string against a hardcoded reference date using string comparison, which works correctly for ISO date strings in `YYYY-MM-DD` format.

---

## The Status Dropdown

The status dropdown appears on both the ticket card and the detail view. It is rendered by `viewStatusDropdown`, which takes the current ticket and produces a `select` element.

```elm
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
```

The `onInput` handler converts the selected string back to a `TicketStatus` via `stringToStatus` and emits `ChangeStatus` with the ticket ID and the new status. `stringToStatus` uses a `case` expression with a fallback to `Open` for unrecognised strings, which cannot occur in practice because the options are hardcoded.

The `selected` attribute on each option is set by comparing the ticket's current status to the option's variant. This ensures the dropdown always reflects the current model state rather than relying on browser-managed selection state.

---

## The Create Ticket Modal

The modal form is rendered by `viewFormModal`. It is only called when `model.showForm` is `True`. The backdrop is a full-screen `div` that emits `CloseForm` on click, allowing the user to dismiss the modal by clicking outside it.

```elm
viewFormModal : Model -> Html Msg
viewFormModal model =
    div [ class "modal-backdrop", onClick CloseForm ]
        [ div
            [ class "modal-box"
            , Html.Events.stopPropagationOn "click" (Json.Decode.succeed ( NoOp, True ))
            ]
            [ ...
            ]
        ]
```

`stopPropagationOn` on the inner modal box prevents click events from reaching the backdrop. Without this, clicking anywhere inside the modal would close it. The decoder `Json.Decode.succeed ( NoOp, True )` produces the `NoOp` message with stop-propagation set to `True`. The `True` instructs the Elm runtime to stop the event from bubbling, and `NoOp` ensures no state change occurs.

The form inputs are all controlled inputs, their `value` attribute is always set from the model, and every change emits a `Msg` that updates the model. This is the standard TEA approach to form handling and ensures the model is always the single source of truth for what the form contains.

Validation errors are rendered by `viewFormError`, which pattern matches on `model.formError`:

```elm
viewFormError : Maybe String -> Html Msg
viewFormError maybeError =
    case maybeError of
        Nothing ->
            text ""

        Just msg ->
            div [ class "form-error" ] [ text msg ]
```

When `formError` is `Nothing`, nothing is rendered. When it is `Just message`, the error is displayed. The error clears automatically when the user modifies the title or description fields, because those `update` branches set `formError` back to `Nothing`.

---

## The Detail View

`viewDetail` renders the full ticket information panel. It is called with both the ticket and the full model, because the comment input state lives in the model rather than on the ticket.

The detail view is composed of four logical sections: the ticket metadata, the status control, the comments section, and the history timeline. Each section is its own helper function, keeping the top-level `viewDetail` function readable.

### Comments

`viewComments` renders the list of existing comments and the comment input form. The list is rendered via `List.map viewComment`. If the list is empty, a neutral placeholder message is shown instead.

```elm
if List.isEmpty ticket.comments then
    p [ class "empty-state" ] [ text "No comments yet." ]
else
    ul [ class "comment-list" ]
        (List.map viewComment ticket.comments)
```

The comment textarea is a controlled input wired to `model.commentBody` via `UpdateCommentBody`. The submit button emits `SubmitComment ticket.id`. The guard against empty submissions is in `update`, not in the view. The view always renders the button regardless of whether the input is empty.

### History timeline

`viewHistory` renders the status change log as a vertical timeline. Each entry is rendered by `viewHistoryEntry`, which displays the previous status badge, an arrow, the new status badge, and the timestamp.

```elm
viewHistoryEntry : TicketHistoryEntry -> Html Msg
viewHistoryEntry entry =
    li [ class "history-item" ]
        [ div [ class "history-dot" ] []
        , div [ class "history-content" ]
            [ span [ class ("badge status-" ++ statusClass entry.from) ] [ text (statusLabel entry.from) ]
            , span [ class "history-arrow" ] [ text " -> " ]
            , span [ class ("badge status-" ++ statusClass entry.to) ] [ text (statusLabel entry.to) ]
            , span [ class "history-meta" ] [ text (" - " ++ entry.changedAt) ]
            ]
        ]
```

Both `entry.from` and `entry.to` are `TicketStatus` values, so `statusClass` and `statusLabel` apply directly without any string parsing. The colour-coded badges in the timeline use the same CSS classes as the badges in the ticket list, ensuring visual consistency across the application.

---

## Helper Functions

`View.elm` contains a set of pure helper functions used across multiple view functions. They are defined at the bottom of the file and have no dependencies on the model or on other view functions.

`statusClass` and `statusLabel` map `TicketStatus` to a CSS class suffix and a human-readable string respectively. `priorityClass` and `priorityLabel` do the same for `Priority`. All four are exhaustive `case` expressions - the compiler verifies that every variant is covered.

```elm
statusLabel : TicketStatus -> String
statusLabel status =
    case status of
        Open       -> "Open"
        InProgress -> "In Progress"
        Resolved   -> "Resolved"
        Closed     -> "Closed"
```

`statusToString` and `stringToStatus` convert between `TicketStatus` and `String` for the dropdown element. `filterClass` maps a `FilterState` to a CSS class suffix for the filter buttons.

These helper functions are pure in the strict sense. They take a value and return a value, with no access to the model, no side effects, and no shared state. They can be called any number of times with the same input and will always return the same output. This property is what makes the view function as a whole predictable and easy to reason about.

---

## Related Files

| File                                                  | Description                                  |
| ----------------------------------------------------- | -------------------------------------------- |
| [Prototype README](../../prototype/README.md)         | Setup and run instructions for the prototype |
| [Prototype Source](../../prototype/src/)              | All Elm source files                         |
| [01 - Prototype Overview](01-prototype-overview.md)   | Application features and structure           |
| [02 - Data Model](02-data-model.md)                   | Types.elm and Model.elm walkthrough          |
| [03 - Messages and Update](03-messages-and-update.md) | Msg.elm and Update.elm walkthrough           |
| [04 - View](04-view.md)                               | This file                                    |
| [05 - How to Run and Test](05-how-to-run-and-test.md) | Setup, run commands, and test scenarios      |

---

<sub>Previous | [Messages and Update](03-messages-and-update.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [How to Run and Test](05-how-to-run-and-test.md)</sub>
