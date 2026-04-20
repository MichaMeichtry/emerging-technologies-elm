module Msg exposing (Msg(..))

type Msg
    = TakeTicket
    | ChangeStatus Int
    | ToggleStatusCloseOrOpen Int
    | GoToDashboard
    | GoToTickets
    