module registration::object_registry {
    use std::vector;
    use sui::object;
    use sui::tx_context as tx_context;
    use sui::tx_context::TxContext;
use sui::transfer;

/// A simple struct to hold the object fields. Not a resource.
    struct CampusObject has store { 
        id: u64,
        name: vector<u8>,
        department: vector<u8>,
        registration_number: vector<u8>,
    }

    /// Registry object stored on Sui. Contains a UID, a counter and a vector of objects.
    struct Registry has key {
        id: object::UID,
        next_id: u64,
        objects: vector<CampusObject>,
    }

    /// Initialize a new Registry object and transfer it to the transaction sender.
    public entry fun init_registry(ctx: &mut TxContext) {
        let registry = Registry {
            id: object::new(ctx),
            next_id: 1,
            objects: vector::empty<CampusObject>(),
        };
        transfer::transfer(registry, tx_context::sender(ctx));
    }

    /// Create a new object; id is auto-generated and the object is appended to the Registry.objects vector.
    /// Returns the assigned id.
    public entry fun create_object(registry: &mut Registry, name: vector<u8>, department: vector<u8>, registration_number: vector<u8>): u64 {
        let id = registry.next_id;
        registry.next_id = id + 1;
        let obj = CampusObject { id, name, department, registration_number };
        vector::push_back<CampusObject>(&mut registry.objects, obj);
        id
    }

    /// Get how many objects are stored in the given registry.
    public fun object_count(registry: &Registry): u64 {
        vector::length(&registry.objects)
    }

    // Note: Reading objects' fields by value (without removing them) requires copying complex types
    // which is non-trivial in Move. For simplicity this package focuses on creating and counting objects.
    // Extensions can add indexed lookup utilities (e.g., remove or return clones) using std libraries.

}