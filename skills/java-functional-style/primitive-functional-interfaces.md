# Primitive Functional Interfaces

`Function<Integer, Integer>` takes and returns *objects*, not `int`. Each call unboxes to add and boxes the result again — invisible in the signature, allocated at runtime.

## Decide

| Operation on | Use | Not |
|---|---|---|
| `int` → `int` | `IntUnaryOperator` | `Function<Integer, Integer>` |
| `long` → `long` | `LongUnaryOperator` | `Function<Long, Long>` |
| `double` → `double` | `DoubleUnaryOperator` | `Function<Double, Double>` |
| `int` → `boolean` | `IntPredicate` | `Predicate<Integer>` |

The specialized type only pays off with a matching primitive source and stream (`int[]` + `Arrays.stream`, `IntStream`). A primitive operator fed from `List<Integer>` still boxes at the source.

## Pattern

```java
// AVOID in bulk processing: the source hands out wrappers,
// and every sum unboxes and boxes again.
Function<Integer, Integer> applyRestockGeneric = quantity -> quantity + RESTOCK_QUANTITY;

List<Integer> stockQuantitiesBoxed = loadStockQuantities();

int totalAfterRestockBoxed = stockQuantitiesBoxed.stream()
        .map(applyRestockGeneric)   // may allocate one Integer per item
        .mapToInt(Integer::intValue)
        .sum();

// USE: source and operation keep the values as int.
IntUnaryOperator applyRestockPrimitive = quantity -> quantity + RESTOCK_QUANTITY;

int[] stockQuantities = loadStockQuantitiesAsArray();

int totalAfterRestock = Arrays.stream(stockQuantities)
        .map(applyRestockPrimitive)  // no Integer wrappers in the pipeline
        .sum();
```

## Scope

This is a hot-path concern, not a style rule. Over a few hundred items it is noise, and the JIT erases part of the cost — but not predictably enough to rely on. It matters when a pipeline walks millions of items or sits on a latency-sensitive path: the temporary objects become GC pressure.

Do not rewrite domain code to chase it. `List<Integer>` and `Function` win on clarity and on fitting the surrounding APIs. Change the source type only where profiling shows the cost.

## Red flags

- `Function<Integer, Integer>` (or `Long`/`Double`) anywhere
- `.map(...)` followed by `.mapToInt(Integer::intValue)` — the boxing round-trip made visible
- A primitive operator fed by a `List<Integer>` — boxing already happened at the source
- Optimizing this without a profile

Related: `custom-functional-interfaces.md`
