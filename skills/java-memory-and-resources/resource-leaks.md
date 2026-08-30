# AutoCloseable Does Not Close Anything

Implementing `AutoCloseable` does not make a resource close itself. It has no integration with the garbage collector — it only tells the compiler your class may participate in try-with-resources. Instantiate it normally and never call `close()`, and the resource stays open like any other.

```java
public class InvoiceGenerator implements AutoCloseable {
    private final HttpClient client = HttpClient.newHttpClient();
    @Override public void close() { client.close(); }
}

// WRONG — close() never runs, connections leak, the pool drains
public void process(List<InvoiceData> invoices) {
    InvoiceGenerator generator = new InvoiceGenerator();
    for (InvoiceData data : invoices) generator.issue(data);
}

// RIGHT — try-with-resources closes on every path, exception included
public void process(List<InvoiceData> invoices) {
    try (InvoiceGenerator generator = new InvoiceGenerator()) {
        for (InvoiceData data : invoices) generator.issue(data);
    }
}
```

The GC frees Java memory only. It does not release external resources: connections, file handles, database locks. `finalize()` was deprecated precisely because it is unpredictable and may never run — `Cleaner` is its modern replacement, and it is a safety net, not a closing mechanism.

## Short-lived vs shared

Try-with-resources is right for a resource scoped to a block. A client meant to live for the application — an `HttpClient`, a connection pool, a Kafka producer — should not be created per request at all. Make it a singleton or a managed bean and tie its `close()` to the application lifecycle.

## Red flags

- An `AutoCloseable` created with `new` outside a try-with-resources header
- `close()` inside a `finally` (see `java-error-handling/finally-and-control-flow.md`)
- A `close()` implementation relying on `finalize` or a `Cleaner` to actually run
- An expensive client instantiated inside a request-scoped method
- A connection pool that drains after N operations — count the creations, not the closes
