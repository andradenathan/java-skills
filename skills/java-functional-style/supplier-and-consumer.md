# Supplier vs Consumer

A variable holds a computed value. A `Supplier<T>` holds *how to produce* it; a `Consumer<T>` holds *what to do* with it. Pass behavior when the work must happen later, conditionally, or repeatedly.

## Decide

| Signature | Passes | Found in |
|---|---|---|
| `Supplier<T>` — `T get()` | how to produce a value | `orElseGet`, `orElseThrow` |
| `Consumer<T>` — `void accept(T)` | what to do with a value | `forEach`, `ifPresent` |

## Anti-pattern: eager argument to `orElse`

```java
// AVOID: findDefaultAccount() runs even when the account exists —
// arguments are evaluated before the method is called.
Account account = repository.findById(id).orElse(findDefaultAccount());

// USE: runs only when the Optional is empty.
Account account = repository.findById(id).orElseGet(() -> findDefaultAccount());
```

`orElse` is for values already at hand (a constant, a field). Anything computed goes in `orElseGet`.

## Anti-pattern: `andThen` as if it isolated failures

```java
Consumer<Account> notify = notifier::sendStatement;
Consumer<Account> audit  = auditTrail::record;

// AVOID: if notify throws, the audit is never recorded.
accounts.forEach(notify.andThen(audit));

// USE: order by what must happen first.
accounts.forEach(audit.andThen(notify));
```

`andThen` chains, it does not guard. A throw in the first consumer skips the second.

## Red flags

- A method call written directly inside `orElse` / `orElseThrow`
- Assuming a `Supplier` caches — every `get()` re-executes
- `andThen` used where the second action must run regardless (needs try/catch, not composition)
