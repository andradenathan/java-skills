# Before @SuppressWarnings("unchecked")

`@SuppressWarnings("unchecked")` is a last resort for when you have *proven* a cast safe and the compiler cannot see the proof — not a way to quiet it. Often the JDK offers an explicit check instead.

The common case: handlers, plugins or strategies loaded by configuration. The system reads a class name, loads it by reflection, and hopes it implements an interface.

```java
// AVOID: the generic part of the cast is erased at runtime —
// nothing has proven rawType implements PaymentProvider.
Class<?> rawType = Class.forName(config.get("payment.provider.class"));

@SuppressWarnings("unchecked")
Class<? extends PaymentProvider> providerType =
        (Class<? extends PaymentProvider>) rawType;

PaymentProvider provider = providerType.getDeclaredConstructor().newInstance();

// USE: Class.asSubclass checks and keeps the type.
Class<?> rawType = Class.forName(config.get("payment.provider.class"));

// if rawType is FraudReport, this throws ClassCastException right here
Class<? extends PaymentProvider> providerType =
        rawType.asSubclass(PaymentProvider.class);

PaymentProvider provider = providerType.getDeclaredConstructor().newInstance();
```

`asSubclass` does two things at once: verifies at runtime that the loaded class really is a subtype, and returns `Class<? extends PaymentProvider>`, preserving the type for everything downstream. A silent cast becomes an explicit check that fails at the loading boundary — before the constructor runs and before a business method blows up three layers away.

## When you must suppress anyway

- Put the annotation on the **smallest possible declaration** — a local variable, never a method or class. A method-wide suppression hides warnings you never inspected.
- Add a comment explaining *why* the cast is safe. This is one of the few places a comment earns its keep.

## Red flags

- `@SuppressWarnings("unchecked")` on a method or class
- A suppression with no comment justifying it
- Casting a `Class<?>` from reflection instead of `asSubclass`
- `ClassCastException` surfacing far from where the object was created

Related: `typesafe-heterogeneous-container.md`
