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
    }


init : Model
init =
    { tickets = []
    , nextId = 1
    , page = Dashboard
    }