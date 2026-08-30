# List Fixtures in Tests

A bad unit test starts with noise: `new ArrayList<>()` followed by `add()`, `add()`, `add()`. The input data takes more lines than the behavior under test.

```java
// AVOID
List<Order> orders = new ArrayList<>();
orders.add(new Order("A", 100));
orders.add(new Order("B", 200));

// USE: read-only fixture (order() is a static test helper)
var orders = List.of(order("A", 100), order("B", 200), order("C", 300));

// USE: the code under test mutates the list
var orders = new ArrayList<>(List.of(order("A", 100), order("B", 200)));

// USE: many identical values
var orders = Collections.nCopies(10, Order.pending());

// USE: numeric sequence — paging, indexes, sequential IDs
var pages = IntStream.rangeClosed(1, 5).boxed().toList();
```

| Need | Use | Watch out |
|---|---|---|
| test only reads it | `List.of(...)` | immutable; rejects `null` at construction |
| code under test mutates it | `new ArrayList<>(List.of(...))` | |
| N identical elements | `Collections.nCopies(n, x)` | one shared instance — dangerous if mutable |
| numeric sequence | `IntStream.rangeClosed(1, n).boxed().toList()` | `toList()` (Java 16+) is immutable |

`List.of` rejecting `null` is a feature: invalid data fails at construction, not halfway through an assertion. When the fixture genuinely needs a `null` element, `Arrays.asList` or `new ArrayList<>()` are the way.

## Two traps

**`Arrays.asList(...)` is fixed-size.** It looks like an ordinary list — `set()` works — but `add()` and `remove()` throw `UnsupportedOperationException`.

**Forget double-brace init**, `new ArrayList<>() {{ add(...); }}`. It creates an anonymous class per fixture and holds a reference to the enclosing instance.

## Red flags

- More setup lines than assertion lines
- `Arrays.asList` handed to code that appends
- `Collections.nCopies` with a mutable element the test then modifies
- `Collectors.toList()` where `.toList()` fits — the old one has no immutability guarantee
