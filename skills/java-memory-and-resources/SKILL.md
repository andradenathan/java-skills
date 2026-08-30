---
name: java-memory-and-resources
description: Use when a Java application leaks memory, resources or throughput - OutOfMemoryError after days of uptime, a connection pool that drains, AutoCloseable without try-with-resources, an in-memory list or cache that only grows, WeakHashMap, or objects allocated repeatedly in a hot loop
---

# Memory and Resources

The GC frees unreachable Java objects. It does not close external resources, and it cannot free what you still reference.

| Symptom | File |
|---|---|
| Connections, file handles or locks not released | `resource-leaks.md` |
| Heap growing over days; a list or cache with no limit | `unbounded-collections.md` |
| Entries that should disappear with their key object | `weak-references.md` |
| GC pressure, throughput loss in a hot path | `object-allocation.md` |

A third source of retention is a hidden reference: a non-static nested class holding its enclosing instance — see `java-oo-design/nested-classes.md`.
