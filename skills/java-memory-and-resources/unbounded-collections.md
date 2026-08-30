# Collections That Grow Forever

An in-memory history that never drops anything is one of the subtlest leaks. It never fails in development; in production, after weeks of uptime, the heap fills until `OutOfMemoryError`.

```java
// LEAK: the list grows without bound
public class AuditApi {
    private List<RequestEvent> history = new ArrayList<>();

    public void register(HttpServletRequest req, HttpServletResponse res) {
        history.add(new RequestEvent(req.getRequestURI(), res.getStatus(), LocalDateTime.now()));
    }
}
// 100 req/s = 8.6M events/day, held forever
```

The GC only removes objects with no live references. A list used as permanent history keeps every event reachable — and if an event holds a `User`, a request or a response, all of those are retained too.

```java
// FIX: a bounded queue
private static final int MAX_EVENTS = 10_000;
private final Queue<RequestEvent> history = new ConcurrentLinkedQueue<>();
private final AtomicInteger size = new AtomicInteger();

public void register(HttpServletRequest req, HttpServletResponse res) {
    history.add(new RequestEvent(...));
    if (size.incrementAndGet() > MAX_EVENTS) {
        history.poll();
        size.decrementAndGet();
    }
    logger.info("Event registered: {}", event);   // the durable record
}
```

**Note the concurrency.** An audit hook runs on every request, from many threads at once. `ArrayList` and `LinkedList` are not thread-safe — under load they corrupt or lose entries, and `size()` on a `LinkedList` you are also polling is not atomic with the poll. Use a concurrent structure, or guard the whole thing with a lock.

If the bound should be time rather than count, expire periodically with `@Scheduled` or a `ScheduledExecutorService`. Safer still: do not keep the events in memory. Write them to a structured log or a database and query when needed.

**No in-memory structure in a long-running application may grow without a bound.**

## Red flags

- A collection field that only ever gets `add` called on it
- A cache with no eviction policy or TTL — use Caffeine, not a `HashMap`
- A `static` collection accumulating per-request data
- A `ThreadLocal` never cleared on a pooled thread
- Retained events holding whole request/response objects instead of extracted fields
