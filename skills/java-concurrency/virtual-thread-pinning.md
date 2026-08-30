# Virtual Thread Pinning (JDK 21–22)

Virtual threads run on carrier threads (real OS threads). Normally, when a virtual thread blocks on I/O it unmounts, freeing the carrier for another. **On JDK 21 and 22 that does not happen inside a `synchronized` block**: the virtual thread stays pinned to its carrier until the operation finishes. Pin every carrier and the application stops.

```java
// Pinned on Java 21/22, safe from Java 24
private final Map<String, String> cache = new ConcurrentHashMap<>();

public String readFile(String name) {
    return cache.computeIfAbsent(name, key -> {
        try {
            return Files.readString(Path.of("/data/" + key + ".txt"));  // blocking I/O
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    });
}
```

It also happened inside core library code — `ConcurrentHashMap.computeIfAbsent` synchronizes on a bin — which made it hard to diagnose. Thread dumps looked idle while every carrier was busy holding a pinned virtual thread. Netflix hit exactly this in production.

JEP 491 (Java 24) removed it by tying monitors to the virtual thread instead of the carrier.

## What to do

| Your stack | Action |
|---|---|
| Java 24+ / Spring Boot 3.3+ | nothing — `synchronized` no longer pins |
| Java 21–22 with `spring.threads.virtual.enabled=true` | review urgently |
| Not on virtual threads yet | no pinning risk, but the hardware is underused |

On 21/22: avoid blocking calls inside `synchronized`, replace the lock with `ReentrantLock` where needed (it unmounts correctly), and monitor with `-Djdk.tracePinnedThreads=full`.

Even on 24+, a virtual thread still pins in a native frame or a foreign function call — rare, but it is why the `jdk.VirtualThreadPinned` JFR event still exists.

## Red flags

- `synchronized` around I/O, a database call or an HTTP request
- `computeIfAbsent` on a `ConcurrentHashMap` whose mapping function blocks
- Virtual threads enabled on JDK 21/22 with no pinning monitoring
- Throughput collapsing under load while thread dumps look idle
