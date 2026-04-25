module Msg exposing (Msg(..))

import Model exposing (Ticket, Status)

type Msg
    = TakeTicket
    | ChangeStatus Int
    | ToggleStatusCloseOrOpen Int
    | GoToDashboard
    | GoToTickets
    | SelectTicket Ticket
    | CloseDetail
    | SetFilter Status
    | UpdateSearch String
    