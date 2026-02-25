# Appointment Scheduling API – Assignment 6

A Rails 8 API-only application that manages appointment scheduling with:

- Time overlap prevention
- Enum-based status management
- Pagination (2 results per page, max 4 pages)
- Clean cancellation logic
- PostgreSQL database
- Production-ready validations

---

## Tech Stack

- Ruby on Rails 8 (API mode)
- PostgreSQL
- Puma
- ActiveRecord

---

## Features

### Create Appointment
- Requires `start_time` and `end_time`
- Automatically defaults `status` to `scheduled`

### Prevent Time Overlap
Prevents overlapping appointments using this logic:


existing.start_time < new.end_time
AND
existing.end_time > new.start_time


Back-to-back appointments are allowed.

---

### Status Enum

```ruby
enum :status, {
  scheduled: "scheduled",
  cancelled: "cancelled"
}

Provides:

scheduled?

cancelled?

cancelled!

Cancel Appointment

Custom route:

PATCH /appointments/:id/cancel

If already cancelled → returns error
Else → updates status to cancelled

Pagination Rules

2 results per page

Maximum 4 pages allowed

Requests beyond page 4 return error

Example:

GET /appointments?page=1

Response:

{
  "data": [...],
  "meta": {
    "page": 1,
    "per_page": 2,
    "total": 10,
    "max_pages": 4
  }
}
📂 API Endpoints
Method	Endpoint	Description
GET	/appointments	List appointments
GET	/appointments/:id	Show appointment
POST	/appointments	Create appointment
PATCH	/appointments/:id	Update appointment
PATCH	/appointments/:id/cancel	Cancel appointment


Example Create Request
curl -X POST http://localhost:3000/appointments \
  -H "Content-Type: application/json" \
  -d '{
    "appointment": {
      "start_time": "2026-02-25T10:00:00",
      "end_time": "2026-02-25T11:00:00"
    }
  }'


Database Schema
create_table "appointments" do |t|
  t.datetime "start_time"
  t.datetime "end_time"
  t.string   "status"
  t.datetime "created_at"
  t.datetime "updated_at"
end

Indexes:

start_time + end_time

status

Setup Instructions

Clone repo

Run:

bundle install
rails db:create
rails db:migrate
rails s

Visit:

http://localhost:3000/appointments


## Key Design Decisions

Used enum for clean status handling

Used model-level validation for overlap protection

Added database indexes for performance

Limited pagination intentionally for API boundary control

Built API in Rails API-only mode for lightweight backend