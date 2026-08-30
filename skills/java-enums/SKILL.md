---
name: java-enums
description: Use when modeling with Java enums - wanting to extend or subclass one, sharing behavior between enums, state transitions, sets of enum constants, permissions, or choosing between HashMap/HashSet and EnumMap/EnumSet
---

# Java Enums

An enum is a *closed* set of constants known at compile time. Most enum questions are about respecting that closure while still getting reuse, or about using the collections built for it.

| Question | File |
|---|---|
| How do I extend / share behavior between enums? | `extending-enums.md` |
| Which transitions are valid from this state? | `enum-state-machines.md` |
| A set of constants — permissions, flags, options | `enum-sets.md` |

`EnumMap` and `EnumSet` pair up: a state graph is `EnumMap<Status, EnumSet<Status>>`.
