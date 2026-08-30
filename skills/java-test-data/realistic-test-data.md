# Realistic Test Data — Datafaker + Instancio

Hardcoded strings are fragile. The eternal "João Silva" never exercises the locale, length, or special characters that show up in production.

**Use Datafaker** (`net.datafaker`, Java 17+). JavaFaker (`com.github.javafaker`) has had no release since January 2020; Datafaker is the active fork, keeps nearly the same API, and is roughly 4x faster.

## Always pass a seed

Without one, a failure appears in CI and will not reproduce locally — the test becomes a lottery.

```java
Faker faker = new Faker(new Locale("pt", "BR"), new Random(42L));

List<User> users = Stream.generate(() -> new User(
                faker.name().fullName(),
                faker.internet().emailAddress(),
                faker.number().numberBetween(18, 80)))
        .limit(50)
        .toList();

// local patterns: # digit, ? letter, bothify both
String cpf = faker.numerify("###.###.###-##");
String sku = faker.bothify("???-####");
```

Datafaker also exposes Schemas that emit CSV, JSON, XML or YAML in one call — useful for integration fixtures without extra libraries.

## Nested graphs: add Instancio

When the object has a nested graph or collections, manual `Stream.generate` turns into boilerplate. Instancio builds the graph respecting the types; Datafaker injects realism into the fields that matter.

```java
Customer customer = Instancio.of(Customer.class)
        .supply(field(Customer::email),    () -> faker.internet().emailAddress())
        .supply(field(Customer::fullName), () -> faker.name().fullName())
        .withSeed(42L)
        .create();
```

Seed both libraries — Instancio fills what you did not specify, so an unseeded `create()` is as non-deterministic as an unseeded `Faker`.

## Red flags

- `new Faker()` with no `Random` seed
- A CI failure that will not reproduce locally on a data-driven test
- `com.github.javafaker` in a new project
- Random data feeding an assertion that depends on its exact value — generate the realism, assert on the invariant
