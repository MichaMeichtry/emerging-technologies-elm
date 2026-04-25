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
    , filter : Status
    , search : String
    }


init : Model
init =
    { tickets = [{ id = 3, status = Open }
        , { id = 2, status = InProgress }
        , { id = 1, status = Resolved }
        , { id = 0, status = Closed }
    ]
    , nextId = 4
    , page = Dashboard
    , selectedTicket = Nothing
    , filter = Open
    , search = ""
    }