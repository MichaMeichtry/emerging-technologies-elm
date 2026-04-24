module Msg exposing (Msg(..))

import Model exposing (Ticket)

type Msg
    = TakeTicket
    | ChangeStatus Int
    | ToggleStatusCloseOrOpen Int
    | GoToDashboard
    | GoToTickets
    | SelectTicket Ticket
    | CloseDetail
    