# Object Registry (Sui Move)

This package implements a simple on-chain registry for campus objects on Sui. Each object stores:
- id (auto-generated u64)
- name (bytes)
- department (bytes)
- registration_number (bytes)

Design notes:
- The registry is a Sui object `Registry` with a UID. You call `init_registry` to create it and it will be transferred to you.
- `create_object` mutably borrows your `Registry` and appends a new object, returning the auto-assigned id.
- `object_count` returns how many objects are stored in a given registry.

Example (pseudo-client):

- To initialize the registry, call the entry function `init_registry` to create a new `Registry` object.
- To create an object, call `create_object` with the UTF-8 bytes of the strings, e.g., for "Alice":

  - name: [65,108,105,99,101]
  - department: [67,83,69]
  - registration_number: [49,50,51,52]

Build:
- This is a Sui Move package. Use the Sui Move toolchain to build and publish.
- Example: `sui move build` within the package directory.

Notes:
- This is a small, intentionally simple example. For production you might want to:
  - Use UTF-8 string helpers or convert strings to vector<u8> in client code.
  - Add access controls, indexing, and query helpers.
