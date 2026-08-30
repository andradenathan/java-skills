# toString

The API docs ask that subclasses override `toString` and that the result be concise, informative and readable. The common mistake is not forgetting it — it is turning it into an object-graph traversal.

The damage starts when `toString` prints whole associations, collections, bidirectional objects or huge fields:

- **Bidirectional JPA relations**: `Order.toString()` calls `Item.toString()` which calls back — `StackOverflowError`.
- **Hibernate lazy proxies**: a single log line touches an association, fires an unexpected `SELECT`, and outside the session throws `LazyInitializationException`.

```java
// AVOID: default @ToString on a JPA entity with a bidirectional relation.
@Entity @Getter @Setter @ToString
class Order {
    @Id private Long id;
    @OneToMany(mappedBy = "order", fetch = FetchType.LAZY)
    private List<Item> items = new ArrayList<>();
}

// USE: simple, stable, safe fields only.
@Entity @Getter @Setter
@ToString(onlyExplicitlyIncluded = true)
class Order {
    @ToString.Include @Id private Long id;
    @ToString.Include private String code;

    @OneToMany(mappedBy = "order", fetch = FetchType.LAZY)
    private List<Item> items = new ArrayList<>();
}
```

## Not a presentation layer

Postal codes, currency, dates and other locale-sensitive formats belong to `Locale` and dedicated formatters. A diagnostic representation and user-facing text are different things.

For enums the default is almost always enough. For immutable DTOs, records already produce a suitable `toString`.

## Red flags

- `@ToString` or `@Data` on a JPA entity
- `toString` returning a collection, an association, or a large field
- Currency/date formatting inside `toString`
- Passwords, tokens or personal data in `toString` — it ends up in logs, which is the one place they must not be
