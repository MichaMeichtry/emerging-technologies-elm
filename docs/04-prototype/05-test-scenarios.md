# Test Scenarios

The following scenarios cover all features of the prototype. Each scenario describes the steps to follow, what to observe, and what it demonstrates about Elm. The scenarios are ordered to build on each other, so running them in sequence gives the most complete picture of the application.

To set up and run the prototype before testing, see [prototype/README.md](../../prototype/README.md) or [Environment Setup](../00-setup/01-environment-setup.md).

---

### 1. Inspect the Seed Data

**Steps:** Open the application. Observe the four pre-loaded tickets on the list.

**What to observe:** Each ticket is in a different status: Open, In Progress, Resolved, and Closed. The filter toolbar shows live counts for each. Ticket 2 (Outlook crashes) is Critical priority with a yellow badge. Ticket 1 (VPN) has a due date badge. Ticket 3 (keyboard) shows an overdue badge because its due date is in the past relative to the hardcoded reference date.

**What it demonstrates:** The `init` function in `Model.elm` seeds the model with structured data on startup. Every field is strictly typed: status and priority are custom types, not strings, and due dates are `Maybe String`.

---

### 2. Filter Tickets by Status

**Steps:** Click each filter button in the toolbar: Open, In Progress, Resolved, Closed, then All.

**What to observe:** The ticket list updates immediately on each click. The active button is highlighted. The count on each button reflects the total tickets in that status, not the visible count.

**What it demonstrates:** `SetFilter` stores a `FilterState` value in the model. The `applyFilter` function in `View.elm` pattern matches on `FilterState` to produce the filtered list. The filtering is a pure function of the model with no intermediate state or cache.

---

### 3. Search Tickets by Keyword

**Steps:** Type "VPN" in the search input. Then clear it and type "outlook". Then try a term that matches no tickets.

**What to observe:** The list filters in real time on every keystroke. The search is case-insensitive. When no tickets match, the list is empty. Clearing the input restores the full list.

**What it demonstrates:** `UpdateSearch` stores the query string in `model.searchQuery`. The `applyFilter` function uses `String.toLower` and `String.contains` to match against ticket titles and descriptions.

---

### 4. Combine Filter and Search

**Steps:** Click the "In Progress" filter. Then type "outlook" in the search box.

**What to observe:** Only tickets that are both In Progress and contain "outlook" are shown. Changing the filter while a search is active re-applies both conditions.

**What it demonstrates:** `applyFilter` applies the status filter first and then runs the search on the result. Both conditions are derived from the model on every render with no separate filtered list to keep in sync.

---

### 5. Create a Valid Ticket

**Steps:** Click "+ New Ticket". Fill in a title of at least five characters, a description of at least ten characters, select a priority and category, and optionally set a due date. Click Submit Ticket.

**What to observe:** The modal closes, the form resets, and the new ticket appears at the bottom of the list with the correct status badge (Open), priority badge, and due date badge if one was set.

**What it demonstrates:** `SubmitTicket` calls `validateForm`, which returns `Nothing` when valid. A new `Ticket` record is constructed and appended to `model.tickets`. The `nextId` counter increments and the form fields reset in a single record update expression.

---

### 6. Submit the Form With Invalid Input

**Steps:** Click "+ New Ticket". Leave the title empty and click Submit Ticket. Then type a title shorter than five characters and click again. Then fill the title correctly but leave the description too short.

**What to observe:** A red error message appears below the modal header describing the specific validation failure. The modal stays open. As soon as you start typing in the title or description field, the error message disappears.

**What it demonstrates:** `validateForm` returns `Just errorMsg` when validation fails. The model stores `formError` as `Maybe String` and `viewFormError` pattern matches on it, rendering nothing when it is `Nothing`. The `UpdateFormTitle` and `UpdateFormDescription` branches in `update` set `formError` back to `Nothing` on every keystroke.

---

### 7. Dismiss the Modal

**Steps:** Open the create ticket form. Click the dark backdrop outside the modal box. Open it again and click the X button. Open it again and click Cancel.

**What to observe:** All three methods close the modal. Any partially filled form fields are reset each time.

**What it demonstrates:** The backdrop `div` emits `CloseForm` on click. The inner modal box uses `stopPropagationOn` to prevent that click from reaching the backdrop when clicking inside. `CloseForm` resets all form fields in a single record update, ensuring the form is always clean when reopened.

---

### 8. Change a Ticket Status From the List

**Steps:** On any ticket card, use the status dropdown to change the status to a different value.

**What to observe:** The status badge on the card updates immediately. The filter toolbar counts update. If a status filter is active and the ticket no longer matches it, the ticket disappears from the list.

**What it demonstrates:** `ChangeStatus` maps over `model.tickets` with `applyStatusChange`. The matching ticket is replaced with a new record containing the updated status and a new history entry. All other tickets are returned unchanged.

---

### 9. Open the Detail View

