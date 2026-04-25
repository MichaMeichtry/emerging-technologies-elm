module Model exposing (Model, Ticket, Status(..), Page(..), init, Filter(..))

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
    , filter : Filter
    , search : String
    }

type Filter
    = All
    | ByStatus Status


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
    , filter = All
    , search = ""
    }