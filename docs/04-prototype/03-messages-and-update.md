# Messages and Update

The messages and update function are the heart of The Elm Architecture. Every state change in the application like creating a ticket, changing a status, typing in the search box, posting a comment is expressed as a `Msg` value that passes through the `update` function. This document walks through `Msg.elm` and `Update.elm` and explains how each message maps to a state transition.

For a general introduction to how `Msg` and `update` work in The Elm Architecture, see [The Elm Architecture](../02-elm-theory/03-the-elm-architecture.md).

---

## Messages

All user interactions in the application are represented as variants of the `Msg` custom type, defined in `Msg.elm`. The `update` function handles every variant with a dedicated `case` branch. Adding a new interaction requires adding a `Msg` variant and a corresponding branch. The compiler reports any missing cases.

```elm
type Msg
    = NoOp
    | OpenForm
    | CloseForm
    | UpdateFormTitle String
    | UpdateFormDescription String
    | UpdateFormPriority Priority
    | UpdateFormCategory String
    | UpdateFormDueDate String
    | SubmitTicket
    | ChangeStatus Int TicketStatus
    | SelectTicket Int
    | CloseDetail
    | SetFilter FilterState
    | UpdateSearch String
    | UpdateCommentBody String
    | SubmitComment Int
```

The table below describes every variant, its payload, and what it causes in the model.

| Msg variant             | Payload               | Effect                                                                                                    |
| ----------------------- | --------------------- | --------------------------------------------------------------------------------------------------------- |
| `NoOp`                  | none                  | No state change. Used internally to absorb click events on the modal backdrop without triggering a close. |
| `OpenForm`              | none                  | Sets `showForm` to `True`, making the create ticket modal visible.                                        |
| `CloseForm`             | none                  | Sets `showForm` to `False` and resets all form fields to their default values.                            |
| `UpdateFormTitle`       | `String`              | Updates `formTitle` in the model and clears `formError`.                                                  |
| `UpdateFormDescription` | `String`              | Updates `formDescription` and clears `formError`.                                                         |
| `UpdateFormPriority`    | `Priority`            | Updates `formPriority` to the selected priority variant.                                                  |
| `UpdateFormCategory`    | `String`              | Updates `formCategory` to the selected category string.                                                   |
| `UpdateFormDueDate`     | `String`              | Updates `formDueDate` with the value from the date input.                                                 |
| `SubmitTicket`          | none                  | Validates the form. On failure, sets `formError`. On success, appends a new ticket and resets the form.   |
| `ChangeStatus`          | `Int`, `TicketStatus` | Finds the ticket by ID, updates its status, and appends a history entry.                                  |
| `SelectTicket`          | `Int`                 | Sets `selectedTicket` to `Just id`, opening the detail view for that ticket.                              |
| `CloseDetail`           | none                  | Sets `selectedTicket` to `Nothing` and clears `commentBody`.                                              |
| `SetFilter`             | `FilterState`         | Updates the active filter applied to the ticket list.                                                     |
| `UpdateSearch`          | `String`              | Updates `searchQuery`, causing the visible ticket list to re-filter on the next render.                   |
| `UpdateCommentBody`     | `String`              | Updates `commentBody` with the current value of the comment input.                                        |
| `SubmitComment`         | `Int`                 | Trims `commentBody`, appends a new comment to the matching ticket if non-empty, and resets the input.     |

---

## The Update Function

The `update` function in `Update.elm` is a pure function that takes the current `Model` and a `Msg` and returns a new `Model`. It never mutates the existing model, it always produces a new record with the relevant fields changed. This is Elm's immutability in practice.

```elm
update : Msg -> Model -> Model
update msg model =
    case msg of
        ...
```

The `case` expression must cover every `Msg` variant. The compiler verifies this at compile time. A missing branch is a compile error, not a runtime failure.

### Form control

`OpenForm` and `CloseForm` are straightforward record updates. `CloseForm` resets all form-related fields simultaneously so the form is always in a clean state when it opens again.

```elm
CloseForm ->
    { model
        | showForm = False
        , formTitle = ""
        , formDescription = ""
        , formPriority = Types.Medium
        , formCategory = "Software"
        , formDueDate = ""
        , formError = Nothing
    }
```

The form field update messages each update a single field. `UpdateFormTitle` and `UpdateFormDescription` also clear `formError` so any validation message disappears as soon as the user starts correcting the input.

```elm
UpdateFormTitle title ->
    { model | formTitle = title, formError = Nothing }
```

### Ticket creation and validation

`SubmitTicket` is the most involved handler. It first calls `validateForm` to check the input. If validation fails, `formError` is set to `Just errorMsg` and the model is otherwise unchanged. If validation passes, a new `Ticket` record is constructed and appended to the ticket list.

```elm
SubmitTicket ->
    case validateForm model of
        Just errorMsg ->
            { model | formError = Just errorMsg }

        Nothing ->
            let
                newTicket =
                    { id = model.nextId
                    , title = String.trim model.formTitle
                    , description = String.trim model.formDescription
                    , status = Open
                    , priority = model.formPriority
                    , category = model.formCategory
                    , createdAt = "2026-04-24"
                    , dueDate = maybeDue
                    , comments = []
                    , history = []
                    }
            in
            { model
                | tickets = model.tickets ++ [ newTicket ]
                , nextId = model.nextId + 1
                , showForm = False
                , formTitle = ""
                , formDescription = ""
                , formPriority = Types.Medium
                , formCategory = "Software"
                , formDueDate = ""
                , formError = Nothing
            }
```

