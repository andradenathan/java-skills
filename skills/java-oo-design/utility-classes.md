# Utility Classes

Not every class represents a domain object. Some exist purely as logical groupings of static operations, with no state, identity or instance behavior — `java.lang.Math` is the JDK's example. `new Math()` makes no sense, and allowing it creates conceptual confusion.

Prevention is threefold:

```java
// WRONG: allows instantiation and inheritance
public class PriceCalculation {
    public static BigDecimal applyDiscount(BigDecimal price, BigDecimal percentage) { ... }
}

// RIGHT
public final class PriceCalculation {
    private PriceCalculation() {
        throw new AssertionError("Utility class cannot be instantiated");
    }
    public static BigDecimal applyDiscount(BigDecimal price, BigDecimal percentage) { ... }
}
```

`final` stops a subclass from bypassing the private constructor via `super()`. The `AssertionError` signals a design contract violation — a programming error, not a runtime condition.

Since Java 8, an interface with `static` methods is a valid way to group related operations without a class, especially in functional APIs. Do not use it to replace domain types; limit it to legitimate functional grouping.

## Naming forces cohesion

Avoid generic names like `SomethingUtils` or `SomethingHelper`. They become black boxes that accumulate unrelated responsibilities. Prefer concrete names — `StringNormalization`, `CurrencyConversion`, `TaxCalculation` — which impose semantic boundaries and keep the class small and testable.

## Before writing one, check the alternative

A static method whose first parameter is a domain object is usually a method that belongs *on* that object (`anemic-domain-model.md`). `PriceCalculation.applyDiscount(price, pct)` is a utility; `price.applyDiscount(pct)` is a domain model. Utility classes are for operations with no natural owner.

## Red flags

- `static` and instance methods mixed in one class — a design problem
- A utility class without `final` or without a private constructor
- `Utils`, `Helper`, `Manager`, `Common` in a class name
- A utility method taking a domain type as its first argument
- Static methods with hidden dependencies — a clock, a config, an I/O client — which are untestable by construction
