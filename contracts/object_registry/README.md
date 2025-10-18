# Object Registry (Sui Move)

This package implements a simple on-chain registry for campus objects. Each object stores:
- id (auto-generated u64)
- name (bytes)
- department (bytes)
- registration_number (bytes)

Design notes:
- The registry is stored as a `Registry` resource under an address.
- `init_registry` must be called once per address to create the registry resource.
- `create_object` appends a new object and returns the auto-assigned id.
- `object_count` returns how many objects the caller has stored.

Example (pseudo-client):

- To initialize the registry for your signer address, call the entry function `init_registry`.
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
