---
name: java-oo-design
description: Use when shaping Java classes and interfaces - XServiceImpl pairs, big interfaces, abstract base classes and default methods, extends used to add behavior, mutable domain values, new inside a class making it untestable, utility classes, builders, setters exposing domain state, a type enum with a switch and optional fields, testing private methods, or a nested class without static
---

# Java OO Design

Common thread: expose the least you can, and let the type carry what conditionals would otherwise re-derive.

**Interfaces**

| Question | File |
|---|---|
| Does this interface earn its existence? Is it too big? | `designing-interfaces.md` |
| How do I make an interface easy to implement? | `interface-with-base-implementation.md` |

**Where behavior and state live**

| Question | File |
|---|---|
| The rules all live in a `Service`, the class is just fields | `anemic-domain-model.md` |
| A `type` field plus a `switch` plus fields that apply to some cases | `sealed-hierarchies.md` |
| `extends` to add validation, logging or auditing | `composition-over-inheritance.md` |
| Static methods with no owning object | `utility-classes.md` |

**Construction and state**

| Question | File |
|---|---|
| Where does this class get its collaborators? | `dependency-injection.md` |
| Domain values changing under a shared reference | `immutable-value-objects.md` |
| Many constructor parameters, optional fields | `builders.md` |
| A constructor call whose arguments need a comment | `static-factory-methods.md` |

**Visibility**

| Question | File |
|---|---|
| How do I test this without making it public? | `encapsulation-and-testability.md` |
| Nested class, `static`, hidden memory retention | `nested-classes.md` |
