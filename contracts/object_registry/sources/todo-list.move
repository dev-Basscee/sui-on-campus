module todo_list::todo {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::string::String;
    use sui::vec_map::{Self, VecMap};

    // Struct representing a single todo item
    public struct TodoItem has store, copy, drop {
        description: String,
        completed: bool,
    }

    // Struct representing the todo list
    public struct TodoList has key, store {
        id: UID,
        items: VecMap<u64, TodoItem>,
        next_id: u64,
    }

    // Create a new todo list
    public entry fun create_list(ctx: &mut TxContext) {
        let list = TodoList {
            id: object::new(ctx),
            items: vec_map::empty(),
            next_id: 0,
        };
        transfer::transfer(list, tx_context::sender(ctx));
    }

    // Add a new item to the todo list
    public entry fun add_item(
        list: &mut TodoList,
        description: String,
    ) {
        let item = TodoItem {
            description,
            completed: false,
        };
        vec_map::insert(&mut list.items, list.next_id, item);
        list.next_id = list.next_id + 1;
    }

    // Remove an item from the todo list
    public entry fun remove_item(
        list: &mut TodoList,
        item_id: u64,
    ) {
        vec_map::remove(&mut list.items, &item_id);
    }

    // Mark an item as completed
    public entry fun mark_done(
        list: &mut TodoList,
        item_id: u64,
    ) {
        let item = vec_map::get_mut(&mut list.items, &item_id);
        item.completed = true;
    }
}