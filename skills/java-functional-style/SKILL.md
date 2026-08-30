---
name: java-functional-style
description: Use when writing or reviewing Java lambdas, streams or functional interfaces - stream vs loop, Predicate/Function/Supplier/Consumer choice, declaring a @FunctionalInterface, autoboxing in numeric pipelines, Collectors.toMap, Optional, returning null from a collection method, or a long lambda inside filter/map/forEach
---

# Java Functional Style

Recurring theme across these: **a lambda is not a code block, and the functional type hides decisions the signature does not show.** Read the file that matches the question.

| Question | File |
|---|---|
| Should this be a stream or a `for` loop? | `for-loop-against-streams.md` |
| Passing a value or the way to produce it? `orElse` vs `orElseGet`? | `supplier-and-consumer.md` |
| Should I declare my own `@FunctionalInterface`? | `custom-functional-interfaces.md` |
| Numeric pipeline — is this boxing? | `primitive-functional-interfaces.md` |
| Long boolean lambda inside `filter`? | `composing-predicates.md` |
| Collecting a stream — `toMap`, duplicate keys, ordering | `collectors.md` |
| A value that may be absent; returning null | `optional-and-nulls.md` |

Two or more may apply: a boxed `Predicate<Integer>` is both a predicate and a boxing question.
