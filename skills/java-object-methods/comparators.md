# Comparable and Comparator

A value class with an unquestionable natural order should implement `Comparable`. For contextual orders or multiple criteria, use `Comparator` — business rules that would otherwise be blocks of `if` fit in a few lines.

```java
orders.sort(
    Comparator.comparing(Order::isVip).reversed()
            .thenComparing(Order::getTotal, Comparator.reverseOrder())
            .thenComparing(Order::getDeliveryDate,
                           Comparator.nullsLast(Comparator.naturalOrder())));

employees.sort(
    Comparator.comparing(Employee::getDepartment)
            .thenComparing(Employee::getSalary, Comparator.reverseOrder())
            .thenComparing(Employee::getName));
```

## Never subtract

```java
// AVOID: 2_000_000_000 - (-300_000_000) overflows int.
// The sign flips and the ordering is silently wrong.
public int compareTo(Player other) { return this.score - other.score; }

// USE
public int compareTo(Player other) { return Integer.compare(this.score, other.score); }
```

In `compareTo`/`compare`, never subtract and never use `<` or `>`. Use `Integer.compare`, `Long.compare`, `Double.compare`, or the `Comparator` factories.

## Three traps

**`reversed()` applies to everything built so far.** `comparing(a).thenComparing(b).reversed()` reverses the *whole* chain, not just `b`. To reverse one key, pass `Comparator.reverseOrder()` as that key's comparator — as in the example above.

**Zero means equivalent to `TreeSet`/`TreeMap`.** They use `compare`, not `equals`: a comparator that ties on two distinct elements will drop one or overwrite a key. Add a tiebreaker that is unique.

**`comparing` boxes.** For a primitive key on a hot path, `comparingInt`/`comparingLong`/`comparingDouble` avoid the wrapper.

## Red flags

- `-` or `<`/`>` inside `compareTo` or `compare`
- `reversed()` at the end of a multi-key chain
- A `TreeSet` whose comparator can return 0 for non-equal elements
- A comparator that touches a nullable key without `nullsFirst`/`nullsLast`
- `compareTo` inconsistent with `equals` on a class used in sorted collections
