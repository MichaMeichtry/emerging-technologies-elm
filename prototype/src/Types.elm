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


-- A single comment left by an agent on a ticket.
-- Author and timestamp are stored as strings for simplicity
-- (no Time dependency needed in this prototype).


type alias TicketComment =
    { author : String
    , body : String
    , postedAt : String
    }


-- One entry in the status-change history of a ticket.
-- Records who changed the status and when.


type alias TicketHistoryEntry =
    { from : TicketStatus
    , to : TicketStatus
    , changedBy : String
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
    , assignedTo : Maybe String
    , comments : List TicketComment
    , history : List TicketHistoryEntry
    }