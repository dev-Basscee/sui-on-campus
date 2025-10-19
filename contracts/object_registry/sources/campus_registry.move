module registration::campus_registry {
    use std::string::String;
    use sui::table::{Self, Table};

    /// Error codes
    const EAlreadyRegistered: u64 = 1;
    const ENotRegistered: u64 = 2;

    /// A registration badge given to users who successfully register
    /// This badge is required to create and manage todo lists
    public struct RegistrationBadge has key, store {
        id: object::UID,
        student_id: u64,
        name: String,
        department: String,
        registration_number: String,
        registration_date: u64,
    }

    /// Main campus registry - shared object accessible by anyone
    public struct CampusRegistry has key {
        id: object::UID,
        next_student_id: u64,
        // Maps address to student_id for lookup
        registered_users: Table<address, u64>,
        // Total number of registered users
        total_registered: u64,
    }

    /// One-time initialization - creates a shared registry
    fun init(ctx: &mut tx_context::TxContext) {
        let registry = CampusRegistry {
            id: object::new(ctx),
            next_student_id: 1000, // Start from 1000 for student IDs
            registered_users: table::new(ctx),
            total_registered: 0,
        };
        // Share the registry so anyone can access it
        transfer::share_object(registry);
    }

    /// Register a new user to the campus system
    /// Gives them a RegistrationBadge that allows them to use the todo system
    entry fun register(
        registry: &mut CampusRegistry,
        name: String,
        department: String,
        registration_number: String,
        ctx: &mut tx_context::TxContext
    ) {
        let sender = tx_context::sender(ctx);
        
        // Check if user is already registered
        assert!(!table::contains(&registry.registered_users, sender), EAlreadyRegistered);
        
        // Generate new student ID
        let student_id = registry.next_student_id;
        registry.next_student_id = student_id + 1;
        
        // Add to registry
        table::add(&mut registry.registered_users, sender, student_id);
        registry.total_registered = registry.total_registered + 1;
        
        // Create and transfer registration badge to user
        let badge = RegistrationBadge {
            id: object::new(ctx),
            student_id,
            name,
            department,
            registration_number,
            registration_date: tx_context::epoch(ctx),
        };
        
        transfer::transfer(badge, sender);
    }

    /// Check if an address is registered
    public fun is_registered(registry: &CampusRegistry, user: address): bool {
        table::contains(&registry.registered_users, user)
    }

    /// Get the student ID for a registered user
    public fun get_student_id(registry: &CampusRegistry, user: address): u64 {
        assert!(table::contains(&registry.registered_users, user), ENotRegistered);
        *table::borrow(&registry.registered_users, user)
    }

    /// Get total number of registered users
    public fun get_total_registered(registry: &CampusRegistry): u64 {
        registry.total_registered
    }

    /// Verify that a badge is valid (helper function for todo module)
    public fun verify_badge(badge: &RegistrationBadge): u64 {
        badge.student_id
    }

    /// Get badge details for display
    public fun get_badge_details(badge: &RegistrationBadge): (u64, String, String, String) {
        (badge.student_id, badge.name, badge.department, badge.registration_number)
    }
}