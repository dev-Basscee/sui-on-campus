# Sui On Campus - Connected Registration & Todo System

A decentralized campus management system built on Sui blockchain, featuring student registration and personal todo list management.

## 📋 Overview

This project consists of two connected smart contracts:

1. **Campus Registry** (`campus_registry.move`) - A registration system for students
2. **Todo List** (`todo_list.move`) - A personal task management system that requires registration

## 🔗 How They Connect

The system enforces that **only registered students can create todo lists**:

1. Students first register via the `CampusRegistry` 
2. Registration gives them a `RegistrationBadge` NFT
3. The badge is required to create a `TodoList`
4. Each todo list is linked to the student's ID from their badge

## 🏗️ Architecture

### Campus Registry Module

**Purpose**: Manages student registrations on campus

**Key Features**:
- Shared registry accessible by all
- Issues unique student IDs (starting from 1000)
- Gives students a `RegistrationBadge` NFT upon registration
- Tracks all registered students
- Prevents duplicate registrations

**Main Functions**:
- `register()` - Register a new student with name, department, and registration number
- `is_registered()` - Check if an address is registered
- `get_student_id()` - Get the student ID for a registered user
- `verify_badge()` - Verify a registration badge is valid

### Todo List Module

**Purpose**: Personal task management for registered students

**Key Features**:
- Requires `RegistrationBadge` to create a list
- Each todo list is linked to a student ID
- Track completion status and percentage
- Timestamp each todo item creation
- Full CRUD operations on tasks

**Main Functions**:
- `create_list()` - Create a new todo list (requires badge)
- `add_item()` - Add a new todo item
- `mark_done()` - Mark an item as completed
- `mark_undone()` - Unmark a completed item
- `update_item()` - Update item description
- `remove_item()` - Delete a todo item
- `get_completion_percentage()` - Get % of completed tasks

## 🚀 Getting Started

### Prerequisites

- Sui CLI installed (v1.58.3 or higher)
- Sui client configured for devnet
- Some SUI tokens for gas fees

### Installation

```bash
# Navigate to the contracts directory
cd contracts/object_registry

# Build the contracts
sui move build

# Run tests (optional)
sui move test
```

### Deployment

```bash
# Publish to Sui devnet
sui client publish --gas-budget 100000000
```

After publishing, save the following from the output:
- `CampusRegistry` package object ID
- Package ID for the published modules

## 📖 Usage Guide

### Step 1: Register as a Student

First, register yourself in the campus system:

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module campus_registry \
  --function register \
  --args <REGISTRY_OBJECT_ID> "John Doe" "Computer Science" "CS2024001" \
  --gas-budget 10000000
```

This will give you a `RegistrationBadge` NFT.

### Step 2: Create Your Todo List

Use your registration badge to create a todo list:

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module todo_list \
  --function create_list \
  --args <YOUR_BADGE_OBJECT_ID> \
  --gas-budget 10000000
```

### Step 3: Add Todo Items

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module todo_list \
  --function add_item \
  --args <YOUR_TODOLIST_OBJECT_ID> "Complete blockchain assignment" \
  --gas-budget 10000000
```

### Step 4: Mark Items as Done

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module todo_list \
  --function mark_done \
  --args <YOUR_TODOLIST_OBJECT_ID> 0 \
  --gas-budget 10000000
```

## 🎯 Use Cases

1. **Campus Management**: Universities can track registered students
2. **Task Tracking**: Students manage their academic tasks on-chain
3. **Verification**: Prove student status with NFT badge
4. **Analytics**: Track completion rates and productivity
5. **Decentralized Identity**: Student registration on blockchain

## 🔒 Security Features

- **Registration Required**: Only registered students can create todo lists
- **Badge Verification**: Registration badge must be valid
- **Duplicate Prevention**: Cannot register same address twice
- **Ownership**: Each student owns their own todo list and badge

## 📊 Data Structures

### CampusRegistry
- `next_student_id`: Counter for unique IDs
- `registered_users`: Maps addresses to student IDs
- `total_registered`: Total count of students

### RegistrationBadge
- `student_id`: Unique identifier
- `name`: Student name
- `department`: Academic department
- `registration_number`: Official registration ID
- `registration_date`: When registered (epoch)

### TodoList
- `student_id`: Links to registration
- `items`: Map of todo items
- `next_id`: Counter for item IDs
- `total_completed`: Completion tracking

### TodoItem
- `description`: Task description
- `completed`: Status flag
- `created_at`: Creation timestamp

## 🛠️ Development

### Build
```bash
sui move build
```

### Test
```bash
sui move test
```

### Clean
```bash
sui move clean
```

## 📝 License

MIT

## 👥 Authors

- dev-Basscee

## 🤝 Contributing

Contributions welcome! Please feel free to submit a Pull Request.
