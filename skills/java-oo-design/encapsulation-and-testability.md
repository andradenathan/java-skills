# Encapsulation and Testing Private Methods

If you can make a class or field less visible, do it. Every increase in accessibility is coupling, and coupling is a permanent design cost. Instance fields should almost never be public — even `final` ones — because they expose the internal representation and remove any chance to validate, protect invariants, or evolve the model without breaking callers.

## Test observable behavior

You can only test what the component lets you observe through its exposed services. If a private method is wrong, the failure shows up in public use — which is what matters to the client of the abstraction.

**Wanting to test a private method directly is usually testability pressure on the design.** The right question is not "how do I test this?" but "why is this so hard to observe?".

## When the internal logic is genuinely dense

Two healthy alternatives, in order:

**1. Extract it into a cohesive class**, which makes the unit naturally testable.

```java
class DiscountService {
    private final BaseDiscountPolicy policy = new BaseDiscountPolicy();

    public BigDecimal calculateDiscount(Order order) {
        BigDecimal base = policy.compute(order.getCustomer(), order.getTotal());
        ...
    }
}

// dense logic extracted — now testable on its own
class BaseDiscountPolicy {
    @VisibleForTesting
    BigDecimal compute(Customer c, BigDecimal total) { ... }
}
```

**2. Make the method package-private**, preserving encapsulation across modules while letting the test suite reach it. `@VisibleForTesting` marks the wider visibility as a concession for testability, not part of the official API — the test must live in the same package for this to work.

Never make something `public` just to test it.

## Red flags

- A test using reflection to reach a private method
- A method made `public` with no caller outside the class
- `@VisibleForTesting` on something that production code also calls
- A class so hard to observe that the test asserts on mocks instead of results
