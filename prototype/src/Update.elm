module Update exposing (update)

import Model exposing (Model)
import Msg exposing (Msg(..))
import Types exposing (Ticket, TicketStatus(..))



-- The main update function.
-- It routes every incoming Msg to the appropriate handler.
-- Each branch returns a new Model (immutability is enforced by Elm).


update : Msg -> Model -> Model
update msg model =
    case msg of
        -- No-op used internally by stopPropagationOn to prevent click propagation
        -- without triggering any state change.
        NoOp ->
            model

        -- Modal form handling
        -- OpenForm shows the ticket creation modal
        OpenForm ->
            { model | showForm = True }

        -- CloseForm hides the modal and resets all form fields to default values
        CloseForm ->
            { model
                | showForm = False
                , formTitle = ""
                , formDescription = ""
                , formPriority = Types.Medium
                , formCategory = "Software"
                , formError = Nothing
            }

        -- Form field updates
        -- Each message updates a single field in the form state
        UpdateFormTitle title ->
            { model | formTitle = title, formError = Nothing }

        UpdateFormDescription desc ->
            { model | formDescription = desc, formError = Nothing }

        UpdateFormPriority priority ->
            { model | formPriority = priority }

        UpdateFormCategory category ->
            { model | formCategory = category }

        -- Ticket creation
        -- Validates form input before creating a new ticket
        -- If invalid, stores an error message; otherwise adds the ticket to the list
        SubmitTicket ->
            case validateForm model of
                Just errorMsg ->
                    { model | formError = Just errorMsg }

                Nothing ->
                    let
                        newTicket =
                            { id = model.nextId
                            , title = String.trim model.formTitle
                            , description = String.trim model.formDescription
                            , status = Open
                            , priority = model.formPriority
                            , category = model.formCategory
                            , createdAt = "2025-04-24"
                            , assignedTo = Nothing
                            }
                    in
                    { model
                        | tickets = model.tickets ++ [ newTicket ]
                        , nextId = model.nextId + 1
                        , showForm = False
                        , formTitle = ""
                        , formDescription = ""
                        , formPriority = Types.Medium
                        , formCategory = "Software"
                        , formError = Nothing
                    }

        -- Ticket status update
        -- Updates only the targeted ticket while leaving others unchanged
        ChangeStatus id newStatus ->
            { model
                | tickets =
                    List.map (applyStatusChange id newStatus) model.tickets
            }

        -- Ticket selection for detail view
        -- Stores the selected ticket id
        SelectTicket id ->
            { model | selectedTicket = Just id }

        -- Closes the detail view by clearing selection
        CloseDetail ->
            { model | selectedTicket = Nothing }

        -- Filtering system
        -- Updates the active filter applied to the ticket list
        SetFilter filterState ->
            { model | filter = filterState }

        -- Updates the search query used to filter tickets
        UpdateSearch query ->
            { model | searchQuery = query }

        -- Assignment update for a ticket
        -- Updates the assigned agent for a specific ticket
        ChangeAssignedTo id agent ->
            { model
                | tickets =
                    List.map
                        (\t ->
                            if t.id == id then
                                { t | assignedTo = Just agent }

                            else
                                t
                        )
                        model.tickets
            }


-- Updates a ticket's status if its id matches the target id.
-- Otherwise returns the ticket unchanged.


applyStatusChange : Int -> TicketStatus -> Ticket -> Ticket
applyStatusChange targetId newStatus ticket =
    if ticket.id == targetId then
        { ticket | status = newStatus }

    else
        ticket


-- Validates the ticket creation form.
-- Returns Nothing if valid, or Just error message if invalid.


validateForm : Model -> Maybe String
validateForm model =
    if String.length (String.trim model.formTitle) < 5 then
        Just "Title must be at least 5 characters long."

    else if String.length (String.trim model.formDescription) < 10 then
        Just "Description must be at least 10 characters long."

    else
        Nothing