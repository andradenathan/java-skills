# Custom Functional Interfaces

A lambda lets a method take a rule, a transformation or an action without a class hierarchy. Declaring your own interface for each callback looks expressive but mostly grows the vocabulary callers must learn.

## Decide

**Default to `java.util.function`** when the signature fits `Predicate`, `Function`, `Supplier`, `Consumer` or their variants. They are already known, interoperate with the JDK's own APIs, and most ship combinators (`and`, `or`, `negate`, `andThen`, `compose`). For primitives reach for `IntPredicate`, `IntFunction` and friends to avoid boxing.

**Write your own** only when it earns at least one of:

- a domain name in a widely used API
- a contract worth documenting (nullability, purity, consistency)
- `default` methods that compose the concept

`Comparator` is the model: structurally it is `ToIntBiFunction<T, T>`, but its name, its consistency rules and its combinators carry meaning the generic type cannot.

## Anti-pattern: renaming Predicate

```java
// AVOID: structurally identical to Predicate<Order>.
@FunctionalInterface
interface OrderFilter { boolean matches(Order order); }

OrderFilter tooManyAttempts = order -> order.paymentAttempts() > MAX_PAYMENT_ATTEMPTS;
// No and()/or()/negate(); orders.stream().filter(tooManyAttempts) does not compile.

// USE: the standard type already solves it, and it composes.
Predicate<Order> excessiveAttempts = order -> order.paymentAttempts() > MAX_PAYMENT_ATTEMPTS;

List<Order> flagged = orders.stream()
        .filter(excessiveAttempts.and(Predicate.not(Order::cancelled)))
        .toList();
```

## When a custom type earns it

```java
@FunctionalInterface
interface RiskRule {
    // Contract: returns a non-null RiskScore and does not modify the order.
    RiskScore evaluate(Order order);

    default RiskRule combine(RiskRule next) {
        Objects.requireNonNull(next, "next");
        return order -> evaluate(order).merge(next.evaluate(order));
    }
}

RiskRule policy = velocityRule.combine(geoRule).combine(chargebackRule);
```

Domain name, documented contract, own composition — none of which `Function<Order, RiskScore>` conveys.

## If you do write one

- Annotate `@FunctionalInterface` — states intent and blocks a second abstract method added by mistake.
- Name it precisely and document the guarantees.
- Do not overload a method with different functional interfaces in the same argument position; the lambda becomes ambiguous at the call site.

## Red flags

- A new interface whose single method matches a `java.util.function` signature
- Wanting `and`/`or`/`negate` and writing them by hand
- A custom type that never appears in a public API — it is a local lambda, not a concept

Related: `primitive-functional-interfaces.md`
