# Prototype Data Model

The data model defines everything the application needs to know about a ticket, its lifecycle, and the state of the UI at any given moment. In Elm, this means two things: the custom types that describe the domain, and the `Model` record that holds the full application state. Both live in dedicated files `Types.elm` and `Model.elm` and together they form the foundation that every other part of the application builds on.

For a general introduction to how Elm's type system works, see [Core Concepts](../02-elm-theory/02-core-concepts.md). For the role the Model plays in The Elm Architecture, see [The Elm Architecture](../02-elm-theory/03-the-elm-architecture.md).

---

## Custom Types

Elm's custom types allow a value to be exactly one of several explicitly named variants. The compiler enforces that every pattern match covers all variants, which means adding a new variant without updating the code that handles it is a compile error, not a silent bug. All domain types for the prototype are defined in `Types.elm`.

### TicketStatus

`TicketStatus` represents the lifecycle of a support ticket. A ticket can only be in one state at a time, and the four variants cover every valid state in the system.

```elm
type TicketStatus
    = Open
    | InProgress
    | Resolved
    | Closed
```

Using a custom type instead of a string or integer means it is impossible to represent an invalid status. A function that expects a `TicketStatus` cannot accidentally receive the string `"in progress"` or the integer `2`. The compiler would reject the program before it runs.

Everywhere `TicketStatus` is pattern matched. In `Update.elm`, in `View.elm` for status badges and dropdowns, and in the history timeline, the compiler verifies that all four variants are handled. Adding a fifth status like `OnHold` would immediately produce compile errors at every unhandled location.

### Priority

`Priority` defines the urgency level of a ticket. It is used for visual highlighting in badges and could be extended for sorting or filtering by priority.

```elm
type Priority
    = Low
    | Medium
    | High
    | Critical
```

The same exhaustiveness guarantee applies. Any function that pattern matches on `Priority` must handle all four variants. In `View.elm`, `priorityLabel` and `priorityClass` both use `Priority` in a `case` expression, and the compiler verifies both independently.

### FilterState

`FilterState` represents the active filter applied to the ticket list. It is a custom type with three variants, one of which carries a payload.

```elm
type FilterState
    = All
    | ByStatus TicketStatus
    | ByPriority Priority
```

`ByStatus` and `ByPriority` carry a value of the respective type. This means the filter state encodes both what kind of filter is active and which specific value it is filtering on in a single type. There is no separate field to track whether the filter is a status filter or a priority filter, the variant itself carries that information.

In `View.elm`, the `applyFilter` function pattern matches on `FilterState` to decide how to filter the ticket list:

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
        ...
```

### TicketComment

`TicketComment` is a record type representing a single comment on a ticket. Record types in Elm are named collections of typed fields. Unlike custom types, they do not have variants, they always have exactly the fields declared.

```elm
type alias TicketComment =
    { body : String
    , postedAt : String
    }
```

The `postedAt` field is a `String` rather than a proper date type. This is a deliberate simplification to avoid the `elm/time` dependency, which would require a `Cmd` and a subscription to get the current time. The trade-off is noted in the source comments.

### TicketHistoryEntry

`TicketHistoryEntry` records a single status transition on a ticket. It stores the previous status, the new status, and when the change occurred.

```elm
type alias TicketHistoryEntry =
    { from : TicketStatus
    , to : TicketStatus
    , changedAt : String
    }
```

Both `from` and `to` are typed as `TicketStatus`, not as strings. This means the history entries benefit from the same compiler checks as the rest of the codebase, they cannot hold an invalid status value.

### Ticket

`Ticket` is the central record type of the application. It combines all the fields that describe a single support ticket.

```elm
type alias Ticket =
    { id : Int
    , title : String
    , description : String
    , status : TicketStatus
    , priority : Priority
    , category : String
    , createdAt : String
    , dueDate : Maybe String
    , comments : List TicketComment
    , history : List TicketHistoryEntry
    }
