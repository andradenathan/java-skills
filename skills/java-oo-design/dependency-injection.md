# Inversion of Control

You write the test, run it, and it sends a real email. Or you try to simulate a network failure and cannot. The code works in production but is impossible to validate in isolation. The cause is almost always one design decision: how the component obtains its dependencies.

Testability rests on two pillars — **controllability** (manipulating the inputs) and **observability** (inspecting the effects). Lose control of the dependencies and you lose both.

```java
// AVOID: fixed dependency, low testability
public class NotificationService {
    private final EmailSender sender = new EmailSender();
    public void notify(String msg) { sender.send(msg); }
}

// USE: injected dependency
public class NotificationService {
    private final MessageSender sender;
    public NotificationService(MessageSender sender) { this.sender = sender; }
    public void notify(String msg) { sender.send(msg); }
}

new NotificationService(new EmailSender());       // production
new NotificationService(new FakeSender());        // unit test
new NotificationService(new SlowSender(5000));    // resilience test
```

When a class creates its dependency with `new`, it couples itself to a concrete implementation: no test double, no simulated failure, and any swap means recompiling. Inverting that responsibility is **Inversion of Control** — the Hollywood Principle, "don't call us, we'll call you". Creating objects moves out of the component and into whoever assembles it.

Spring and Guice only automate this. The principle is unchanged: classes do not create their dependencies, they receive them.

## Constructor injection, not field injection

`@Autowired` on a field cannot be `final`, hides missing dependencies until runtime, and requires the container (or reflection) to build the object in a test. Constructor injection gives final fields, fails at startup when a dependency is missing, and lets a test build the object with `new`.

## Red flags

- `new` on a collaborator that does I/O, holds state, or reads a clock
- `@Autowired` on a field instead of a constructor parameter
- A test that needs the whole Spring context to exercise one rule
- A constructor with so many parameters that the class clearly does too much — inject less by splitting the class, not by switching to field injection
