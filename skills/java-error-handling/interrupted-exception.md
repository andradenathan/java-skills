# InterruptedException Is a Cancellation Request

Blocking methods — `Thread.sleep()`, `Future.get()`, `BlockingQueue.take()` — throw `InterruptedException` when the thread is interrupted while waiting. That happens routinely: `ExecutorService.shutdownNow()` during a deploy, a timeout cancelling a slow task, Structured Concurrency aborting sibling subtasks when one fails.

The request travels as an internal flag, the **interrupt status**. Throwing the exception *clears that flag automatically*. If the catch only logs and moves on, the flag stays clear and the thread has lost the only signal telling it to stop.

```java
// AVOID: flag consumed, thread ignores the shutdown
try {
    var order = queue.take();
    exporter.send(order);
} catch (InterruptedException e) {
    log.warn("Thread interrupted");
}

// USE: flag restored, execution ends cooperatively
try {
    var order = queue.take();
    exporter.send(order);
} catch (InterruptedException e) {
    Thread.currentThread().interrupt();
    return;
}
```

The failure is silent in production. Shutdown interrupts the active threads; one that swallows the exception keeps running. The process may never terminate, the deploy hangs, and the container eventually kills everything by force — cutting tasks mid-flight with no cleanup.

Two steps, in order: **restore the flag** with `Thread.currentThread().interrupt()`, then propagate the cancellation or end cooperatively. Cooperative cancellation depends entirely on the interrupt status; with virtual threads this comes up far more often.

If the method can declare it, the cleanest choice is not catching at all — let `InterruptedException` propagate to a caller that knows how to stop.

## Red flags

- `catch (InterruptedException e)` with no `Thread.currentThread().interrupt()`
- `InterruptedException` rethrown as a `RuntimeException` without restoring the flag
- `InterruptedException` swallowed inside a library — it destroys the caller's cancellation
- Code that keeps working after the catch, as if nothing was requested
