module Update exposing (update)

import Model exposing (Model)
import Msg exposing (Msg(..))
import Types exposing (Ticket, TicketStatus(..))



-- The single update function routes every Msg to its handler.
-- Each branch returns a new model - the old model is never mutated.


update : Msg -> Model -> Model
update msg model =
    case msg of
        -- No-op - leaves the model unchanged.
        -- Used by stopPropagationOn in the modal to absorb click events on the box.
        NoOp ->
            model

        -- Modal form - OpenForm shows the overlay, CloseForm hides it and resets all fields.
        OpenForm ->
            { model | showForm = True }

        CloseForm ->
            { model
                | showForm = False
                , formTitle = ""
                , formDescription = ""
                , formPriority = Types.Medium
                , formCategory = "Software"
                , formError = Nothing
            }

        -- Step 6 - form field handlers
        -- Each one replaces a single field in the model record.
        UpdateFormTitle title ->
            { model | formTitle = title, formError = Nothing }

        UpdateFormDescription desc ->
            { model | formDescription = desc, formError = Nothing }

        UpdateFormPriority priority ->
            { model | formPriority = priority }

        UpdateFormCategory category ->
            { model | formCategory = category }

        -- Step 6 - ticket submission with validation
        -- Validates required fields before creating a ticket.
        -- On failure, sets formError so the view can display the message.
        -- On success, the modal is closed and fields are reset.
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

        -- Step 7 - status change
        -- List.map walks every ticket; only the one matching the id is updated.
        -- All other tickets are returned unchanged - this is immutability in action.
        ChangeStatus id newStatus ->
            { model
                | tickets =
                    List.map (applyStatusChange id newStatus) model.tickets
            }

        -- Step 8 - open ticket detail
        -- Stores the ticket id in selectedTicket (Just id).
        -- The view uses this to decide whether to render the detail panel.
        SelectTicket id ->
            { model | selectedTicket = Just id }

        -- Step 8 - close ticket detail
        -- Clears selectedTicket back to Nothing.
        CloseDetail ->
            { model | selectedTicket = Nothing }

        -- Step 9 - filter and search
        SetFilter filterState ->
            { model | filter = filterState }

        UpdateSearch query ->
            { model | searchQuery = query }

        -- Change ticket Affiliation

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



-- Returns the updated ticket when the id matches, or the original ticket unchanged.


applyStatusChange : Int -> TicketStatus -> Ticket -> Ticket
applyStatusChange targetId newStatus ticket =
    if ticket.id == targetId then
        { ticket | status = newStatus }

    else
        ticket



-- Validates the create-ticket form.
-- Returns Nothing when the form is valid, or Just errorMsg when it is not.


validateForm : Model -> Maybe String
validateForm model =
    if String.length (String.trim model.formTitle) < 5 then
        Just "Title must be at least 5 characters."

    else if String.length (String.trim model.formDescription) < 10 then
        Just "Description must be at least 10 characters."

    else
        Nothing


