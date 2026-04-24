module Msg exposing (Msg(..))

import Types exposing (FilterState, Priority, TicketStatus)



-- Every user interaction is represented as a Msg variant.
-- The update function handles each one with a dedicated case branch.


type Msg
    = -- No-op used internally by stopPropagationOn to absorb backdrop click events
      NoOp
      -- Modal form - OpenForm shows the overlay, CloseForm hides it and resets fields
    | OpenForm
    | CloseForm
      -- Form field updates - each input is wired to its own Msg
    | UpdateFormTitle String
    | UpdateFormDescription String
    | UpdateFormPriority Priority
    | UpdateFormCategory String
      -- Submitting the form validates inputs and either creates a ticket or sets formError
    | SubmitTicket
      -- Ticket lifecycle - ChangeStatus carries the ticket id and the new status
    | ChangeStatus Int TicketStatus
      -- Detail view - SelectTicket stores the ticket id in selectedTicket (Just id)
    | SelectTicket Int
      -- CloseDetail sets selectedTicket back to Nothing
    | CloseDetail
      -- Filtering and search - SetFilter replaces the active FilterState
    | SetFilter FilterState
      -- UpdateSearch updates the live search query string
    | UpdateSearch String