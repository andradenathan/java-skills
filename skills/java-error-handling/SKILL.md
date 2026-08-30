---
name: java-error-handling
description: Use when deciding how a Java failure travels - catch(Exception), empty catch blocks, log-and-throw, wrapping and rethrowing, return inside finally, validation placement, checked exceptions inside a stream, InterruptedException, CompletableFuture exceptionally/handle/whenComplete, retry policy, or a Result type for expected domain outcomes
---

# Java Error Handling

Most failures in this area are silent: the code compiles, runs, and loses the evidence.

**Design — is this even an exception?**

| Question | File |
|---|---|
| Expected domain outcome, or a real exception? | `result-pattern.md` |
| Where do invalid arguments get rejected? | `fail-fast.md` |
| Is retrying this worth anything? | `retry-transient-failures.md` |

**Catching and rethrowing**

| Question | File |
|---|---|
| Which exception should this `catch` name? | `catching-specifically.md` |
| Should I wrap this in my own exception type? | `exception-translation.md` |
| Where does the error get logged? | `log-and-throw.md` |
| Is it ever OK to swallow one? | `empty-catch.md` |
| Cleanup blocks, `return`/`throw` inside `finally` | `finally-and-control-flow.md` |

**Where the mechanism changes**

| Context | File |
|---|---|
| Checked exception inside a lambda or stream | `checked-exceptions-in-lambdas.md` |
| A blocking call throwing `InterruptedException` | `interrupted-exception.md` |
| Async chains — the failure is a stage's state | `completablefuture-errors.md` |

Two rules cut across all of it: preserve the cause when translating, and log once, at the layer that decides what happens next.
