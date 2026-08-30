# State Machines with EnumMap

`EnumMap` is a `Map` implementation for enum keys: internally an array indexed by the constant's ordinal, no hashing — faster and more compact than `HashMap` here, and it iterates in declaration order.

When the domain has well-defined states, model the transitions as `EnumMap<Status, Set<Status>>`: each entry maps a source state to its valid destinations. `EnumSet` as the value keeps both sides optimized for enums and states the intent precisely.

```java
// AVOID: validation scattered as ifs across the domain
public void transition(Status current, Status next) {
    if (current == Status.PAID
            && next != Status.PICKING
            && next != Status.CANCELLED) {
        throw new IllegalStateException("Invalid transition");
    }
    // ...one block like this per state
}

// USE: the graph centralized with EnumMap + EnumSet
private static final EnumMap<Status, Set<Status>> TRANSITIONS =
        new EnumMap<>(Status.class);

static {
    TRANSITIONS.put(Status.PAID,      EnumSet.of(Status.PICKING, Status.CANCELLED));
    TRANSITIONS.put(Status.PICKING,   EnumSet.of(Status.SHIPPED, Status.CANCELLED));
    TRANSITIONS.put(Status.SHIPPED,   EnumSet.of(Status.DELIVERED));
    // terminal state — no possible transitions
    TRANSITIONS.put(Status.DELIVERED, EnumSet.noneOf(Status.class));
}

public boolean canTransition(Status from, Status to) {
    return TRANSITIONS
            .getOrDefault(from, EnumSet.noneOf(Status.class))
            .contains(to);
}
```

Terminal states get `EnumSet.noneOf(Status.class)` rather than being left out — the absence of transitions becomes explicit and no `null` handling is needed. The whole graph sits in one block, which is what makes it reviewable as the domain grows.

## Red flags

- `HashMap` keyed by an enum
- Transition rules as `if`/`switch` chains spread across services
- A terminal state left out of the map instead of mapped to `noneOf`
- The map exposed directly — a static `EnumMap` is mutable; wrap it in `Collections.unmodifiableMap` (see `enum-sets.md`)
