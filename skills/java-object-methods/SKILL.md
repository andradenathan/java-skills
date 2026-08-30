---
name: java-object-methods
description: Use when overriding equals, hashCode, toString or compareTo in Java - an object missing from a HashSet, contains() returning false, Lombok @Data on an entity, StackOverflowError or LazyInitializationException from a log line, or multi-criteria sorting
---

# equals, hashCode, toString, compareTo

The methods a value class overrides. Each has a contract that the compiler does not enforce, so breakage is silent.

| Symptom / question | File |
|---|---|
| Overriding `equals` correctly; `contains` fails on a list | `overriding-equals.md` |
| Object lost in a `HashSet`/`HashMap`; Lombok `@Data`; JPA entity identity | `equals-hashcode-contract.md` |
| `toString` on entities, logs, `StackOverflowError`, lazy proxies | `tostring.md` |
| Sorting by several criteria; `compareTo` | `comparators.md` |

`compareTo` returning 0 should agree with `equals` — sorted collections treat 0 as equality.
