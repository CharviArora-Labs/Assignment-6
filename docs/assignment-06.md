# Assignment 6 – Stepwise Implementation Plan

This document outlines the complete step-by-step process followed to build the Appointment Scheduling API using Rails 8 (API mode) and PostgreSQL.

---

## Step 1 – Initialize Rails API Project

Created a new Rails API-only application:

```
rails new appointment_api --api -d postgresql
```

Configured `database.yml`, created the database, and ensured the server booted correctly.

---

## Step 2 – Generate Appointment Model

Generated the core model:

```
rails g model Appointment start_time:datetime end_time:datetime status:string
rails db:migrate
```

Verified the schema to ensure correct column creation.

---

## Step 3 – Generate Controller and Routes

Generated controller:

```
rails g controller Appointments
```

Configured RESTful routes with custom cancel action:

```ruby
resources :appointments do
  member do
    patch :cancel
  end
end
```

Implemented the following actions:

* index
* show
* create
* update
* cancel

---

## Step 4 – Add Basic Validations

Added presence validations in the model:

```ruby
validates :start_time, presence: true
validates :end_time, presence: true
validates :status, presence: true
```

Added custom validation to ensure valid time range:

```ruby
validate :end_after_start
```

Ensured that `end_time` must be after `start_time`.

---

## Step 5 – Convert Status to Enum

Replaced plain string handling with Rails enum:

```ruby
enum :status, {
  scheduled: "scheduled",
  cancelled: "cancelled"
}
```

Benefits:

* `scheduled?`
* `cancelled?`
* `cancelled!`

Added default status at DB level via migration.

---

## Step 6 – Implement Overlap Prevention

Added custom validation:

```ruby
validate :no_time_overlap, if: :scheduled?
```

Overlap logic implemented as:

```
existing.start_time < new.end_time
AND
existing.end_time > new.start_time
```

This ensures:

* No partial overlaps
* No complete overlaps
* Back-to-back appointments allowed

---

## Step 7 – Add Pagination Controls

Implemented offset-based pagination:

* 2 results per page
* Maximum 4 pages
* Requests beyond page 4 return error

Used `limit` and `offset` to control result window.

---

## Step 8 – Add Database Indexes

Created migration to add performance indexes:

* Composite index on `start_time` and `end_time`
* Index on `status`

This optimizes overlap query performance.

---

## Step 9 – Improve Cancel Logic

Implemented safe cancel action using enum bang method:

```ruby
@appointment.cancelled!
```

Prevents double cancellation and ensures clean status transitions.

---

## Step 10 – Testing Strategy

Testing performed using:

* Rails console
* curl requests
* Manual API calls

Test scenarios covered:

* Valid appointment creation
* Overlapping booking rejection
* Back-to-back booking acceptance
* Invalid time rejection
* Pagination boundaries
* Cancel functionality

---

## Final System Capabilities

The completed system supports:

* Appointment creation
* Time conflict prevention
* Controlled pagination
* Enum-based status management
* Custom cancellation route
* Database-level performance indexing
* Clean RESTful API structure

---

## Learning Outcomes

This assignment strengthened understanding of:

* Rails API-only architecture
* ActiveRecord custom validations
* Enum usage in Rails
* Offset-based pagination
* Query optimization with indexes
* RESTful route design
* Backend debugging and server process handling

---

This completes Assignment 6 implementation with production-grade structure and clean backend design.
