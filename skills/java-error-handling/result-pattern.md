# Result Pattern

Exceptions signal the unexpected. Insufficient balance, invalid document, duplicate order are not unexpected — they are legitimate domain answers. Model them with `throw`/`catch` and nothing obliges the caller to handle them: forget the `catch`, the code still compiles, and the failure shows up in production.

Result puts both outcomes in the return type.

```java
// AVOID — exception for an expected domain branch
try {
    Reservation res = stockService.reserve(productId, qty);
    return OrderResult.ok(res);
} catch (OutOfStockException e) {
    return OrderResult.fail("Out of stock");
}

// USE — sealed interface Result<T> permits Success, Failure
Result<Reservation> res = stockService.tryReserve(productId, qty);

return switch (res) {
    case Success<Reservation> s -> OrderResult.ok(s.value());
    case Failure<Reservation> f -> OrderResult.fail(f.reason());
};
// the compiler verifies no case of the sealed hierarchy was forgotten
```

## Where the line sits

| Situation | Mechanism |
|---|---|
| what the business can answer (no stock, invalid input, duplicate) | `Result` |
| infrastructure failure (connection refused, timeout, disk full) | exception |
| invariant violation — an order with a negative total that passed validation | exception |

Infrastructure failures are not business decisions: a caller in the middle of the domain does not know what to do with `Failure("connection refused")`. The exception needs to travel up to someone who does. Result belongs in the domain and use-case layers.

## Not always a Result — sometimes just a better contract

The same smell shows up as try/catch driving the business rule:

```java
// AVOID: exceptions as control flow
try {
    Reservation res = stockService.reserve(prodId, qty);
    Receipt rec = payService.charge(custId, amt);
    couponService.apply(orderId, code);
    return OrderResult.ok(orderId, res, rec);
} catch (OutOfStockException e) {
    return OrderResult.fail("Out of stock");
} catch (PaymentDeclinedException e) {
    return OrderResult.fail("Payment declined");
}

// USE: the expected outcome is visible in each return type
Optional<Reservation> res = stockService.tryReserve(prodId, qty);
if (res.isEmpty()) return OrderResult.fail("Out of stock");

PaymentResult pay = payService.charge(custId, amt);
if (pay.isDeclined()) return OrderResult.fail("Payment declined");
```

`Result` is one shape among several. Pick by what the outcome is:

| Outcome | Shape |
|---|---|
| value may be absent | `Optional<T>` |
| several named outcomes | `Result` / a sealed hierarchy |
| the caller can check first | a guard method — `canReserve()` before `reserve()` |
| a bug or infrastructure failure | exception |

If you need try/catch to express the business rule, the API contract is probably wrong.

## What Result does and does not guarantee

It makes the branch visible in the signature, and `switch` over a sealed hierarchy is checked for exhaustiveness. But nothing forces the caller to *inspect* the value — a returned `Result` can still be discarded. Exhaustiveness only helps once you switch on it.

## Red flags

- A custom exception thrown for an outcome the business expects
- `catch` used as control flow in domain code
- `Result` wrapping an infrastructure failure the caller cannot act on
- A `Result` return value ignored at the call site
- A non-sealed `Result` — without `sealed` there is no exhaustiveness check
