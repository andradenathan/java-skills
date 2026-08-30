# Retry Only What Is Transient

A network timeout may work on the next attempt. Malformed JSON will not. In production both usually get the same treatment: catch anything, sleep, try again. The timeout eventually resolves; the JSON fails again and again, burning threads, inflating retry queues and generating alerts nobody reads.

| Class | Examples | Retry? |
|---|---|---|
| transient | `SocketTimeoutException`, `ConnectException`, HTTP 503 | yes |
| deterministic | `IllegalArgumentException`, `JsonParseException`, HTTP 400 | no — same input, same error |

```java
// AVOID — blind retry on any exception
try {
    submitPayment(order);
} catch (Exception e) {
    Thread.sleep(2000);
    submitPayment(order);   // invalid JSON fails again
}

// USE — declarative retry for transient failures
// requires @EnableResilientMethods on a @Configuration
@Retryable(includes = SocketTimeoutException.class,
           excludes = IllegalArgumentException.class,
           maxRetries = 3,
           delay = 1000, multiplier = 2, jitter = 200)
public void submitPayment(Order order) {
    gateway.process(order);
}
```

Spring Framework 7 brought `@Retryable` into the framework's own resilience core. `includes`/`excludes` put the classification in the code instead of hiding it in a generic `catch` with a `Thread.sleep`.

## Jitter

Without it, instances that failed together retry together on the same interval, hammering a service already under pressure — the thundering herd. A random variation on the delay desynchronizes the attempts and spreads the load.

## Retry needs idempotency

A timeout does not tell you whether the request was processed. Retrying a non-idempotent write can charge twice. Before adding `@Retryable` to a write path, make the operation idempotent — an idempotency key the gateway deduplicates on, or a check for an existing result before resubmitting.

## Red flags

- `catch (Exception e)` followed by a retry
- A retry policy with no upper bound, or none on the total time budget
- Retrying a write with no idempotency key
- Exponential backoff without jitter across multiple instances
- Retrying a 4xx
