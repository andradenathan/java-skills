---
name: java-deserialization
description: Use when Java code reads serialized objects - ObjectInputStream, readObject/readResolve, Serializable types crossing a trust boundary, Jackson polymorphic typing, or objects stored in Redis/Kafka/caches/sessions
---

# Native Deserialization

`ObjectInputStream` does not read data — it reconstructs objects, loading classes from the classpath and running their `readObject`/`readResolve`. With a gadget chain, code already present in your dependencies becomes a path to remote code execution. Treat an untrusted byte stream as untrusted *code*.

Severity is not theoretical: CVE-2025-20124 (Cisco ISE, 2025) was insecure Java deserialization giving an authenticated attacker command execution as root.

## Order of preference

1. **Do not deserialize untrusted input natively.** This is the only complete fix.
2. **Use a format with an explicit schema** — Protobuf, or JSON with concrete target types. The schema defines the structure and the payload carries no Java class names, so the receiver reads data instead of being told what to instantiate.
3. **If native is unavoidable**, constrain it (below).

In Spring, that means JSON or Protobuf for Redis, Kafka and APIs — and never open polymorphic typing in Jackson (`enableDefaultTyping`, unrestricted `@JsonTypeInfo`), which reintroduces the same class-from-payload problem.

## If native is unavoidable

```java
// AVOID: accepts any class arriving in the stream.
try (ObjectInputStream ois = new ObjectInputStream(input)) {
    Account account = (Account) ois.readObject();
}

// USE: explicit allowlist with ObjectInputFilter (JEP 290).
try (ObjectInputStream ois = new ObjectInputStream(input)) {
    // Allows Account, String and Number. Rejects everything else.
    ois.setObjectInputFilter(ObjectInputFilter.Config.createFilter(
        "maxdepth=5;maxrefs=50;com.acme.Account;java.lang.String;java.lang.Number;!*"
    ));
    Account account = (Account) ois.readObject();
}
```

The trailing `!*` is what makes it an allowlist — without it the filter denies nothing. `maxdepth`/`maxrefs` bound deserialization bombs. Then validate invariants in `readObject`: a deserialized object bypasses your constructors.

## Never serialize secrets

Passwords, tokens, keys and session data stay out of the stream. Mark internal fields `transient`; use DTOs to control what crosses a boundary. If something sensitive must be persisted, encrypt, sign and validate it.

## Red flags

- `new ObjectInputStream(...)` on anything reaching the process from outside
- `readObject` with no filter set, or a filter without a terminating `!*`
- `Serializable` on a type holding credentials, keys or session state
- Jackson default/polymorphic typing enabled globally
- `readObject` that assigns fields without re-checking invariants
