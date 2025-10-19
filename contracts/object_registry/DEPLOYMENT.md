# Deployment Guide

## Quick Start

### 1. Build the Project

```bash
cd contracts/object_registry
sui move build
```

### 2. Publish to Devnet

```bash
sui client publish --gas-budget 100000000
```

### 3. Save Important Values

After publishing, you'll see output like this. Save these values:

```
Published Objects:
- Package ID: 0x<PACKAGE_ID>
- CampusRegistry (shared object): 0x<REGISTRY_ID>
```

## Usage Examples

### Register a Student

```bash
# Replace with your actual package and registry IDs
export PACKAGE_ID="0x..."
export REGISTRY_ID="0x..."

sui client call \
  --package $PACKAGE_ID \
  --module campus_registry \
  --function register \
  --args $REGISTRY_ID "Alice Johnson" "Computer Science" "CS2024001" \
  --gas-budget 10000000
```

After registration, note your `RegistrationBadge` object ID from the output.

### Create a Todo List

```bash
# Replace with your badge ID
export BADGE_ID="0x..."

sui client call \
  --package $PACKAGE_ID \
  --module todo_list \
  --function create_list \
  --args $BADGE_ID \
  --gas-budget 10000000
```

Note your `TodoList` object ID from the output.

### Add a Todo Item

```bash
# Replace with your todo list ID
export TODOLIST_ID="0x..."

sui client call \
  --package $PACKAGE_ID \
  --module todo_list \
  --function add_item \
  --args $TODOLIST_ID "Complete Move programming assignment" \
  --gas-budget 10000000
```

### Mark Item as Done

```bash
# Item ID starts from 0
sui client call \
  --package $PACKAGE_ID \
  --module todo_list \
  --function mark_done \
  --args $TODOLIST_ID 0 \
  --gas-budget 10000000
```

### Update an Item

```bash
sui client call \
  --package $PACKAGE_ID \
  --module todo_list \
  --function update_item \
  --args $TODOLIST_ID 0 "Complete Move programming assignment - UPDATED" \
  --gas-budget 10000000
```

### Remove an Item

```bash
sui client call \
  --package $PACKAGE_ID \
  --module todo_list \
  --function remove_item \
  --args $TODOLIST_ID 0 \
  --gas-budget 10000000
```

## Checking Your Objects

### View All Your Objects

```bash
sui client objects
```

### View Specific Object

```bash
sui client object <OBJECT_ID>
```

### View Your Registration Badge

```bash
sui client object $BADGE_ID
```

### View Your Todo List

```bash
sui client object $TODOLIST_ID
```

## Testing Multiple Students

You can create multiple addresses to test the multi-user scenario:

```bash
# Create a new address
sui client new-address ed25519

# Switch to the new address
sui client switch --address <NEW_ADDRESS>

# Request faucet for gas
sui client faucet

# Now register this new student
sui client call \
  --package $PACKAGE_ID \
  --module campus_registry \
  --function register \
  --args $REGISTRY_ID "Bob Smith" "Mathematics" "MATH2024002" \
  --gas-budget 10000000
```

## Troubleshooting

### "AlreadyRegistered" Error

You're trying to register an address that's already registered. Each address can only register once.

### "NotRegistered" Error

You need to register first before creating a todo list.

### Need More Gas?

```bash
sui client faucet
```

### Check Active Address

```bash
sui client active-address
```

### Switch Network

```bash
# Switch to devnet
sui client switch --env devnet

# Switch to testnet
sui client switch --env testnet
```

## Advanced: Query Functions (Read-only)

These don't cost gas and are useful for checking state:

```bash
# Check if an address is registered (requires custom script)
# Check total registered users
# Get completion percentage of a todo list
```

Note: Read-only calls require using the Sui SDK or RPC directly, not the CLI.

## Environment Variables Template

Create a `.env` file to store your IDs:

```bash
# Package and Object IDs
export PACKAGE_ID="0x..."
export REGISTRY_ID="0x..."
export BADGE_ID="0x..."
export TODOLIST_ID="0x..."

# Network
export SUI_NETWORK="devnet"
```

Then source it:

```bash
source .env
```
