# Nested Classes: the Missing static

A non-`static` nested class carries a hidden reference to its enclosing instance. You never see it — the compiler inserts it into the bytecode. If the inner object outlives the outer one, the outer cannot be collected.

```java
// AVOID: the callback uses nothing from Checkout, yet retains all of it
public class Checkout {
    private final PaymentGateway gateway;

    public void startPayment() {
        gateway.registerCallback(new PaymentCallback());
    }

    class PaymentCallback implements Callback<PaymentEvent> {
        @Override public void onEvent(PaymentEvent e) { audit(e); }
    }
}

// USE: independent, no implicit reference
    static class PaymentCallback implements Callback<PaymentEvent> {
        @Override public void onEvent(PaymentEvent e) { audit(e); }
    }
```

Register that callback with a gateway that keeps it — retries, queues, async processing — and the whole `Checkout` stays reachable. The retention is invisible in the source and usually surfaces only in a heap dump or a memory metric. SpotBugs, Error Prone and SonarQube all detect the pattern.

Nested **records** are implicitly static (Java 16+), so they never have this reference.

The same capture applies to **anonymous classes**, which are always inner. A lambda is different: it captures the enclosing instance only if it actually references instance state — one more reason to prefer a lambda or a method reference for a small callback.

## Red flags

- A nested class with no `static` that never touches an outer field or method
- An anonymous class handed to something that stores it long-term
- A non-static inner class that is `Serializable` — serializing it drags the outer instance in, or fails
- A memory profile where instances of an outer class outlive their scope

Rule: if the nested class does not need instance members of the outer class, declare it `static`.
