# Typesafe Heterogeneous Container

`Map<String, Object>` works but pushes type control onto the caller: a typo in the key returns `null` silently, every read needs a cast, and nothing ties a key to the type of its value.

**Invert where the generics go: parameterize the key, not the container.** `Class<T>` is built for the role — `String.class` has type `Class<String>`, so the key carries the type at compile time *and* at runtime. That is a type token.

## Pattern

```java
// AVOID
Map<String, Object> registry = new HashMap<>();
registry.put("port", 8080);

Integer port = (Integer) registry.get("prot");  // typo → null
registry.put("port", "8080");                   // wrong type still compiles

// USE
public class TypedRegistry {
    private final Map<Class<?>, Object> values = new HashMap<>();

    public <T> void put(Class<T> type, T value) {
        // the compiler ties the value to the key's type
        values.put(Objects.requireNonNull(type), value);
    }

    public <T> T get(Class<T> type) {
        // dynamic cast checked by the class itself — no warning, no client cast
        return type.cast(values.get(type));
    }
}

registry.put(String.class, "production");
registry.put(Integer.class, 8080);

String env = registry.get(String.class);   // no cast
Integer port = registry.get(Integer.class);
```

The map stays `Map<Class<?>, Object>`; the safety comes from the API around it.

You already use this daily: it is the mechanics behind `getBean(MyService.class)` in Spring and `readValue(json, MyDto.class)` in Jackson.

## Limits

- **One value per type.** The type *is* the key, so two `String` entries collide. If you need several, the key must be a distinct type or a custom key object.
- **No generic types.** `List<String>.class` does not exist — erasure leaves only `List.class`, so `List<String>` and `List<Integer>` share a key. Storing those needs a super type token (a subclassed generic holder), not `Class<T>`.
- `type.cast(null)` returns `null`, so a missing key looks like a stored null.

## Red flags

- `Map<String, Object>` where the caller casts every `get`
- A cast whose correctness depends on a string literal matching elsewhere
- `@SuppressWarnings("unchecked")` on a container read — `Class.cast` removes the need
