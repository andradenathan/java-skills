# CompletableFuture: Failure Is a Result

In async code, an exception does not travel up the call stack looking for a `catch`. It becomes part of the stage's state — an **exceptional completion** — which can then be observed, transformed, recovered or propagated. `thenApply` and `thenCompose` simply do not run unless an earlier step recovers the failure.

## Three roles, not interchangeable

| Method | Role | Changes the result? |
|---|---|---|
| `exceptionally(ex -> ...)` | **recovers** — supplies an alternative value so the chain continues | yes |
| `handle((val, ex) -> ...)` | **transforms** — sees both outcomes, returns a new value | yes |
| `whenComplete((val, ex) -> ...)` | **observes** — side effects: logs, metrics | no |

```java
// AVOID: whenComplete does not recover.
// It logs, then join() still throws CompletionException.
String result = future
    .whenComplete((val, ex) -> { if (ex != null) log.error("Failure", ex); })
    .join();

// USE: each step with a defined role
String result = CompletableFuture
    .supplyAsync(() -> fetchFromDb(id), dbExecutor)
    .orTimeout(5, TimeUnit.SECONDS)
    .exceptionally(ex -> {
        log.error("Failure [id=%s]".formatted(id), ex);
        return "unknown";
    })
    .join();
```

Put the wrong one in place and nothing fails to compile — the whole chain's runtime behavior changes. When the roles blur, a log becomes a fallback and a fallback becomes a log.

## Two more traps

**Catching inside `supplyAsync` and returning `null`.** That replaces the exceptional completion with an invalid normal result, and the chain runs on until it resurfaces as a `NullPointerException` with no apparent link to the real cause.

**The wrapper type differs by accessor.** `join()` throws `CompletionException`; `get()` throws `ExecutionException`. Both wrap the original — a `catch` written for one will not match the other, and the cause you want is `e.getCause()`.

Blocking work needs its own executor, as in `supplyAsync(..., dbExecutor)`. The default is the common `ForkJoinPool`, shared process-wide.

## Red flags

- `whenComplete` used as recovery
- `catch` inside `supplyAsync` returning `null`
- `catch (CompletionException e)` around a `get()`, or vice versa
- `supplyAsync` with no explicit executor on blocking work
- A chain whose stages silently never ran
