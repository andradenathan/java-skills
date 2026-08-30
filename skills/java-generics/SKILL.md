---
name: java-generics
description: Use when Java generics fight back - a List<Subtype> rejected by a List<Supertype> parameter, wildcards (? extends / ? super), @SuppressWarnings("unchecked"), casts after reflection, or a container holding values of several types
---

# Java Generics

Generics are invariant and erased at runtime. Most friction comes from one of those two facts.

| Question | File |
|---|---|
| Why won't my `List<Subtype>` fit this parameter? | `pecs.md` |
| Can I avoid this unchecked cast? | `suppressing-unchecked.md` |
| A container holding values of different types | `typesafe-heterogeneous-container.md` |
