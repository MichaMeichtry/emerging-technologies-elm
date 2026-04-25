module Update exposing (update)

import Model exposing (Model, Ticket, Status(..))
import Msg exposing (Msg(..))


update : Msg -> Model -> Model
update msg model =
    case msg of
        TakeTicket ->
            { model
                | tickets =
                    model.tickets
                        ++ [ { id = model.nextId, status = Open } ]
                , nextId = model.nextId + 1
            }

        ChangeStatus id ->
            { model
                | tickets =
                    List.map (updateTicket id) model.tickets
            }

        ToggleStatusCloseOrOpen id ->
            { model
                | tickets =
                    List.map (toggleStatus id) model.tickets
            }

        GoToDashboard ->
            { model | page = Model.Dashboard }

        GoToTickets ->
            { model | page = Model.TicketsPage }

        SelectTicket ticket ->
            { model | selectedTicket = Just ticket }

        CloseDetail ->
            { model | selectedTicket = Nothing }
            
        SetFilter status ->
            { model | filter = status }

        UpdateSearch query ->
            { model | search = query }


updateTicket : Int -> Ticket -> Ticket
updateTicket id ticket =
    if ticket.id == id then
        { ticket | status = nextStatus ticket.status }

    else
        ticket

nextStatus : Status -> Status
nextStatus status =
    case status of
        Open ->
            InProgress

        InProgress ->
            Resolved

        Resolved ->
            Open

        Closed ->
            Closed

toggleStatus : Int -> Ticket -> Ticket
toggleStatus id ticket =
    if ticket.id == id then
        { ticket | status = toggleStatusHelp ticket.status }

    else
        ticket

toggleStatusHelp : Status -> Status
toggleStatusHelp status =
    case status of
        Closed ->
            Open

        _ ->
            Closed




            