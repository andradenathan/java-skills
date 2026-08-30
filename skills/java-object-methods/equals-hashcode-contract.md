# The equals / hashCode Contract

If two objects are equal by `equals`, they must return the same `hashCode`. Breaking this produces no compile error and no exception — just silently wrong behavior.

`HashSet`/`HashMap` are numbered drawers. `add(customer)` computes `hashCode()` = 42 and stores it in drawer 42; `contains(customer)` computes it again, opens drawer 42, finds it.

**Override `equals` but not `hashCode`** and two equal objects hash to 42 and 87: stored in one drawer, looked up in another.

**Compute `hashCode` from a mutable field** and the same thing happens over time. Change the field after insertion and the hash moves from 42 to 87. The object is still physically in drawer 42 — `size()` counts it, iteration shows it — but `contains()` returns false. A ghost.

## Lombok @Data is a trap

`@Data` bundles `@Getter`, `@Setter`, `@ToString`, `@RequiredArgsConstructor` and `@EqualsAndHashCode` over **all** fields. Combined with `@Setter` on a mutable entity, fields like `name` or `email` come to define identity, and any setter corrupts lookup.

```java
// AVOID
@Data @Entity
public class Customer {
    @Id private Long id;
    private String name;
    private String email;
}
// Any setter changes the hashCode and the object becomes a ghost in a HashSet.

// USE
@Getter @Setter
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@Entity
public class Customer {
    @Id @EqualsAndHashCode.Include private Long id;
    private String name;
    private String email;
}
```

`onlyExplicitlyIncluded = true` inverts Lombok's default: only fields marked `@EqualsAndHashCode.Include` count.

## Records vs JPA entities

For DTOs and value objects, **records replace `@Data`** outright: native immutability, no ghosts.

Records do not fit as JPA entities. The spec requires a no-arg constructor, and Hibernate needs the class and its fields non-`final` to build proxies and lazy loading; records are `final` with `final` fields and no empty constructor. `@Getter`/`@Setter` stay legitimate there — as long as `equals` and `hashCode` are controlled explicitly.

## The JPA id problem

A database-generated `@Id` is `null` before persist, so an entity's hash changes when it is saved — the same ghost, in a collection that spans the transition. Two workable fixes: assign a UUID business key in the constructor and use that, or make `hashCode()` return a constant for the class so it stays stable while `equals` compares the id.

## Red flags

- `@Data` on a `@Entity`
- `hashCode` computed from any field with a setter
- An object in a `HashSet` that `contains()` cannot find
- `equals` including a field the `hashCode` omits, or vice versa
