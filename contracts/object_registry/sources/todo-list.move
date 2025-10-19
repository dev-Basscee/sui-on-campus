module registration::todo_list {
    use std::string::String;
    use sui::vec_map::{Self, VecMap};
    use registration::campus_registry::{Self, RegistrationBadge};

    /// Struct representing a single todo item
    public struct TodoItem has store, drop, copy {
        description: String,
        completed: bool,
        created_at: u64,
    }

    /// Struct representing the todo list - now linked to a student
    public struct TodoList has key, store {
        id: object::UID,
        student_id: u64,  // Links to the registration badge
        items: VecMap<u64, TodoItem>,
        next_id: u64,
        total_completed: u64,
    }

    /// Create a new todo list - requires a valid RegistrationBadge
    /// This ensures only registered students can create todo lists
    entry fun create_list(
        badge: &RegistrationBadge,
        ctx: &mut tx_context::TxContext
    ) {
        // Verify the badge and get student ID
        let student_id = campus_registry::verify_badge(badge);
        
        let list = TodoList {
            id: object::new(ctx),
            student_id,
            items: vec_map::empty(),
            next_id: 0,
            total_completed: 0,
        };
        
        transfer::transfer(list, tx_context::sender(ctx));
    }

    /// Add a new item to the todo list
    entry fun add_item(
        list: &mut TodoList,
        description: String,
        ctx: &tx_context::TxContext,
    ) {
        let item = TodoItem {
            description,
            completed: false,
            created_at: tx_context::epoch(ctx),
        };
        vec_map::insert(&mut list.items, list.next_id, item);
        list.next_id = list.next_id + 1;
    }

    /// Remove an item from the todo list
    entry fun remove_item(
        list: &mut TodoList,
        item_id: u64,
    ) {
        let (_, item) = vec_map::remove(&mut list.items, &item_id);
        
        // If the removed item was completed, decrease the counter
        if (item.completed) {
            list.total_completed = list.total_completed - 1;
        };
    }

    /// Mark an item as completed
    entry fun mark_done(
        list: &mut TodoList,
        item_id: u64,
    ) {
        let item = vec_map::get_mut(&mut list.items, &item_id);
        
        // Only increment counter if it wasn't already completed
        if (!item.completed) {
            item.completed = true;
            list.total_completed = list.total_completed + 1;
        };
    }

    /// Mark an item as not completed (undo)
    entry fun mark_undone(
        list: &mut TodoList,
        item_id: u64,
    ) {
        let item = vec_map::get_mut(&mut list.items, &item_id);
        
        // Only decrement counter if it was completed
        if (item.completed) {
            item.completed = false;
            list.total_completed = list.total_completed - 1;
        };
    }

    /// Update the description of an existing todo item
    entry fun update_item(
        list: &mut TodoList,
        item_id: u64,
        new_description: String,
    ) {
        let item = vec_map::get_mut(&mut list.items, &item_id);
        item.description = new_description;
    }

    /// Get the student ID associated with this todo list
    public fun get_student_id(list: &TodoList): u64 {
        list.student_id
    }

    /// Get total number of items in the list
    public fun get_total_items(list: &TodoList): u64 {
        vec_map::length(&list.items)
    }

    /// Get total number of completed items
    public fun get_total_completed(list: &TodoList): u64 {
        list.total_completed
    }

    /// Get completion percentage (returns value 0-100)
    public fun get_completion_percentage(list: &TodoList): u64 {
        let total = vec_map::length(&list.items);
        if (total == 0) {
            return 0
        };
        (list.total_completed * 100) / total
    }
}