`validateForm` is a pure helper function that returns `Maybe String`. `Nothing` means the form is valid. `Just message` means a validation rule failed and the message describes the problem.

```elm
validateForm : Model -> Maybe String
validateForm model =
    if String.length (String.trim model.formTitle) < 5 then
        Just "Title must be at least 5 characters long."

    else if String.length (String.trim model.formDescription) < 10 then
        Just "Description must be at least 10 characters long."

    else
        Nothing
```

The use of `Maybe String` here is typical for Elm. The caller is forced to handle both outcomes, the compiler will not allow treating the result as a plain `String`. This pattern is identical to how `String.toFloat` and `String.toInt` work in the standard library, and to how the `Maybe` type is introduced in [Core Concepts](../02-elm-theory/02-core-concepts.md).

The `dueDate` field is handled separately before constructing the ticket. If the trimmed input is empty, `dueDate` is set to `Nothing`. Otherwise it is wrapped in `Just`.

```elm
let
    maybeDue =
        if String.isEmpty (String.trim model.formDueDate) then
            Nothing
        else
            Just (String.trim model.formDueDate)
```

### Status changes and history

`ChangeStatus` takes the target ticket ID and the new status. It maps over the full ticket list and applies `applyStatusChange` to each ticket. Only the ticket with the matching ID is modified, all others are returned unchanged.

```elm
ChangeStatus id newStatus ->
    { model
        | tickets =
            List.map (applyStatusChange id newStatus) model.tickets
    }
```

`applyStatusChange` is a pure helper function that updates a single ticket if its ID matches. When a match is found, it constructs a `TicketHistoryEntry` recording the transition and appends it to the ticket's history before updating the status.

```elm
applyStatusChange : Int -> TicketStatus -> Ticket -> Ticket
applyStatusChange targetId newStatus ticket =
    if ticket.id == targetId then
        let
            entry : TicketHistoryEntry
            entry =
                { from = ticket.status
                , to = newStatus
                , changedAt = "2026-04-24 12:00"
                }
        in
        { ticket
            | status = newStatus
            , history = ticket.history ++ [ entry ]
        }
    else
        ticket
```

This is a direct demonstration of immutable record updates in Elm. The existing ticket is not modified. A new record is returned with the `status` and `history` fields replaced. The original record is discarded. For more on immutability, see [Core Concepts - Immutability](../02-elm-theory/02-core-concepts.md).

### Detail view navigation

`SelectTicket` stores the ticket ID in `selectedTicket` as `Just id`. `CloseDetail` sets it back to `Nothing` and clears the comment input. The `view` function checks `selectedTicket` to decide whether to render the list or the detail panel - this is covered in detail in [View](04-view.md).

```elm
SelectTicket id ->
    { model | selectedTicket = Just id }

CloseDetail ->
    { model | selectedTicket = Nothing, commentBody = "" }
```

### Filtering and search

`SetFilter` replaces the active `FilterState`. `UpdateSearch` updates `searchQuery`. Neither triggers any direct computation - both simply store the new value in the model. The filtering logic runs in the `view` function on the next render, which keeps `update` free of rendering concerns.

```elm
SetFilter filterState ->
    { model | filter = filterState }

UpdateSearch query ->
    { model | searchQuery = query }
```

### Comments

`UpdateCommentBody` updates the comment input field. `SubmitComment` takes the target ticket ID, trims the `commentBody`, and if the result is non-empty, constructs a new `TicketComment` and appends it to the matching ticket's comment list. The comment input is then cleared.

```elm
SubmitComment id ->
    let
        body =
            String.trim model.commentBody
    in
    if String.isEmpty body then
        model
    else
        let
            newComment =
                { body = body
                , postedAt = "2026-04-24 12:00"
                }
        in
        { model
            | tickets =
                List.map
                    (\t ->
                        if t.id == id then
                            { t | comments = t.comments ++ [ newComment ] }
                        else
                            t
                    )
                    model.tickets
            , commentBody = ""
        }
```

The guard `if String.isEmpty body then model` means the model is returned unchanged when the input is empty. This is intentional. Submitting an empty comment produces no side effect, no error, and no state change.

---

## Key Observations

Every branch of `update` returns a new `Model`. No branch mutates the existing model, calls a side effect, or touches the DOM. The function is pure given the same model and the same message, it always returns the same new model. This makes every state transition testable in isolation and makes it straightforward to reason about what a given message does by reading a single branch.

The filtering and rendering logic is deliberately absent from `update`. Update handles data changes only. Deriving the visible ticket list from the current filter and search query is the responsibility of the `view` function, which is covered in the next section.

---

## Related Files

| File                                                  | Description                                  |
| ----------------------------------------------------- | -------------------------------------------- |
| [01 - Prototype Overview](01-prototype-overview.md)   | Application features and structure           |
| [02 - Data Model](02-data-model.md)                   | Types.elm and Model.elm walkthrough          |
| [03 - Messages and Update](03-messages-and-update.md) | Msg.elm and Update.elm walkthrough           |
| [04 - View](04-view.md)                               | View.elm walkthrough                         |
| [05 - Test Scenarios](05-test-scenarios.md)           | This file                                    |
| [Prototype README](../../prototype/README.md)         | Setup and run instructions for the prototype |
| [Prototype Source](../../prototype/src/)              | All Elm source files                         |

---

<sub>Previous | [Data Model](02-data-model.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [View](04-view.md)</sub>
