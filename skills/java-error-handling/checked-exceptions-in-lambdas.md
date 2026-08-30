# Checked Exceptions in Lambdas

The standard functional interfaces — `Function`, `Consumer`, `Supplier` — declare no checked exceptions. So when code inside a `map()` or `forEach()` throws `IOException`, the reflex is a local try/catch. That reflex usually degrades the pipeline's contract.

```java
// AVOID: hides the failure and corrupts the pipeline with null
var orders = paths.stream()
    .map(path -> {
        try {
            return mapper.readValue(Files.readString(path), OrderDto.class);
        } catch (IOException e) {
            log.warn("Error reading {}", path, e);
            return null;
        }
    })
    .filter(Objects::nonNull)

// USE: translate with context, preserve the cause
    .map(path -> {
        try {
            return mapper.readValue(Files.readString(path), OrderDto.class);
        } catch (IOException e) {
            throw new UncheckedIOException("Failed reading " + path, e);
        }
    })
    .toList();
```

Catching, logging and returning `null` turns an operational failure into an absent value. `filter(Objects::nonNull)` then removes it and the stream continues as if nothing happened. The result type is still correct, but its semantic integrity is gone: the caller receives an apparently valid list that may be silently incomplete.

`UncheckedIOException` exists in the JDK precisely for this translation.

## Options, in order

1. **Do the risky work outside the pipeline** — a plain loop can throw checked exceptions and `return` (see `java-functional-style/for-loop-against-streams.md`).
2. **Translate to unchecked** with context and cause, as above.
3. **Model failure as a value** if partial results are genuinely wanted — a `Result` per element, then partition successes from failures explicitly (`result-pattern.md`). Never `null`.

## Red flags

- `return null` inside a `map`, followed by `filter(Objects::nonNull)`
- `catch` + `log` + continue inside a pipeline
- A "sneaky throws" helper that smuggles a checked exception past the compiler
- A list whose size silently depends on how many elements failed
