# Overriding equals

You override `equals`, tests go green, and in production `ArrayList.contains()` fails to find an object that is in there. The cause is one of Java's most treacherous slips: writing `equals(MyType o)` instead of `equals(Object o)`. That does not override `Object.equals` — it *overloads* it. Collections and JDK APIs dispatch on the `equals(Object)` signature, so your method never participates.

```java
// AVOID: overload. Does not override Object.equals(Object).
public boolean equals(Product o) { ... }

// USE: real override.
@Override
public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof Product other)) return false;
    return Objects.equals(sku, other.sku);
}

@Override
public int hashCode() { return Objects.hash(sku); }
```

**Always write `@Override`** — the compiler then rejects the accidental overload immediately.

## The contract

| Clause | Meaning |
|---|---|
| reflexive | `x.equals(x)` is always true |
| symmetric | `a.equals(b)` implies `b.equals(a)` |
| transitive | `a==b` and `b==c` implies `a==c` |
| consistent | the result does not change while the compared state does not |
| non-nullity | `x.equals(null)` is always false |

Break any clause and `HashMap`, `HashSet` and everything built on `equals` misbehave — silently. See `equals-hashcode-contract.md`.

## The recipe

1. Test `this == o`.
2. Check the type with `instanceof` — this also covers `null`.
3. Bind the cast (`instanceof Product other` does both).
4. Compare every significant field with the form appropriate to its type: `Objects.equals` for references, `==` for primitives, `Double.compare`/`Float.compare` for floating point (NaN and -0.0 misbehave under `==`), `Arrays.equals` for arrays.

## Red flags

- `equals` without `@Override`
- `equals` overridden and `hashCode` not
- `getClass() != o.getClass()` in a class with subclasses — it breaks symmetry against a subclass instance; `instanceof` with a `final` class avoids the whole question
- A class that does not need logical equality overriding `equals` at all — identity equality is the right default
