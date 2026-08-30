# Do Not Create Objects Unnecessarily

In high-volume code the cost of pointless allocation is invisible at first — it works — and shows up later as GC pressure and lost throughput. Think twice before instantiating inside a large loop.

```java
// BAD: recompiles the regex on every call
boolean isValidEmail(String email) {
    return email.matches("^[\\w.%+-]+@[\\w.-]+\\.[A-Za-z]{2,6}$");
}

// GOOD: compile once, reuse
private static final Pattern EMAIL_PATTERN =
        Pattern.compile("^[\\w.%+-]+@[\\w.-]+\\.[A-Za-z]{2,6}$");

boolean isValidEmail(String email) {
    return EMAIL_PATTERN.matcher(email).matches();
}
```

A validator running over thousands of rows recompiles that regex on every iteration. `Pattern` is immutable and thread-safe, so a `static final` field is safe and eliminates thousands of temporary objects.

## The usual suspects

| Created repeatedly | Why it hurts | Where it belongs |
|---|---|---|
| `String.matches(...)` | compiles the regex per call | `static final Pattern` |
| `new ObjectMapper()` | expensive to build; thread-safe once configured | a singleton or Spring bean |
| `new Random()` / `new SecureRandom()` | seeding cost; `Random` is contended across threads | `ThreadLocalRandom.current()`, or a shared `SecureRandom` |
| `DateTimeFormatter.ofPattern(...)` | immutable and thread-safe | `static final` |

Note the one that is **not** on that list: `SimpleDateFormat` is mutable and *not* thread-safe. Hoisting it into a `static final` field is a data-corruption bug, not an optimization — use `DateTimeFormatter` instead.

Only hoist objects that are immutable or documented thread-safe. Otherwise you trade allocation for a race condition.

## Red flags

- `String.matches`, `String.split` or `Pattern.compile` inside a loop
- `new ObjectMapper()` in a method body
- A `static final SimpleDateFormat` or `Calendar`
- Boxing in a hot numeric loop (`java-functional-style/primitive-functional-interfaces.md`)
- Optimizing allocation with no profile — measure first
