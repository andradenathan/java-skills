# When an Interface Earns Its Place

Interfaces are behavioral contracts, not architectural bureaucracy. The most common mistake is the `XService`/`XServiceImpl` pair with no real justification — useless complexity and a class whose suffix means nothing.

```java
// AVOID: unnecessary interface, Impl naming
public interface UserService { User findById(Long id); }
public class UserServiceImpl implements UserService {
    @Override public User findById(Long id) { ... }
}

// USE: a direct class when there is one implementation
public class UserService {
    public User findById(Long id) { ... }
}
```

An interface is justified when there is **real variation in behavior** or a **boundary between modules**. If you do need a default implementation, name it `XServiceDefault` — it states the intent of being *the default behavior*, not a generic implementation with no purpose.

A useful test: if you cannot give the implementation a meaningful name, you do not have two implementations.

You also do not need an interface for Spring to proxy a bean — CGLIB subclasses concrete classes, so `@Transactional` and aspects work without one.

## Keep them small

A big interface forces implementations to declare irrelevant methods (ISP violation). A dozen methods means it is doing too much.

## Changing an existing interface

Before Java 8 this was fatal. `default` methods made it possible, but risky: the default implementation is injected into existing classes without their authors' knowledge, and can violate guarantees they rely on — thread synchronization, specific validations. **Default methods are for new designs, not for evolving old APIs casually.** For deriving behavior in a new interface, see `interface-with-base-implementation.md`.

## Do not use an interface to hide a bad design

If `OrderService` mixes shipping calculation, stock validation and invoice issuing, an interface does not fix it. Separate the responsibilities — `ShippingCalculator`, `StockValidator`, `InvoiceIssuer`. Each interface should have one reason to change.

## Red flags

- A class named `...Impl`
- An interface with exactly one implementation and no module boundary
- An interface created "for testability" that only ever gets mocked
- A `default` method added to an interface with implementations you do not own
