# Check-Then-Act and Read-Modify-Write

In October 2025 AWS had a 15-hour outage in us-east-1. The cause was a latent race condition in DynamoDB's DNS system: a delayed process completed its work while another was cleaning up old records, deleting DNS entries still in use. No error, no log — a dormant bug that woke up on the right timing.

The same shape appears in two classic Java traps. In both, each individual operation is thread-safe; the *sequence* is not.

## Check-Then-Act

```java
// AVOID: two threads see the same state, both create the resource
Resource get(String k) {
    if (!cache.containsKey(k)) {
        cache.put(k, createExpensive(k));
    }
    return cache.get(k);
}

// USE: one atomic operation
Resource get(String k) {
    return cache.computeIfAbsent(k, this::createExpensive);
}
```

## Read-Modify-Write

```java
// AVOID: increments lost between threads
void increment(String k) {
    Long current = counters.get(k);          // read
    counters.put(k, current == null ? 1L : current + 1);  // modify + write
}

// USE: LongAdder for high contention
private final Map<String, LongAdder> counters = new ConcurrentHashMap<>();

void increment(String k) {
    counters.computeIfAbsent(k, x -> new LongAdder()).increment();
}
```

`ConcurrentHashMap` gives you a family of atomic compound operations — `computeIfAbsent`, `putIfAbsent`, `merge`, `compute`, `replace`. Reaching for `get` followed by `put` means you skipped one.

## Two caveats

**The mapping function must be short and must not touch the map.** `computeIfAbsent` holds a bin lock: computing another entry of the same map inside it can deadlock, and blocking I/O in there pins a virtual thread on JDK 21–22 (`virtual-thread-pinning.md`).

**Atomicity is not visibility.** Making an update atomic does not guarantee another thread sees it. That is what `volatile`, the atomic types and the locks' happens-before edges are for.

## Red flags

- `containsKey` / `get` followed by `put` on a shared map
- A `get`-modify-`put` sequence on any shared structure
- `synchronized` on one method but not on another touching the same field
- A "thread-safe" class whose safety rests on each call being safe individually
