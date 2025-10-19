# System Architecture - Connected Contracts

## Overview

This project implements a **two-tier access control system** where registration is required to use the todo list functionality.

```
┌─────────────────────────────────────────────────────────────┐
│                     User (Student)                          │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
         ┌─────────────────────────┐
         │  1. Register via        │
         │  CampusRegistry         │
         │  (shared object)        │
         └────────────┬────────────┘
                      │
                      ▼
         ┌─────────────────────────┐
         │  Receive                │
         │  RegistrationBadge NFT  │◄─── Proof of Registration
         └────────────┬────────────┘
                      │
                      ▼
         ┌─────────────────────────┐
         │  2. Create TodoList     │
         │  (requires badge)       │
         └────────────┬────────────┘
                      │
                      ▼
         ┌─────────────────────────┐
         │  Manage Todo Items      │
         │  (owns todo list)       │
         └─────────────────────────┘
```

## Contract 1: Campus Registry

**File**: `campus_registry.move`
**Module**: `registration::campus_registry`

### Purpose
Acts as a **registration authority** for the campus system. It's the entry point for all users.

### Key Components

#### Shared Object: `CampusRegistry`
```move
struct CampusRegistry has key {
    id: UID,
    next_student_id: u64,           // Counter for unique IDs
    registered_users: Table<address, u64>,  // Maps address -> student ID
    total_registered: u64,          // Total count
}
```

- **Shared Object**: Anyone can interact with it
- **Single Instance**: Created once during `init`
- **Persistent**: Stores all registrations

#### NFT Badge: `RegistrationBadge`
```move
struct RegistrationBadge has key, store {
    id: UID,
    student_id: u64,
    name: String,
    department: String,
    registration_number: String,
    registration_date: u64,
}
```

- **NFT**: Unique, owned by the registered user
- **Proof of Registration**: Required to create todo lists
- **Contains Identity**: Stores student information

### Flow

1. User calls `register()` with their info
2. System checks they're not already registered
3. Assigns unique `student_id` (auto-incremented from 1000)
4. Creates and transfers `RegistrationBadge` to user
5. Records registration in shared `CampusRegistry`

### Security

✅ **Prevents duplicate registrations** - One badge per address
✅ **Unique student IDs** - Auto-incremented counter
✅ **Shared access** - Anyone can register
✅ **Permanent record** - Can't delete registrations

## Contract 2: Todo List

**File**: `todo-list.move`
**Module**: `registration::todo_list`

### Purpose
Provides **personal task management** for registered students only.

### Key Components

#### Personal Object: `TodoList`
```move
struct TodoList has key, store {
    id: UID,
    student_id: u64,               // Links to RegistrationBadge
    items: VecMap<u64, TodoItem>,  // Map of todo items
    next_id: u64,                  // Counter for item IDs
    total_completed: u64,          // Completion tracking
}
```

- **Owned Object**: Belongs to one user
- **Multiple Instances**: Each student can have their own
- **Linked**: Contains `student_id` from badge

#### Todo Item: `TodoItem`
```move
struct TodoItem has store, drop, copy {
    description: String,
    completed: bool,
    created_at: u64,
}
```

- **Stored in VecMap**: Efficient key-value storage
- **Copyable**: Can be duplicated if needed
- **Droppable**: Can be removed easily

### Flow

1. User must have `RegistrationBadge` (from Contract 1)
2. Calls `create_list()` passing their badge
3. System verifies badge via `campus_registry::verify_badge()`
4. Extracts `student_id` from badge
5. Creates `TodoList` linked to that `student_id`
6. Transfers todo list to user

### Operations

- ✅ **Add** todo items
- ✅ **Update** item descriptions  
- ✅ **Mark done/undone**
- ✅ **Remove** items
- ✅ **Track completion** percentage

### Security

✅ **Registration required** - Must have valid badge
✅ **Badge verification** - Calls `verify_badge()`
✅ **Ownership model** - Each user owns their list
✅ **Linked identity** - `student_id` ties list to student

## Connection Mechanism

### How Contract 2 Depends on Contract 1

