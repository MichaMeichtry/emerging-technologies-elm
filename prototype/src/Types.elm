module Types exposing
    ( FilterState(..)
    , Priority(..)
    , Ticket
    , TicketStatus(..)
    )

-- The lifecycle of a support ticket.
-- Custom types make invalid states impossible: a ticket can never be in two states at once.


type TicketStatus
    = Open
    | InProgress
    | Resolved
    | Closed



-- Urgency level of a ticket.
-- Used both for display (badge colour) and for filtering.


type Priority
    = Low
    | Medium
    | High
    | Critical



-- The active filter applied to the ticket list.
-- ByStatus and ByPriority carry the value being filtered on.


type FilterState
    = All
    | ByStatus TicketStatus
    | ByPriority Priority



-- A single support ticket.
-- All fields are typed so the compiler catches misuse at compile time.


type alias Ticket =
    { id : Int
    , title : String
    , description : String
    , status : TicketStatus
    , priority : Priority
    , category : String
    , createdAt : String
    , assignedTo : Maybe String
    }