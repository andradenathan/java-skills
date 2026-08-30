# Loop vs Stream

Same repetition, different constructs: streams use function objects, loops use code blocks. Not modern vs old — pick by what the rule needs.

## Decide

| Need | Use |
|---|---|
| map / filter / group / reduce / findFirst over a sequence | stream |
| mutate a local variable | loop |
| `return` from the enclosing method | loop |
| propagate a checked exception | loop |

A lambda cannot: assign to captured locals (reads only final/effectively final), return from the caller, or throw checked exceptions through the standard `java.util.function` interfaces.

Mixing is fine and usually best: pipeline for the transformation, loop for the rest. Do not force one pipeline.

## Anti-pattern: field-hoisting to feed a lambda

```java
// AVOID: local promoted to field just so the lambda can assign it —
// now shared across calls and threads.
private BigDecimal settled = BigDecimal.ZERO;

BigDecimal settle(List<Transaction> transactions) {
    transactions.forEach(transaction -> {
        BigDecimal next = settled.add(transaction.amount());
        if (next.compareTo(DAILY_SETTLEMENT_LIMIT) <= 0) settled = next;
        // forEach keeps consuming; early stop needs Gatherers (Java 24)
    });
    return settled;
}

// USE: local total, return exits on overflow.
BigDecimal settle(List<Transaction> transactions) {
    BigDecimal settled = BigDecimal.ZERO;
    for (Transaction transaction : transactions) {
        BigDecimal next = settled.add(transaction.amount());
        if (next.compareTo(DAILY_SETTLEMENT_LIMIT) > 0) return settled;
        settled = next;
    }
    return settled;
}
```

## Readability

- Refactor loop↔pipeline only when it reads better. Never by default.
- Lambda params have no explicit type: name them `transaction`, `order` — not `t`, `o`.
- Extract long stages into named helper methods.

## Red flags

- A field exists only so a lambda can write to it
- `forEach` with an `if` that should have been a `return`
- A pipeline you have to re-read to follow