```

Several fields are worth examining individually.

`status` and `priority` are typed as `TicketStatus` and `Priority` rather than strings. This prevents invalid values from entering the data model and allows exhaustive pattern matching wherever these fields are used.

`dueDate` is `Maybe String`. The `Maybe` type in Elm represents a value that may or may not be present. `Just "2026-04-28"` means a due date was set, `Nothing` means no deadline exists. The compiler requires that both cases are handled wherever `dueDate` is used, which makes it structurally impossible to accidentally treat an absent due date as an empty string or to call string functions on a value that does not exist.

`comments` and `history` are typed as `List TicketComment` and `List TicketHistoryEntry`. An empty list is the default for both, no separate boolean or nullable field is needed to indicate whether comments or history exist.

For more on `Maybe` and how Elm handles absent values, see [Core Concepts - Maybe and Result](../02-elm-theory/02-core-concepts.md#maybe-and-result---no-null-no-exceptions).

---

## The Model

The `Model` record in `Model.elm` holds the complete application state. Every field that can change over the lifetime of the application lives here. Nothing lives outside the model, no global variables, no component-local state, no hidden fields.

```elm
type alias Model =
    { tickets : List Ticket
    , nextId : Int
    , filter : FilterState
    , searchQuery : String
    , selectedTicket : Maybe Int
    , showForm : Bool
    , formTitle : String
    , formDescription : String
    , formPriority : Priority
    , formCategory : String
    , formDueDate : String
    , formError : Maybe String
    , commentBody : String
    }
```

The fields fall into four logical groups.

**Ticket data**: `tickets` holds the full list of tickets in the system. `nextId` is an auto-incrementing counter used to assign a unique ID to each new ticket. Both are updated together when `SubmitTicket` is handled in `Update.elm`.

**List state**: `filter` and `searchQuery` control what the ticket list displays. `filter` is a `FilterState` value that determines which tickets are shown. `searchQuery` is the current text in the search input. Both are used together in `applyFilter` to produce the visible ticket list.

**Detail view state**: `selectedTicket` is `Maybe Int`. `Nothing` means no ticket is selected and the list view is shown. `Just id` means a ticket is selected and the detail panel is rendered for that ID. Using `Maybe` here means the application can never be in a state where a ticket is "selected" but the ID is invalid or empty.

**Form state**: `showForm`, `formTitle`, `formDescription`, `formPriority`, `formCategory`, `formDueDate`, `formError`, and `commentBody` hold the transient state of the two input forms. Form state is reset to default values when the modal is closed or a ticket is successfully submitted. `formError` is `Maybe String` meaning it will be `Nothing` when the form is valid and `Just message` when validation has failed.

---

## Initialisation

The `init` value in `Model.elm` defines the starting state of the application. Every field is set to a safe default, and the `tickets` field is seeded with four example tickets.

```elm
init : Model
init =
    { tickets = seedTickets
    , nextId = 5
    , filter = All
    , searchQuery = ""
    , selectedTicket = Nothing
    , showForm = False
    , formTitle = ""
    , formDescription = ""
    , formPriority = Medium
    , formCategory = "Software"
    , formDueDate = ""
    , formError = Nothing
    , commentBody = ""
    }
```

`nextId` starts at `5` because the four seed tickets occupy IDs 1 through 4. The filter defaults to `All`, the search query is empty, no ticket is selected, and the form is hidden. All form fields start at their default values so the form is ready to use immediately when opened.

The seed tickets cover all four statuses and all four priorities. Two include pre-populated comments and history entries so those features are visible immediately without requiring any interaction. This makes the prototype useful as a demonstration tool from the first load.

---

## Related Files

| File                                                  | Description                                  |
| ----------------------------------------------------- | -------------------------------------------- |
| [01 - Prototype Overview](01-prototype-overview.md)   | Application features and structure           |
| [02 - Data Model](02-data-model.md)                   | This file                                    |
| [03 - Messages and Update](03-messages-and-update.md) | Msg.elm and Update.elm walkthrough           |
| [04 - View](04-view.md)                               | View.elm walkthrough                         |
| [05 - Test Scenarios](05-test-scenarios.md)           | Test scenarios of the prototype              |
| [Prototype README](../../prototype/README.md)         | Setup and run instructions for the prototype |
| [Prototype Source](../../prototype/src/)              | All Elm source files                         |

---

<sub>Previous | [Prototype Overview](01-prototype-overview.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [Messages and Update](03-messages-and-update.md)</sub>
