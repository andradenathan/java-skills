# PECS — Producer Extends, Consumer Super

Generics are **invariant**: `List<ExpressOrder>` is not a subtype of `List<Order>`, even though `ExpressOrder` extends `Order`. So a `List<Order>` parameter rejects a `List<ExpressOrder>`, forcing the caller to copy the whole collection first.

The invariance is not arbitrary. If `List<ExpressOrder>` could be passed as `List<Order>`, the method could add a `VipOrder` to it, and whoever still holds the original reference gets a `ClassCastException` on the next `get`.

Wildcards restore the flexibility without giving up that safety.

```java
// AVOID: rejects List<ExpressOrder> and List<VipOrder>
public BigDecimal calculateTotal(List<Order> orders) { ... }

// USE: producer extends — reads from any subtype of Order
public BigDecimal calculateTotal(List<? extends Order> orders) {
    return orders.stream().map(Order::value).reduce(BigDecimal.ZERO, BigDecimal::add);
}

// AVOID: rejects List<Object>, even though it only adds Order
public void exportTo(List<Order> destination, Order order) { ... }

// USE: consumer super — writes Order into any supertype list
public void exportTo(List<? super Order> destination, Order order) {
    destination.add(order);
}
```

| The collection | Declare | You get |
|---|---|---|
| produces values you read | `List<? extends T>` | read as `T`; writes blocked (only `null`) |
| consumes values you add | `List<? super T>` | add `T` safely; reads give only `Object` |
| both | `<T>` type parameter | no wildcard |

The compiler allows exactly the operation it can prove safe. `? extends` blocks writing because the list's exact subtype is unknown; `? super` limits reads to `Object` because that is the only type guaranteed across every possible supertype.

## Applying it

- Wildcards belong on **method parameters**, not return types — a wildcard in the return signature leaks into every caller's code.
- A type parameter used only once in a signature is a signal it should be a wildcard.
- The same rule drives JDK signatures: `Comparator<? super T>`, `Collection.addAll(Collection<? extends E>)`.

## Red flags

- Callers copying a collection just to satisfy a parameter type
- `List<Object>` as a parameter to accept anything
- A wildcard on a return type
- `? extends` on a parameter the method writes to — it will not compile, and the fix is `? super`, not raw types