```move
// In todo_list.move
use registration::campus_registry::{Self, RegistrationBadge};

public entry fun create_list(
    badge: &RegistrationBadge,  // ← Requires badge from Contract 1
    ctx: &mut TxContext
) {
    // Verify badge is valid
    let student_id = campus_registry::verify_badge(badge);
    
    // Use student_id to create linked todo list
    let list = TodoList {
        id: object::new(ctx),
        student_id,  // ← Links to registration
        // ...
    };
}
```

### Cross-Module Function Call

```move
// Exported from campus_registry.move
public fun verify_badge(badge: &RegistrationBadge): u64 {
    badge.student_id  // Returns the student ID
}
```

This is a **public function** that:
- Takes a reference to `RegistrationBadge`
- Returns the `student_id`
- Proves the badge is valid (if it exists, it's valid)

## Data Flow Diagram

```
Registration Flow:
==================
User Address
    │
    ├──► CampusRegistry.register()
    │         │
    │         ├──► Check: !already_registered()
    │         ├──► Generate: student_id = next_id++
    │         ├──► Store: registered_users[address] = student_id
    │         └──► Create & Transfer: RegistrationBadge
    │
    └──► Receives: RegistrationBadge NFT


Todo List Creation Flow:
========================
User (with Badge)
    │
    ├──► TodoList.create_list(badge)
    │         │
    │         ├──► Verify: campus_registry::verify_badge(badge)
    │         ├──► Extract: student_id from badge
    │         ├──► Create: TodoList with student_id
    │         └──► Transfer: TodoList to user
    │
    └──► Receives: TodoList object


Managing Todos:
===============
User (owns TodoList)
    │
    ├──► add_item(list, description)
    ├──► mark_done(list, item_id)
    ├──► update_item(list, item_id, description)
    └──► remove_item(list, item_id)
```

## Access Control Matrix

| Action | CampusRegistry | RegistrationBadge | TodoList | Notes |
|--------|---------------|-------------------|----------|-------|
| Register | ✅ Anyone | ❌ N/A | ❌ N/A | Public shared object |
| Create List | ❌ N/A | ✅ Required | ❌ N/A | Must pass badge reference |
| Add Todo | ❌ N/A | ❌ N/A | ✅ Owner only | Must own the list |
| Mark Done | ❌ N/A | ❌ N/A | ✅ Owner only | Must own the list |
| View Registry | ✅ Anyone | ❌ N/A | ❌ N/A | Read-only queries |

## Object Ownership Model

```
Shared Objects (Anyone can access):
├── CampusRegistry (one instance)

Owned Objects (Specific user owns):
├── RegistrationBadge (one per registered user)
└── TodoList (zero or more per user)
```

## Benefits of This Architecture

### 1. **Separation of Concerns**
- Registration logic separate from todo logic
- Each module has clear responsibility
- Easy to maintain and extend

### 2. **Access Control**
- Only registered users can use todo system
- Badge acts as proof of registration
- Can't fake registration (blockchain-verified)

### 3. **Scalability**
- Registry is shared (gas-efficient)
- Todo lists are personal (parallel processing)
- No bottlenecks in todo operations

### 4. **Auditability**
- All registrations recorded on-chain
- Todo lists linked to student IDs
- Transparent and verifiable

### 5. **Extensibility**
- Can add more modules requiring badges
- Badge can unlock other campus features
- Easy to add new student services

## Potential Extensions

1. **Assignment Submission**
   - Require badge to submit work
   - Link submissions to student ID

2. **Grade Management**
   - Professors post grades
   - Students view with badge

3. **Library System**
   - Borrow books with badge
   - Track borrowing history

4. **Event Registration**
   - Campus events require badge
   - Track attendance

5. **Reputation System**
   - Award points for completing todos
   - Build student reputation on-chain

## Security Considerations

### Implemented ✅

- Duplicate registration prevention
- Badge ownership verification
- Object access control
- Immutable student IDs

### Future Enhancements 🔄

- Badge expiration (for graduated students)
- Role-based access (admin, student, professor)
- Multi-signature for sensitive operations
- Badge revocation mechanism

## Conclusion

This architecture demonstrates:
- **Modular design** - Two contracts working together
- **Access control** - NFT-based permissions
- **Practical use case** - Real-world campus scenario
- **Blockchain benefits** - Transparency, ownership, immutability

The registration requirement creates a **gated system** where only verified students can use campus services, while keeping each service (like todo lists) independent and scalable.
