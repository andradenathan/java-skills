# Composition Over Inheritance

Extending a concrete class to add auditing or validation is the classic trap. Every order must pass a credit check before persisting, so you write `ValidatedOrderService extends OrderService` overriding `save()`. It compiles, tests pass, it ships.

Months later someone adds `saveAll()` for batch processing, reusing parts of the original internal flow. Batch orders now persist **without the credit check**, and nothing fails to compile. The system keeps working while a critical business rule is silently violated — the kind of bug found in an audit, not a build.

The fragility comes from depending on implementation details that can change: which methods exist, how they call each other internally, and in what order.

```java
// FRAGILE — inheritance violates encapsulation
class ValidatedOrderService extends OrderService {
    @Override public void save(Order order) {
        validateCredit(order);
        super.save(order);
    }
    // saveAll(), added later, bypasses validation
}

// ROBUST — composition protects the invariant (Decorator)
class ValidatedOrderService implements OrderService {
    private final OrderService delegate;

    ValidatedOrderService(OrderService delegate) { this.delegate = delegate; }

    @Override public void save(Order order) {
        validateCredit(order);
        delegate.save(order);
    }

    @Override public void saveAll(List<Order> orders) {
        orders.forEach(this::validateCredit);
        delegate.saveAll(orders);
    }
    // a new interface method forces an explicit implementation here
}
```

You depend only on the public contract. New methods on the interface become compile errors, which is exactly the alarm you want.

## In Spring

`BaseController` and `AbstractService` for shared logging, validation or exception handling create the same fragility: protected methods called in a specific order, mutable state via inherited fields, implicit dependencies where overriding one method breaks another.

Inject `LoggingService` and `ValidationService` through the constructor instead. For genuinely cross-cutting concerns, use AOP (`marker-annotation-aop`) — it intercepts without inheritance coupling. A decorator is just another bean; mark it `@Primary` and inject the delegate.

## When inheritance is right

A genuine "is-a" relationship **and** a superclass designed for extension — documented self-use, protected extension points. If you do not control the superclass or it lives in another package, composition is safer even when "is-a" holds.

## Red flags

- The motivation is "reuse code" or "intercept behavior"
- A subclass overriding a method that the superclass also calls internally
- `extends` on a class that is not `abstract` and not documented for extension
- `BaseController` / `AbstractService` holding mutable state
