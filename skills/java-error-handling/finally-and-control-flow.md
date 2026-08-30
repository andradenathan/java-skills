# No Control Flow in finally

`finally` exists for cleanup. Put a `return` in it and any exception propagating from the `try` or the `catch` is **discarded**. The caller gets the value normally and never learns something failed. Even on the happy path, the `finally` return overwrites what the `try` would have returned.

```java
// AVOID: the exception vanishes; the caller receives "unknown"
String findName(Long id) {
    try {
        return repository.findById(id).getName();
    } catch (DataAccessException e) {
        throw new InfrastructureException("Failed fetching id=%d".formatted(id), e);
    } finally {
        return "unknown";
    }
}

// USE: finally does not divert the flow; the exception propagates
String findName(Long id) {
    try {
        return repository.findById(id).getName();
    } catch (DataAccessException e) {
        throw new InfrastructureException("Failed fetching id=%d".formatted(id), e);
    } finally {
        connection.close();
    }
}
```

It compiles with no warning. Unlike an empty `catch`, which at least raises suspicion in review, a `return` here has no visual signal that it is swallowing a failure. PMD, SpotBugs and SonarQube all have dedicated rules for it — without static analysis a codebase can carry the bug for years. It usually arrives via a rushed refactor or a forgotten debug line.

The same applies to `break`, `continue`, and to **throwing** from `finally`: a new exception raised there replaces the one in flight, and the original is lost with no `getSuppressed` record.

## Prefer try-with-resources

For the actual job — closing resources, releasing locks — `try (var connection = open()) { ... }` closes in the right order, keeps the primary exception, and records a close failure as a *suppressed* exception instead of overwriting it. A manual `finally { close(); }` gets that wrong on both counts.

## Red flags

- `return`, `break` or `continue` inside `finally`
- `throw` inside `finally`
- A method returning a fallback value where an exception was expected
- `finally { resource.close(); }` where try-with-resources applies
