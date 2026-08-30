# Static Factory Methods

A constructor with many loose parameters is hard to read and easy to get wrong. A static factory method gives the creation a name.

```java
// Traditional constructor — the reader needs the docs
Order o1 = new Order("123", "CREDIT", true, 250.0, "BRL", "ONLINE");

// Static factory — the intent is in the name
Order o2 = Order.paidOnlineWithCredit("123", 250.0, "BRL");
```

Three advantages over a constructor:

- **A descriptive name**, which removes the ambiguity of overloaded constructors — two factories can even take the same parameter types, which two constructors cannot.
- **Instance reuse**: it may return a cached instance instead of allocating (`Integer.valueOf`, `Boolean.valueOf`, enum constants).
- **Flexible return type**: it may return a subtype and hide the concrete implementation (`List.of`, `Collectors.toMap`).

Conventional names carry meaning: `of`, `valueOf`, `from` for conversions, `getInstance` for a managed instance, `newInstance` when a fresh object is guaranteed.

## Trade-offs

A class with only private constructors cannot be subclassed — usually a feature, occasionally a constraint. And factories are harder to spot than constructors in generated docs, so the naming conventions matter.

## Relation to builders

A factory names a *purpose*; a builder assembles *many optional fields*. Use a factory to make a default explicit — `User.admin(id, name)` beats a builder quietly defaulting `role = "ADMIN"`. See `builders.md`.

## Red flags

- A constructor taking three or more parameters of the same type — nothing stops a caller swapping them
- Boolean parameters in a constructor: `new Order(..., true, ...)` says nothing at the call site
- Overloaded constructors distinguished only by parameter order
- A comment above a `new` explaining what the arguments mean
