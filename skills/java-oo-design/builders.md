# Builders

A builder makes an API fluent. Done well it simplifies; done badly it hides bugs.

## Mutability leaking through the builder

The most common defect: the built object keeps a direct reference to the collection the builder held.

```java
var roles = new ArrayList<>(List.of("ADMIN"));
var user = User.builder(UUID.randomUUID(), "Jane Doe").roles(roles).build();
roles.add("DEV");   // user.roles changed too
```

The fix belongs in the canonical constructor, not the builder — that way it holds no matter how the object is created:

```java
public record User(UUID id, String name, List<String> roles) {
    public User {
        Objects.requireNonNull(id, "id cannot be null");
        Objects.requireNonNull(name, "name cannot be null");
        if (name.isBlank()) throw new IllegalArgumentException("name cannot be blank");
        roles = List.copyOf(roles);          // defensive copy
    }

    public static Builder builder(UUID id, String name) {   // required fields at entry
        return new Builder(id, name);
    }
}
```

Same for arrays (`data.clone()`) and any mutable type. Prefer `java.time.*` over `Date`.

## Cross-field validation

Field-by-field checks are not enough. Rules spanning fields — `if (start.isAfter(end)) throw ...` — go in `build()` or the canonical constructor, so no path produces an inconsistent object.

## Implicit defaults hide intent

The biggest risk is a silent magic value. Instead of a builder quietly defaulting `role = "ADMIN"`, use a static factory method that names the purpose: `User.admin(id, "Jane")`.

## Lombok

`@Builder` saves typing, not responsibility. It performs no validation — the business logic still has to live in `build()`. `@Singular` allocates a new list per call (avoid in hot paths), and `@SuperBuilder` can break invariants across inheritance without revalidation.

## JSON

If the type is simple and immutable, serialize the record directly. If you need a builder, align the mapping to the contract and keep validation at the creation point — never open setters just to satisfy the serializer.

## Red flags

- A builder setter storing a caller's collection with no `List.copyOf`
- Validation in the builder's setters but not in the constructor
- A builder for a type with three fields — a canonical constructor is clearer
- A reusable builder instance — keep it disposable, one build per instance
- Optional fields with silent defaults that a factory method should name
