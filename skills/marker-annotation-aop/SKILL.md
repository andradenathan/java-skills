---
name: marker-annotation-aop
description: Use when audit or other cross-cutting logging is written inside Spring business methods - repeated SecurityContextHolder plus log.info blocks, or when deciding between a custom @Aspect, Hibernate Envers/JaVers, Micrometer and Actuator audit events
---

# Marker Annotation + Spring AOP

Auditing a business operation answers one question: who ran which action? Written inside the method, the financial rule and the tracking couple together, and every new method repeats the same capture-user-and-log block.

A **marker annotation** — empty, no attributes — carries no behavior. It only marks which methods are auditable domain actions. A single `@Aspect` gives it effect.

## Pattern

```java
// AVOID: audit mixed into the business rule.
@Service
public class PaymentService {
    public Receipt process(Payment payment) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        log.info("audit user={} action=process", auth.getName());
        return execute(payment);
    }
}

// USE: marker annotation — semantics only.
@Retention(RetentionPolicy.RUNTIME)   // without RUNTIME the proxy cannot see it
@Target(ElementType.METHOD)
public @interface Audited {}

@Aspect
@Component
public class AuditAspect {

    @Around("@annotation(com.example.Audited)")
    public Object audit(ProceedingJoinPoint pjp) throws Throwable {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String user = (auth != null) ? auth.getName() : "anonymous";
        Object result = pjp.proceed();
        // logged after success — the record means the action completed
        log.info("audit user={} action={}", user, pjp.getSignature().getName());
        return result;
    }
}

// The service now expresses only intent.
@Service
public class PaymentService {
    @Audited
    public Receipt process(Payment payment) {
        return execute(payment);
    }
}
```

## Pick the right layer

| Concern | Tool |
|---|---|
| data state changes over time | Hibernate Envers / JaVers |
| latency and metrics | Micrometer |
| which business action ran, and by whom | marker annotation + AOP |

## Use it when

The annotation communicates architectural intent and the aspect implements a cross-cutting behavior — never a central business rule. Logic that decides an outcome belongs in the service, visible; hiding it in a proxy makes it invisible at the call site.

## Red flags

- A marker annotation without `@Retention(RUNTIME)` — silently never applies
- Aspect advice that changes the return value or swallows exceptions
- Self-invocation inside the same bean — the proxy is bypassed, the aspect never runs
- Logging before `proceed()` when the record is meant to mean "action completed"
- Reaching for AOP where Envers, Micrometer or Actuator audit events already fit
