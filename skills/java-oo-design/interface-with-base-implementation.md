# Interface + Skeletal Implementation

Implementing an interface by auto-generating a dozen methods is a symptom. The interface should describe the contract, and everything derivable from it should come free.

**Order of tools:**

1. **`default` methods** for behavior derivable from the minimal contract.
2. **An abstract skeletal class** for what remains: shared state, repeated code, a fixed execution order.

```java
public interface TaxCalculator {
    BigDecimal calculateItem(BigDecimal base);

    // derived from the minimal method — every implementation gets it
    default BigDecimal calculateOrder(List<BigDecimal> items) {
        return items.stream().map(this::calculateItem)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}

public abstract class AbstractTaxCalculator implements TaxCalculator {
    protected final BigDecimal rate;          // interfaces hold no state
    protected AbstractTaxCalculator(BigDecimal rate) { this.rate = rate; }

    @Override public BigDecimal calculateItem(BigDecimal base) { return base.multiply(rate); }
}
```

This is GoF Template Method: the algorithm lives in the base, the variation points are the abstract methods. The JDK does exactly this with `AbstractList`, `AbstractSet`, `AbstractMap`.

Java 8+ reduced the need for the abstract class but did not remove it: interfaces hold no state, do not override `equals`/`hashCode`, and are a poor place for complex rules.

## Designing one

- Define the **minimal set of methods** the rest can be derived from.
- Derive everything possible with `default`.
- Put in the abstract class only what `default` cannot express.
- Implementing the interface should be a *choice*. Do not force inheritance — a class that already extends something can implement the interface and forward to a private inner subclass of the skeletal class.

## Red flags

- Extending `AbstractX` purely to reuse code, with no contract to fulfill
- An inherited method still throwing `UnsupportedOperationException`
- A base class that accumulated responsibilities beyond the algorithm
- An interface whose implementations all copy the same method body
