# Fail Fast

Interleaving validation with the normal path forces the reader to reconstruct the conditions of every branch. Detect the failure as early as possible and stop immediately, before starting work that will be wasted.

```java
// AVOID: validation interleaved with normal logic
void setStock(int stock) {
    if (stock < 0) {
        throw new IllegalArgumentException("Invalid stock: %d. Cannot be negative.".formatted(stock));
    } else if (stock <= 999_999) {
        this.stock = stock;
    } else {
        throw new IllegalArgumentException(
            "Invalid stock: %d. Must be between 0 and %d.".formatted(stock, 999_999));
    }
}
```

## Better: lift the check to the type

A record with a compact constructor validates at construction, so an invalid instance can never exist anywhere in the system.

```java
record Stock(int value) {
    static final int MAX_VALUE = 999_999;

    Stock {
        if (value < 0 || value > MAX_VALUE) {
            throw new IllegalArgumentException(
                "Invalid stock: %d. Must be between 0 and %d.".formatted(value, MAX_VALUE));
        }
    }
}

class ProductService {
    private Stock stock;

    void setStock(Stock stock) {
        this.stock = Objects.requireNonNull(stock, "Stock cannot be null.");
    }
}
```

This is not a business rule — it is an invariant guarding the type. Business rules that can legitimately answer "no" belong in the return type (`result-pattern.md`).

## Two failures, two exceptions

| What happened | Exception |
|---|---|
| contract violation — negative stock, null argument | `IllegalArgumentException` / `NullPointerException` |
| resource failure — gateway down, circuit open | a dedicated type, e.g. `PaymentGatewayUnavailableException` |

Mixing them confuses diagnosis and can make a circuit breaker read a client error as real unavailability, opening the circuit against a healthy dependency.

The same reasoning applies in distributed systems: fail early on local signals that the operation cannot succeed — deadline already exhausted, breaker open, dependency marked down. Do not start work that is born doomed.

## Red flags

- Validation of the same argument repeated across several methods — it belongs in the type
- A guard clause buried after work has already started
- `IllegalArgumentException` thrown for an unavailable dependency
- A validated value passed around as a bare `int` or `String`