**Steps:** Click "View Details" on any ticket card.

**What to observe:** The ticket list is replaced by the detail panel showing the full ticket information: title, description, status, priority, category, ID, creation date, and due date badge if applicable.

**What it demonstrates:** `SelectTicket` sets `model.selectedTicket` to `Just id`. The `viewBody` function pattern matches on `selectedTicket` and renders `viewDetail` when a ticket is selected. This is conditional rendering driven entirely by the model, with no separate route or page state.

---

### 10. Change Status From the Detail View

**Steps:** From the detail view, use the status dropdown to change the ticket status.

**What to observe:** The status badge in the detail view updates immediately. A new entry appears at the bottom of the history timeline showing the previous status, the new status, and a timestamp.

**What it demonstrates:** `ChangeStatus` works identically whether triggered from the list or the detail view: the same message, the same update branch, the same result. `applyStatusChange` appends a `TicketHistoryEntry` to `ticket.history` with `from` and `to` typed as `TicketStatus`, not strings.

---

### 11. Post a Comment

**Steps:** From the detail view, type a note in the comment textarea and click Post Comment.

**What to observe:** The comment appears in the list above the input with a timestamp. The input clears. The comment count in the section header increments.

**What it demonstrates:** `SubmitComment` trims `commentBody` and only proceeds if the result is non-empty. A new `TicketComment` record is constructed and appended to the ticket's `comments` list. The view derives the displayed list directly from `ticket.comments` on every render.

---

### 12. Attempt to Post an Empty Comment

**Steps:** From the detail view, leave the comment input empty and click Post Comment. Then type only spaces and click again.

**What to observe:** Nothing happens. The model does not change and no error is shown.

**What it demonstrates:** The `SubmitComment` branch in `update` trims the input and checks `String.isEmpty` before constructing a comment. If the body is empty, `model` is returned unchanged. The guard lives in `update`, not in the view, keeping the view free of validation logic.

---

### 13. Navigate Back From the Detail View

**Steps:** From any detail view, click the Back button.

**What to observe:** The detail panel is replaced by the ticket list. The list is in the same filter and search state as before the detail view was opened.

**What it demonstrates:** `CloseDetail` sets `model.selectedTicket` to `Nothing` and clears `commentBody`. The `filter` and `searchQuery` fields are separate and unaffected, so the list re-renders with the same filter applied.

---

### 14. Observe the Overdue Badge

**Steps:** Look at the ticket list on startup. Observe ticket 1 (Cannot connect to VPN), ticket 3 (Request new keyboard), and ticket 4 (Reset domain password).

**What to observe:** Ticket 1 has a grey "Due 2026-04-25" badge because its due date is after the reference date. Ticket 3 has no due date badge because `dueDate` is `Nothing`. Ticket 4 has a red "Overdue - 2026-04-23" badge because its due date is before the reference date of 2026-04-24.

**What it demonstrates:** `viewDueDateBadge` pattern matches on `Maybe String`. `Nothing` produces `text ""` and `Just due` compares the date string against `today` using `<`. This works correctly for ISO date strings because lexicographic ordering matches chronological ordering for the `YYYY-MM-DD` format. The reference date `today` is hardcoded as `"2026-04-24"` in `View.elm` - in a production application this would be retrieved from the system clock via `elm/time` and a `Task`, but this prototype avoids that dependency to keep the setup simple and the code focused on the concepts being demonstrated.

---

### 15. Observe the History Timeline

**Steps:** Click View Details on ticket 2 (Outlook crashes) or ticket 3 (Request new keyboard). Scroll to the History section.

**What to observe:** Each status transition is shown as a timeline entry with colour-coded badges for the previous and new status, and a timestamp. Ticket 3 has two entries: Open to In Progress, and In Progress to Resolved.

**What it demonstrates:** The history is stored as `List TicketHistoryEntry` on the ticket. Each entry holds `from` and `to` as `TicketStatus` values. The `viewHistoryEntry` function applies `statusClass` and `statusLabel` directly to these values, with no string parsing needed because the values are already typed.

---

### Related Files

| File                                                  | Description                                  |
| ----------------------------------------------------- | -------------------------------------------- |
| [01 - Prototype Overview](01-prototype-overview.md)   | Application features and structure           |
| [02 - Data Model](02-data-model.md)                   | Types.elm and Model.elm walkthrough          |
| [03 - Messages and Update](03-messages-and-update.md) | Msg.elm and Update.elm walkthrough           |
| [04 - View](04-view.md)                               | View.elm walkthrough                         |
| [05 - Test Scenarios](05-test-scenarios.md)           | This file                                    |
| [Prototype README](../../prototype/README.md)         | Setup and run instructions for the prototype |
| [Prototype Source](../../prototype/src/)              | All Elm source files                         |

---

<sub>Previous | [View](04-view.md)</sub> &nbsp;&nbsp;&nbsp; <sub>Next | [Resources](../99-resources/01-resources.md)</sub>
