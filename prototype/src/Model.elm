module Model exposing (Model, init)

import Types exposing (FilterState(..), Priority(..), Ticket, TicketComment, TicketHistoryEntry, TicketStatus(..))


-- The full application state.
-- Every field that can change over time lives here.
-- This represents the single source of truth for the entire application.


type alias Model =
    { tickets : List Ticket
    , nextId : Int

    -- Current filter applied to the ticket list (status / priority / all)
    , filter : FilterState

    -- Text entered in the search bar used to filter tickets by keyword
    , searchQuery : String

    -- ID of the currently selected ticket (used for detail view)
    , selectedTicket : Maybe Int

    -- Controls whether the "create ticket" modal is visible
    , showForm : Bool

    -- Form state for creating a new ticket
    , formTitle : String
    , formDescription : String
    , formPriority : Priority
    , formCategory : String
    , formDueDate : String

    -- Holds validation error message for the form (if any)
    , formError : Maybe String

    -- State for the comment input on the detail view
    , commentAuthor : String
    , commentBody : String
    }


-- The initial state of the application.
-- Seeds 4 example tickets so the list is not empty on first load.
-- Each field is initialized to a safe default state.


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
    , commentAuthor = ""
    , commentBody = ""
    }


-- Example tickets that populate the app on startup.
-- Each ticket is designed to demonstrate a different status and priority,
-- ensuring all UI states are visible for testing and demonstration.
-- Some tickets have due dates and pre-seeded comments/history to showcase
-- all new features immediately on load.


seedTickets : List Ticket
seedTickets =
    [ { id = 1
      , title = "Cannot connect to VPN"
      , description = "Since the last update I am unable to connect to the corporate VPN from home. I get error code 800."
      , status = Open
      , priority = High
      , category = "Network"
      , createdAt = "2025-04-20"
      , dueDate = Just "2025-04-25"
      , assignedTo = Nothing
      , comments = []
      , history = []
      }
    , { id = 2
      , title = "Outlook crashes on startup"
      , description = "Outlook 365 crashes immediately after the splash screen. Reinstalling did not fix the problem."
      , status = InProgress
      , priority = Critical
      , category = "Software"
      , createdAt = "2025-04-21"
      , dueDate = Just "2025-04-28"
      , assignedTo = Just "Alice Martin"
      , comments =
            [ { author = "Alice Martin"
              , body = "Reproduced the crash. Collecting event logs from the affected machine."
              , postedAt = "2025-04-21 14:30"
              }
            ]
      , history =
            [ { from = Open
              , to = InProgress
              , changedBy = "Alice Martin"
              , changedAt = "2025-04-21 14:00"
              }
            ]
      }
    , { id = 3
      , title = "Request new keyboard"
      , description = "Several keys on my keyboard are stuck. I need a replacement before the end of the week."
      , status = Resolved
      , priority = Low
      , category = "Hardware"
      , createdAt = "2025-04-22"
      , dueDate = Nothing
      , assignedTo = Just "Bob Chen"
      , comments =
            [ { author = "Bob Chen"
              , body = "Replacement keyboard ordered. Will arrive tomorrow."
              , postedAt = "2025-04-22 09:15"
              }
            , { author = "Bob Chen"
              , body = "Keyboard delivered and confirmed working by user."
              , postedAt = "2025-04-23 11:00"
              }
            ]
      , history =
            [ { from = Open
              , to = InProgress
              , changedBy = "Bob Chen"
              , changedAt = "2025-04-22 09:00"
              }
            , { from = InProgress
              , to = Resolved
              , changedBy = "Bob Chen"
              , changedAt = "2025-04-23 11:05"
              }
            ]
      }
    , { id = 4
      , title = "Reset domain password"
      , description = "My domain account is locked after too many failed login attempts. Please reset."
      , status = Closed
      , priority = Medium
      , category = "Access"
      , createdAt = "2025-04-23"
      , dueDate = Just "2025-04-24"
      , assignedTo = Just "Alice Martin"
      , comments = []
      , history =
            [ { from = Open
              , to = Resolved
              , changedBy = "Alice Martin"
              , changedAt = "2025-04-23 16:45"
              }
            , { from = Resolved
              , to = Closed
              , changedBy = "Alice Martin"
              , changedAt = "2025-04-23 17:00"
              }
            ]
      }
    ]