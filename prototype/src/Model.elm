module Model exposing (Model, Ticket, Status(..), Page(..), init)

type Status
    = Open
    | InProgress
    | Resolved
    | Closed


type alias Ticket =
    { id : Int
    , status : Status
    }


type Page
    = Dashboard
    | TicketsPage


type alias Model =
    { tickets : List Ticket
    , nextId : Int
    , page : Page
    , selectedTicket : Maybe Ticket
    }


init : Model
init =
    { tickets = [{ id = 1, status = Open }
        , { id = 2, status = InProgress }
        , { id = 3, status = Resolved }
        , { id = 4, status = Closed }
    ]
    , nextId = 5
    , page = Dashboard
    , selectedTicket = Nothing
    }