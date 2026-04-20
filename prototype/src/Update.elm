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

        GoToDashboard ->
            { model | page = Model.Dashboard }

        GoToTickets ->
            { model | page = Model.TicketsPage }


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

closeTiquet : Status -> Status
closeTiquet _ =
    Closed




            