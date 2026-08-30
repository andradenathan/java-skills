# Optional and Absent Values

**Return an empty collection, never null.** `Collections.emptyList()` (or `List.of()`) removes an entire class of NPEs, because the caller can iterate unconditionally.

For a single value that may be absent, `Optional<T>` states it in the type.

## Checking

```java
// Fail fast with a clear message — for what must not be null
Objects.requireNonNull(user, "User must not be null");
sendWelcomeEmail(user);

// Act only if present
Optional.ofNullable(user).ifPresent(this::sendWelcomeEmail);
```

Be honest about the third form: for a single check, `if (user != null) { ... }` is just as clear, and wrapping a value in an `Optional` only to unwrap it immediately adds an allocation and a step. `Optional.ofNullable` earns its place when the value continues through a chain, not as a decorated `if`.

## Chained fallbacks

`or()` (Java 9+) composes alternatives lazily — each is evaluated only if the previous was empty:

```java
Optional<String> result = findFromCache()
    .or(() -> findFromDatabase())
    .or(() -> Optional.of("default"));
```

That replaces a stack of nested `if`s. See `supplier-and-consumer.md` for why `orElseGet` and `or` take suppliers while `orElse` does not.

## Where Optional does not belong

`Optional` was designed as a **return type**. Avoid it as a field (it is not `Serializable` and adds an object per instance), as a method parameter (the caller now has three states to pass: value, empty, null), and in collections — an empty list already expresses absence.

## Red flags

- A method returning `null` instead of an empty collection
- `optional.get()` without `isPresent()` — use `orElseThrow()`
- `Optional<T>` as a field or a parameter
- `Optional.ofNullable(x).ifPresent(...)` where a plain null check reads better
- Nested `if` chains testing successive fallback sources
