# You Cannot Extend an Enum

Every enum already extends `java.lang.Enum`, and Java has no multiple class inheritance. That is not an oversight: an enum is a *closed* set of constants known at compile time. Extensibility would break switch exhaustiveness, constant identity, and the predictability of the domain.

So the fix is never to make the enum open. Pick the alternative that matches the actual need.

## Decide

| The need | Use |
|---|---|
| one API accepting several enums (or classes) | **interface** |
| reusing data or logic across enums | **composition** |
| several implementations, still a closed set | **sealed interface** |
| new values at runtime (config, DB, plugins) | **class / record / value object** |

## 1. Interface — a shared contract

```java
public interface Status { boolean isFinal(); }

public enum OrderStatus implements Status {
    CREATED(false), PAID(false), CANCELLED(true);

    private final boolean finalStatus;
    OrderStatus(boolean finalStatus) { this.finalStatus = finalStatus; }
    @Override public boolean isFinal() { return finalStatus; }
}

public enum PaymentStatus implements Status { /* PENDING(false), APPROVED(true), ... */ }

// The API depends on the contract, not on one enum.
public void process(Status status) {
    if (status.isFinal()) { /* common rule for any Status */ }
}
```

Each enum stays closed; the extension point moves to the interface.

## 2. Composition — shared data and logic

```java
public record StatusInfo(boolean finalStatus, String description) {}

public enum OrderStatus {
    CREATED(new StatusInfo(false, "Order created")),
    CANCELLED(new StatusInfo(true, "Order cancelled"));

    private final StatusInfo info;
    OrderStatus(StatusInfo info) { this.info = info; }

    public boolean isFinal() { return info.finalStatus(); }
    public String description() { return info.description(); }
}
```

Do not try to inherit fields from another enum — extract them into a record and delegate.

## 3. Sealed interface — closed, but multiple families

```java
public sealed interface Event permits OrderEvent, PaymentEvent {
    String code();
}

public enum OrderEvent implements Event {
    CREATED, CANCELLED;
    @Override public String code() { return "ORDER_" + name(); }
}

public enum PaymentEvent implements Event {
    AUTHORIZED, REJECTED;
    @Override public String code() { return "PAYMENT_" + name(); }
}
```

`permits` states exactly who may implement it, so arbitrary extension outside the model stays blocked — and a `switch` over `Event` can still be checked for exhaustiveness.

## 4. Value object — extensible at runtime

```java
public record EventType(String name) {
    public static final EventType ORDER_CREATED = new EventType("ORDER_CREATED");
    public static final EventType ORDER_CANCELLED = new EventType("ORDER_CANCELLED");
}

EventType customEvent = new EventType("EXTERNAL_INTEGRATION_RECEIVED");
```

When values arrive from configuration, a database or an integration, an enum is the wrong abstraction. Accept the trade: no exhaustive switch, no constant identity — compare with `equals`, never `==`, since two instances of the same name are distinct objects.

## Red flags

- Duplicated fields and constructors across enums that mean the same thing
- An API overloaded once per enum instead of taking a common interface
- `valueOf` wrapped in try/catch to tolerate unknown values — the set is not actually closed
- `==` on value objects that replaced an enum
