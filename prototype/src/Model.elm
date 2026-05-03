module Model exposing (Model, init)

import Types exposing (FilterState(..), Priority(..), Ticket, TicketStatus(..))




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

    -- Holds validation error message for the form (if any)
    , formError : Maybe String
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
    , formError = Nothing
    }



-- Example tickets that populate the app on startup.
-- Each ticket is designed to demonstrate a different status and priority,
-- ensuring all UI states are visible for testing and demonstration.


seedTickets : List Ticket
seedTickets =
    [ { id = 1
      , title = "Cannot connect to VPN"
      , description = "Since the last update I am unable to connect to the corporate VPN from home. I get error code 800."
      , status = Open
      , priority = High
      , category = "Network"
      , createdAt = "2025-04-20"
      , assignedTo = Nothing
      }
    , { id = 2
      , title = "Outlook crashes on startup"
      , description = "Outlook 365 crashes immediately after the splash screen. Reinstalling did not fix the problem."
      , status = InProgress
      , priority = Critical
      , category = "Software"
      , createdAt = "2025-04-21"
      , assignedTo = Just "Alice Martin"
      }
    , { id = 3
      , title = "Request new keyboard"
      , description = "Several keys on my keyboard are stuck. I need a replacement before the end of the week."
      , status = Resolved
      , priority = Low
      , category = "Hardware"
      , createdAt = "2025-04-22"
      , assignedTo = Just "Bob Chen"
      }
    , { id = 4
      , title = "Reset domain password"
      , description = "My domain account is locked after too many failed login attempts. Please reset."
      , status = Closed
      , priority = Medium
      , category = "Access"
      , createdAt = "2025-04-23"
      , assignedTo = Just "Alice Martin"
      }
    ]