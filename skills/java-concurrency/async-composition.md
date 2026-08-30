# Never Block Inside Async Code

Calling `get()` or `join()` in the middle of an async flow looks harmless and defeats the entire point: the thread sits waiting, which causes thread starvation and destroys scalability.

```java
// WRONG: blocks
CompletableFuture<String> result = callExternalApi();
String data = result.get();

// RIGHT: compose
return callExternalApi().thenApply(response -> transform(response));
```

Return the `CompletableFuture` itself and the method stays asynchronous, letting the application scale without a bottleneck.

**Where to materialize:** services keep composing with `thenApply`, `thenCompose`, `thenCombine`. Only the edge — the controller — turns it into a value. Spring MVC accepts a `CompletableFuture` as a handler return type and completes the response itself, so often the edge does not block either.

Blocking is worse than it looks when the stage runs on the default executor: the common `ForkJoinPool` is shared process-wide, and a blocked worker is unavailable to everything else in the JVM. Pass your own executor for blocking work.

## Red flags

- `.get()` or `.join()` inside a `@Service`
- A method returning `String` where every operation inside it was async
- `thenApply` doing blocking I/O — that belongs in `thenComposeAsync` with a dedicated executor
- `join()` inside a loop over futures — collect them and use `allOf`

Failure handling in these chains — `exceptionally` vs `handle` vs `whenComplete` — is in `java-error-handling/completablefuture-errors.md`.
