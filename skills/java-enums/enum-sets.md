# EnumSet for Permissions

When every element of a set comes from the same enum, the idiomatic choice is `EnumSet`, not `HashSet` — a bit vector internally, and it gives set algebra that reads as the business rule.

| Operation | Call |
|---|---|
| union of roles | `addAll` |
| revoke | `removeAll` |
| full authorization check | `containsAll` |
| admin profile | `EnumSet.allOf(Permission.class)` |
| empty start | `EnumSet.noneOf(Permission.class)` |
| explicitly denied | `EnumSet.complementOf(...)` |

Conditionals stack up; these do not.

## The trap: EnumSet is mutable

```java
// AVOID: stores the received reference and leaks it
enum Role {
    EDITOR(new HashSet<>(List.of(READ, WRITE, PUBLISH)));

    private final Set<Permission> permissions;
    Role(HashSet<Permission> permissions) { this.permissions = permissions; }
    public Set<Permission> permissions() { return permissions; }  // caller can mutate
}

// USE: defensive copy + unmodifiable view
enum Role {
    READER(EnumSet.of(READ)),
    EDITOR(EnumSet.of(READ, WRITE, PUBLISH));

    private final Set<Permission> permissions;
    Role(EnumSet<Permission> permissions) {
        this.permissions = Collections.unmodifiableSet(EnumSet.copyOf(permissions));
    }
    public Set<Permission> permissions() { return permissions; }
}
```

Both halves matter: `copyOf` cuts the caller's reference to the set you were handed, `unmodifiableSet` stops the getter from handing yours out. Either one alone still leaks.

`EnumSet` rejects `null` — inserting one throws `NullPointerException`.

## Red flags

- `HashSet<SomePermission>` where every element is that enum
- A getter returning an `EnumSet` field directly
- Permission logic as chained `if`s instead of `containsAll` / `addAll`
- `EnumSet.copyOf` on an empty non-EnumSet collection — it cannot infer the enum type and throws
