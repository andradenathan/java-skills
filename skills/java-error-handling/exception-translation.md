# Translating Exceptions Without Losing the Cause

Preserving the cause when translating is essential. Creating a custom class in every layer is not. One question separates legitimate translation from bureaucracy: **does the new exception add a type, context or contract the original did not have?**

When the answer is no, you get over-wrapping: three or four exceptions stacked in the trace, each repeating the same message under a different name. Whoever investigates digs layer by layer to reach the real cause.

Worse is destructive wrapping:

```java
// AVOID — unnecessary custom exception + the cause discarded
catch (JsonProcessingException e) {
    throw new OrderServiceException(e.getMessage());
}

// USE — JDK exception + cause preserved
catch (JsonProcessingException e) {
    throw new IllegalArgumentException(
        "Invalid payload for order %s".formatted(orderId), e);
}
```

`new ...Exception(e.getMessage())` looks harmless but drops the original object: the real type, the original stack trace and the whole cause chain. You keep the sentence and lose the evidence. The pattern spreads by inertia — someone copies a `catch`, and before long the project cannot diagnose production failures.

That trailing `, e` is the whole difference.

## Red flags

- `throw new X(e.getMessage())` — no cause
- A custom exception that adds nothing the JDK's did not express
- Three or more wrapper layers in one stack trace
- Log *and* rethrow in the same catch (`log-and-throw.md`)
