module Update exposing (update)

import Model exposing (Model)
import Msg exposing (Msg(..))
import Types exposing (Ticket, TicketHistoryEntry, TicketStatus(..))


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
                , formDueDate = ""
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

        UpdateFormDueDate date ->
            { model | formDueDate = date }

        -- Ticket creation
        -- Validates form input before creating a new ticket.
        -- If invalid, stores an error message; otherwise adds the ticket to the list.
        SubmitTicket ->
            case validateForm model of
                Just errorMsg ->
                    { model | formError = Just errorMsg }

                Nothing ->
                    let
                        maybeDue =
                            if String.isEmpty (String.trim model.formDueDate) then
                                Nothing

                            else
                                Just (String.trim model.formDueDate)

                        newTicket =
                            { id = model.nextId
                            , title = String.trim model.formTitle
                            , description = String.trim model.formDescription
                            , status = Open
                            , priority = model.formPriority
                            , category = model.formCategory
                            -- createdAt and comment timestamps are hardcoded strings.
                            -- A real application would use elm/time to get the current date,
                            -- which requires Browser.element and a Task. This prototype uses
                            -- Browser.sandbox and avoids that dependency deliberately.
                            , createdAt = "2026-04-24"
                            , dueDate = maybeDue
                            , comments = []
                            , history = []
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
                        , formDueDate = ""
                        , formError = Nothing
                    }

        -- Ticket status update
        -- Appends a history entry recording the transition, then updates the status.
        ChangeStatus id newStatus ->
            { model
                | tickets =
                    List.map (applyStatusChange id newStatus) model.tickets
            }

        -- Ticket selection for detail view - stores the selected ticket id
        SelectTicket id ->
            { model | selectedTicket = Just id }

        -- Closes the detail view and resets the comment input field
        CloseDetail ->
            { model
                | selectedTicket = Nothing
                , commentBody = ""
            }

        -- Filtering system - updates the active filter applied to the ticket list
        SetFilter filterState ->
            { model | filter = filterState }

        -- Updates the search query used to filter tickets
        UpdateSearch query ->
            { model | searchQuery = query }

        -- Comment field update for the detail view
        UpdateCommentBody body ->
            { model | commentBody = body }

        -- Submits a comment if the body is non-empty.
        -- Appends the comment to the ticket's comment list and resets the input field.
        SubmitComment id ->
            let
                body =
                    String.trim model.commentBody
            in
            if String.isEmpty body then
                model

            else
                let
                    newComment =
                        { body = body
                        -- Timestamp is hardcoded for the same reason as createdAt in SubmitTicket
                        , postedAt = "2026-04-24 12:00"
                        }
                in
                { model
                    | tickets =
                        List.map
                            (\t ->
                                if t.id == id then
                                    { t | comments = t.comments ++ [ newComment ] }

                                else
                                    t
                            )
                            model.tickets
                    , commentBody = ""
                }


-- Updates a ticket's status and appends a history entry if its id matches.
-- Otherwise returns the ticket unchanged.


applyStatusChange : Int -> TicketStatus -> Ticket -> Ticket
applyStatusChange targetId newStatus ticket =
    if ticket.id == targetId then
        let
            entry : TicketHistoryEntry
            entry =
                { from = ticket.status
                , to = newStatus
                , changedAt = "2026-04-24 12:00"
                -- Timestamp is hardcoded for the same reason as createdAt in SubmitTicket
                }
        in
        { ticket
            | status = newStatus
            , history = ticket.history ++ [ entry ]
        }

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