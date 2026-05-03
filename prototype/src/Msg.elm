module Msg exposing (Msg(..))

import Types exposing (FilterState, Priority, TicketStatus)


-- Every user interaction in the application is represented as a Msg variant.
-- The update function handles each message with a dedicated case branch,
-- making state transitions explicit and predictable.


type Msg
    = -- No-op used internally by stopPropagationOn to absorb backdrop click events
      NoOp

      -- Modal form control messages
      -- OpenForm displays the modal, CloseForm hides it and resets form state
    | OpenForm
    | CloseForm

      -- Form field updates - each input field has its own message
    | UpdateFormTitle String
    | UpdateFormDescription String
    | UpdateFormPriority Priority
    | UpdateFormCategory String

      -- Form submission
      -- Validates input and either creates a ticket or sets a form error
    | SubmitTicket

      -- Ticket lifecycle
      -- ChangeStatus updates the status of a specific ticket
    | ChangeStatus Int TicketStatus

      -- Assignment update for a ticket (agent name)
    | ChangeAssignedTo Int String

      -- Detail view selection
      -- SelectTicket stores the selected ticket id for the detail panel
    | SelectTicket Int

      -- CloseDetail clears the selected ticket
    | CloseDetail

      -- Filtering system
      -- SetFilter changes the active filter applied to the ticket list
    | SetFilter FilterState

      -- Live search input update
    | UpdateSearch String