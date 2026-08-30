# Read the Fine Print on Collectors

Without `collect(...)` nothing accumulates at the end of a stream. `Collectors.toMap` turns the stream into a map — and has a runtime trap.

```java
// PROBLEM: IllegalStateException if two users share an email
Map<String, User> map = users.stream()
    .collect(Collectors.toMap(User::getEmail, u -> u));

// FIX: decide which value wins
Map<String, User> safeMap = users.stream()
    .collect(Collectors.toMap(
        User::getEmail,
        u -> u,
        (u1, u2) -> u2));      // keep the last
```

Duplicate keys throw `IllegalStateException` at runtime — no static analysis catches it, and you find out after deploy. The two-argument `toMap` is only safe when the key is genuinely unique (a primary key, a UUID), and even then a merge function documents the intent.

## Two more sharp edges

**A null value throws.** `toMap` rejects null values with a `NullPointerException`, unlike `HashMap.put`. A mapper that can return null needs filtering first.

**Order is not preserved.** `toMap` builds a `HashMap`. If the original order matters, pass the supplier:

```java
.collect(Collectors.toMap(User::getEmail, u -> u, (u1, u2) -> u2, LinkedHashMap::new));
```

## When duplicates are meaningful

If a repeated key is data rather than a conflict, `toMap` is the wrong collector — `groupingBy` keeps all of them:

```java
Map<String, List<User>> byDomain = users.stream()
    .collect(Collectors.groupingBy(User::getDomain));
```

## Red flags

- Two-argument `toMap` on a key that is not guaranteed unique
- A merge function written as `(a, b) -> a` with no thought about which one is right
- `toMap` fed by a mapper that can return null
- `toMap` where order matters and no `LinkedHashMap::new`
- A merge function used to silence an exception that was pointing at duplicate data
