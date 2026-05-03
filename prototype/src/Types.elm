module Types exposing
    ( FilterState(..)
    , Priority(..)
    , Ticket
    , TicketComment
    , TicketHistoryEntry
    , TicketStatus(..)
    )

-- Represents the lifecycle of a support ticket.
-- A ticket can only be in one status at a time, which prevents invalid states at compile time.


type TicketStatus
    = Open
    | InProgress
    | Resolved
    | Closed


-- Defines the urgency level of a ticket.
-- Used for visual highlighting (badges) and for filtering tickets by importance.


type Priority
    = Low
    | Medium
    | High
    | Critical


-- Represents the active filter applied to the ticket list.
-- Allows filtering either by status or by priority.


type FilterState
    = All
    | ByStatus TicketStatus
    | ByPriority Priority


-- A single comment left on a ticket.
-- Timestamp is stored as a string for simplicity
-- (no Time dependency needed in this prototype).


type alias TicketComment =
    { body : String
    , postedAt : String
    }


-- One entry in the status-change history of a ticket.
-- Records the transition and when it occurred.


type alias TicketHistoryEntry =
    { from : TicketStatus
    , to : TicketStatus
    , changedAt : String
    }


-- Represents a single support ticket in the system.
-- All fields are strictly typed to ensure data consistency across the application.
-- dueDate is optional: Nothing means no deadline was set.


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