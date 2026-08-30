# Do Not Trust Spring's Default Thread Pools

By default every `@Scheduled` task runs on a **single** scheduling thread. One task that hangs stops all of them, and one that runs long delays the rest.

```properties
spring.task.scheduling.pool.size=5
```

Or programmatically, which also lets you size from the runtime:

```java
@EnableScheduling
@Configuration
public class SchedulerConfig {
    @Bean
    public TaskScheduler taskScheduler() {
        ThreadPoolTaskScheduler scheduler = new ThreadPoolTaskScheduler();
        scheduler.setPoolSize(5);
        return scheduler;
    }
}
```

`Runtime.getRuntime().availableProcessors()` works for a dynamic size — on Kubernetes it reflects the container's CPU limit, so verify what it actually returns under your resource settings.

Spring Boot hides several pools — `@Async`, `WebClient`, `TaskExecutor`. They exist to get you started; under load they cause strange stalls. In production, define your own `ThreadPoolTaskExecutor` with explicit sizes and queue.

## The queue trap

`ThreadPoolTaskExecutor` grows past `corePoolSize` only when the queue is **full**. Leave `queueCapacity` at its default (effectively unbounded) and `maxPoolSize` is never reached — the pool stays at core size while work piles up in memory. Set a real `queueCapacity`, a `maxPoolSize`, and a rejection policy you chose deliberately.

## Red flags

- `@Scheduled` with no `spring.task.scheduling.pool.size` and more than one task
- `@Async` with no explicit executor
- `ThreadPoolTaskExecutor` with `maxPoolSize` set but no `queueCapacity`
- A pool sized by a number nobody can explain
- A long-running task on the scheduling pool instead of a work executor
