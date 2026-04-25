module Msg exposing (Msg(..))

import Model exposing (Ticket, Status, Filter)

type Msg
    = TakeTicket
    | ChangeStatus Int
    | ToggleStatusCloseOrOpen Int
    | GoToDashboard
    | GoToTickets
    | SelectTicket Ticket
    | CloseDetail
    | SetFilter Filter
    | UpdateSearch String
    