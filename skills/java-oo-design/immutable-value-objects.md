# Immutable Value Objects

A large share of bugs comes not from wrong algorithms but from state changing without anyone noticing. Price, discount and order total cross methods, services and layers. When those objects are mutable, a reused reference can alter a value you assumed stable — and the error surfaces later, in production, when nobody remembers who touched the object.

```java
// AVOID: mutable state, easy to corrupt
class Price {
    BigDecimal value;
    void applyDiscount(BigDecimal percent) {
        value = value.subtract(value.multiply(percent));
    }
}

Price original = new Price(new BigDecimal("100.00"));
Price checkoutPrice = original;
checkoutPrice.applyDiscount(new BigDecimal("0.10"));
// original changed without you noticing

// USE: a value, not a container
record Price(BigDecimal value) {
    Price applyDiscount(BigDecimal percent) {
        return new Price(value.subtract(value.multiply(percent)));
    }
}
```

An immutable object *is* a value. Applying a discount, adding tax or converting currency does not mean "changing the price" — it means deriving a new one. Side effects disappear, the code becomes predictable, and the model is thread-safe for free.

Records make this the language default: `final` fields, no setters, value-based equality. For domain concepts like price, money, percentage or total, immutability stops being an aesthetic choice and becomes a defense of the domain.

## A record is not automatically immutable

A record's *reference* fields are final, but the objects behind them are not. `record Order(List<Item> items)` hands out the caller's live list. Copy on the way in and on the way out:

```java
record Order(List<Item> items) {
    Order {
        items = List.copyOf(items);   // compact constructor
    }
}
```

Same for arrays, `Date`, and any mutable type. `BigDecimal`, `String` and `LocalDate` are already immutable and need no copy.

## The cost

More objects created. In Java small objects are cheap; shared-state bugs are not.

## Red flags

- A setter on a domain value type
- A method returning `void` that changes the object it was called on, where a new value would do
- A record holding a `List`, `Map`, array or `Date` with no defensive copy
- Two variables pointing at one instance where the code reads as if they were separate values
