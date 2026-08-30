# Behavior Belongs on the Constant

## Constants are not a type

Loose `static final int` values name things without limiting them.

```java
// AVOID: static final gives names, not boundaries
public class User {
    public static final int ADMIN = 1;
    public static final int GUEST = 2;
    private int role;
    public void setRole(int role) { this.role = role; }   // accepts 999
    public boolean canEdit() { return role == ADMIN; }
}

// USE: a closed, semantic set the compiler enforces
public class User {
    private AccessLevel accessLevel;
    public boolean canEdit() { return accessLevel.canEdit(); }
}

public enum AccessLevel {
    ADMIN { @Override public boolean canEdit() { return true; } },
    GUEST { @Override public boolean canEdit() { return false; } };

    public abstract boolean canEdit();
}
```

`static final` defines data; an enum defines meaning. With `int`, nothing stops `setRole(999)` — a nonexistent value and an invisible compile-time error.

## Never put default in an enum switch

```java
// FRAGILE: a new REFUNDED constant falls silently into default
String action = switch (status) {
    case PENDING -> "retry";
    case APPROVED -> "capture";
    case CANCELLED -> "refund";
    default -> "ignored";
};

// BETTER: no default — the build breaks everywhere a new constant must be handled
String action = switch (status) {
    case PENDING -> "retry";
    case APPROVED -> "capture";
    case CANCELLED -> "refund";
};
```

A switch **expression** with no `default` forces every constant to be handled explicitly. That broken build is the protection. (Old-style switch *statements* get no such check — another reason to use the expression form.)

## Do not scatter the switch

Services doing `if (status == APPROVED)` or switching on the enum to decide behavior fragment the domain rule, duplicate the decision, and create places to forget. The enum becomes an anemic model that the whole system is responsible for interpreting.

Put the behavior on the constant instead:

```java
public enum PaymentStatus {
    PENDING   { @Override public void handle(PaymentService s) { s.scheduleRetry(); } },
    APPROVED  { @Override public void handle(PaymentService s) { s.capturePayment(); } },
    CANCELLED { @Override public void handle(PaymentService s) { s.refund(); } };

    public abstract void handle(PaymentService service);
}

status.handle(paymentService);
```

This works when the behavior is intrinsic to the state and does not need complex external dependencies. When it does — or when the enum must not know about services — keep the mapping outside in an `EnumMap` (`enum-state-machines.md`).

## Red flags

- `static final int`/`String` groups representing states, roles or types
- `default` in a switch over an enum
- The same `switch (status)` in more than one class
- An enum with only constants while every service interprets it
