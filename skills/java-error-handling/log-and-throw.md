# Log and Throw

Logging and rethrowing feels prudent. It duplicates the stack trace, inflates log ingestion, and dilutes the real cause in noise — which makes incidents more expensive and lengthens time to diagnosis.

```java
// AVOID: log and throw
try {
    gateway.process(orderId);
} catch (RuntimeException e) {
    log.error("process[orderId={}]", orderId, e);
    throw e;
}

// USE: preserve cause and context, log elsewhere
try {
    service.process(orderId);
} catch (RuntimeException e) {
    throw new InfrastructureException("processOrder[orderId=%s]".formatted(orderId), e);
}
```

**Log once, where the failure policy is decided** — the HTTP boundary, the job, the consumer. That is the layer that chooses retry, fallback or the final response. Inner layers do not narrate the error; they propagate it with cause and context preserved.

## The one exception

With distributed tracing, when execution crosses threads, pools or queues, the trace context can be lost — say, if propagation is not configured correctly in Spring. At those transition points a structured log carrying `traceId`/`correlationId` can be justified to keep correlation. Even then it must be informational: no stack trace, and not a duplicate of the error the edge will handle. Configuring the framework's own context propagation is still the better fix.

## In the Javadoc

Describe the contract, not the implementation. State under which conditions the operation can fail and what the caller is responsible for; use `@throws` for the observable scenario. Log policy is not part of a method's contract — record it in an ADR or the service README.

## Red flags

- `log.error(...)` immediately followed by `throw`
- The same failure appearing more than once in the logs of one request
- A stack trace logged in a layer that does not decide what happens next
- `@throws` documenting an implementation detail instead of the caller's obligation
