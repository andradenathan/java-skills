---
name: java-concurrency
description: Use when Java code is shared across threads or runs asynchronously - check-then-act or get-modify-put on a shared map, lost updates, blocking get()/join() in a service, @Scheduled tasks blocking each other, Spring default thread pools, virtual threads on JDK 21/22, or throughput collapsing while thread dumps look idle
---

# Java Concurrency

| Question | File |
|---|---|
| Is this sequence of thread-safe calls actually safe? | `race-conditions.md` |
| Blocking inside an async flow | `async-composition.md` |
| Which pool does this actually run on? | `spring-thread-pools.md` |
| Virtual threads stalling on JDK 21/22 | `virtual-thread-pinning.md` |

Cancellation and `InterruptedException` live in `java-error-handling/interrupted-exception.md`; async failure handling in `java-error-handling/completablefuture-errors.md`.
