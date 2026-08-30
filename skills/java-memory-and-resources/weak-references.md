# WeakHashMap

A key put into a `HashMap` stays until you `remove()` it. The map holds a strong reference, so the GC cannot collect the key or its value — a leak by design if the map is a cache you never prune.

`WeakHashMap` holds its **keys** weakly: when the key object is no longer referenced anywhere else, the entry disappears and the GC collects everything.

```java
Map<ShippingQuote, PriceBreakdown> preview = new WeakHashMap<>();

public PriceBreakdown getPreview(ShippingQuote q) {
    return preview.computeIfAbsent(q, this::calcPreview);
}
```

`HashMap` for data whose lifetime you control; `WeakHashMap` for data that should vanish with its key object.

## Three cautions

**Only the key is weak.** If `PriceBreakdown` holds a reference back to its `ShippingQuote`, the key stays strongly reachable through the value and the entry is never collected. Cyclic references defeat the whole mechanism.

**Not thread-safe.** Wrap it: `Collections.synchronizedMap(new WeakHashMap<>())`.

**Eviction timing is the GC's, not yours.** Entries vanish when a collection happens, which makes `WeakHashMap` a poor cache: it may hold everything until the next GC, or drop a hot entry immediately. For an actual cache, use a real one with size and TTL policy (Caffeine) — see `unbounded-collections.md`.

Weak keys also require meaningful identity: with `equals`/`hashCode` based on value, a *different* instance that is equal still misses the entry it should hit.

## Red flags

- A `WeakHashMap` used as a performance cache with hit-rate expectations
- A value holding a reference back to its own key
- `WeakHashMap` shared across threads without synchronization
- A `HashMap` field that only ever grows (`unbounded-collections.md`)
