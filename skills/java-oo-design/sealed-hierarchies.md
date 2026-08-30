# Replacing switch-on-type With a Sealed Hierarchy

A model that starts as an enum plus a `switch` works, and then the business grows: every new form means hunting `switch` blocks across the codebase, adding optional fields, and hoping nobody forgets a case. That is **switch-on-type** — a poor attempt at a discriminated union built from an enum and conditionals.

```java
// AVOID: one class holding every shape, fields that apply to some cases only
class Payment {
    enum Type { CREDIT_CARD, WIRE_TRANSFER }
    final Type type;
    String cardNumber;      // card only
    int installments;       // card only
    String routingNumber;   // transfer only
    String accountNumber;   // transfer only
}

// USE: sealed interface + records
sealed interface Payment permits CreditCard, WireTransfer {
    BigDecimal amount();
}

record CreditCard(BigDecimal amount, String number, int installments) implements Payment {}
record WireTransfer(BigDecimal amount, String routingNumber, String accountNumber) implements Payment {}

// exhaustive pattern matching
String process(Payment p) {
    return switch (p) {
        case CreditCard c -> c.installments() + "x on card";
        case WireTransfer w -> "Transfer to " + w.accountNumber();
    };
}
```

The interface states what is common, each record carries only what it needs, and the compiler guarantees exhaustiveness. In the product we say "card in installments" and "bank transfer" — the code should not model both as a generic object with irrelevant fields.

**Do not add a `default` branch** to that switch. A `default` makes it compile forever, which is precisely the protection you came for: without it, adding a `permits` type breaks the build at every switch that must change.

## When an enum is still right

A closed set of constants with no per-case data — statuses, roles, units. The trigger to evolve is fields that apply to only some constants, or a `switch` whose branches need different data. See `java-enums/extending-enums.md` for the neighboring decision.

## Red flags

- A `type` field whose value decides which other fields are meaningful
- Nullable fields documented as "only for X"
- The same `switch` over a type enum in more than one place
- `default:` in a switch over a sealed hierarchy
