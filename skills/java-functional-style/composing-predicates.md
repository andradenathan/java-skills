# Composing Predicates

`Predicate<T>` answers one question: true or false. The gain is not replacing an `if` with a lambda — it is naming independent criteria and composing a larger decision from them with `and`, `or`, `negate`.

## Pattern

```java
// AVOID: the business rules are anonymous, buried in the filter.
List<Order> dispatchQueue = orders.stream()
        .filter(order -> order.payment() == PaymentStatus.APPROVED
                && order.hasStock()
                && !order.customerBlocked())
        .toList();

// USE: each criterion named, testable, combinable.
Predicate<Order> paymentApproved = order -> order.payment() == PaymentStatus.APPROVED;
Predicate<Order> hasStock        = Order::hasStock;
Predicate<Order> customerCleared = order -> !order.customerBlocked();

Predicate<Order> eligibleForAutoDispatch =
        paymentApproved.and(hasStock).and(customerCleared);

List<Order> dispatchQueue = orders.stream()
        .filter(eligibleForAutoDispatch)
        .toList();
```

`paymentApproved.and(hasStock)` reads as the business rule. A chain of technical conditions does not.

## Not a Predicate when

| The check | Use instead |
|---|---|
| must explain *why* it failed | a validation result carrying the reasons |
| belongs to the object itself | a method — `invoice.isOverdue()` |
| throws a checked exception or does I/O | an explicit method; `test` declares no exceptions |
| computes a lot, has steps, or returns more than a boolean | a policy or service |

## No side effects

A predicate observes and answers. It must not modify the order, reserve stock, persist, or emit events.

**Never log inside one.** Streams are lazy and short-circuit, so which elements get evaluated and in what order is not yours to depend on; in a parallel stream, evaluations also overlap non-deterministically. The log records what the pipeline chose to evaluate, not what the business did — a witness that lies.

Hiding a checked exception in a `catch` inside the lambda has the same shape of failure: it turns into a silent one.

## Red flags

- A multi-line boolean lambda inside `filter(...)`
- A predicate that touches a repository, a clock, or a logger
- `false` returned where the caller needs the reason
- A predicate wrapping a check the domain object should expose

Related: `custom-functional-interfaces.md`, `supplier-and-consumer.md`
