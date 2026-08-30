# Catch What the try Can Throw

`catch (Exception e)` looks practical. The problem is not that it catches "everything" — it is that it catches far more than the code in the `try` can actually throw, including `RuntimeException` subclasses that signal bugs.

```java
// AVOID: the only real risk here is DateTimeParseException.
try {
    var expiry = LocalDate.parse(raw, DATE_FORMAT);
    return new Promotion(code, expiry);
} catch (Exception e) {
    throw new IllegalArgumentException(
        "Expected valid date, but got '%s' for promotion '%s'".formatted(raw, code), e);
}

// USE
} catch (DateTimeParseException e) {
    throw new IllegalArgumentException(
        "Expected valid date, but got '%s' for promotion '%s'".formatted(raw, code), e);
}
```

If `DATE_FORMAT` is null from an initialization bug, the generic version repackages a `NullPointerException` as `IllegalArgumentException`. The team investigates a format error while the real cause is an uninitialized field. The original cause is still chained, but the type exposed at the boundary now lies.

Need more than one? Use multi-catch (Java 7+): `catch (DateTimeParseException | NumberFormatException e)`.

## Red flags

- `catch (Exception e)` where the `try` throws one specific checked exception
- `catch (Throwable)` — that reaches `Error`: `OutOfMemoryError`, `StackOverflowError`, failures you cannot handle and must not absorb
- A catch block copied from elsewhere in the codebase without checking what the `try` throws
- A caught `RuntimeException` that was never expected — it is a bug, and catching it hides it
