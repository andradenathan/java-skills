# Java Skills

Java skills for coding agents, derived from **Wanderlei Souza's Pílulas de Java** ("Java Pills") series.

All the technical content — the problems, the code examples, the practical rules — comes from that series. This repository only reorganizes the material into skill form: compressed, routed by symptom, and optimized for context cost.

## Install

```sh
./install.sh
```

Symlinks every skill into `~/.claude/skills`, so a `git pull` updates them in place. Start a new Claude Code session to pick them up.

| Flag | Effect |
|---|---|
| `--copy` | copy instead of symlinking (for a machine that will not keep this repo) |
| `--target DIR` | install elsewhere — e.g. `--target ./.claude/skills` to scope them to one project |
| `--list` | show which skills are installed and how |
| `--uninstall` | remove the skills this repo installed |
| `--force` | overwrite (or remove) a target directory that is not ours |

The script never clobbers a skill directory it did not install: an unrelated `java-enums` already in the target is skipped, on install and on uninstall alike, unless you pass `--force`. `CLAUDE_SKILLS_DIR` works as a default for `--target`.

## Structure

```
skills/
  <family>/
    SKILL.md        # router: frontmatter + symptom -> file table
    <topic>.md      # content, loaded on demand
```

Only the `SKILL.md` files are discovered by the agent, and only their `description` enters every conversation. Topic files are read when the router points at them. That is why the pills are grouped into families instead of becoming one skill each: 11 descriptions loaded instead of 55.

| Skill | Covers |
|---|---|
| `java-functional-style` | stream vs loop, Predicate/Function/Supplier/Consumer, `@FunctionalInterface`, boxing, Collectors, Optional |
| `java-enums` | extension, EnumMap/EnumSet, behavior on the constant, serialization |
| `java-object-methods` | `equals`, `hashCode`, `toString`, `compareTo` |
| `java-oo-design` | interfaces, inheritance vs composition, anemic models, DI, builders, immutability, visibility |
| `java-error-handling` | catching, translating, `finally`, Result, retry, exceptions in async contexts |
| `java-generics` | invariance and PECS, `@SuppressWarnings`, typesafe heterogeneous container |
| `java-concurrency` | race conditions, async composition, Spring thread pools, virtual thread pinning |
| `java-memory-and-resources` | resource leaks, unbounded collections, weak references, allocation |
| `java-test-data` | list fixtures, Datafaker + Instancio |
| `java-deserialization` | native serialization, gadget chains, `ObjectInputFilter` |
| `marker-annotation-aop` | auditing with a marker annotation and Spring AOP |

## How the text was compressed

A post exists to persuade; a skill exists to let the agent decide. Every sentence that only persuades is a spent token. What remains:

- **trigger** — the `description`, written as a symptom ("an object went missing from a HashSet"), never as a summary of the content
- **rule** — a decision table wherever the prose was already a list
- **counter-example** — the AVOID/USE code, commented only where the comment says *why*
- **red flags** — what to look for in a diff

Cut systematically: definitions of standard APIs the model already knows, evidence that only argues prevalence, engagement questions, and the second example when it repeats the shape of the first.

## Additions

Some files carry points that were not in the original posts — boundaries of a rule, silent failure modes, and adjacent traps. A few examples:

- a `record` is not automatically immutable: a `List` field needs `List.copyOf`
- `reversed()` reverses the whole `Comparator` chain, not the last key
- retrying a non-idempotent write can charge twice
- `@Enumerated` defaults to `ORDINAL`, which breaks when constants are reordered
- `ThreadPoolTaskExecutor` only grows once the queue is full
- hoisting `SimpleDateFormat` into a `static final` field trades allocation for data corruption

They are marked in the text where they change how the original rule reads.

## Credit

Original content: **Wanderlei Souza** — Pílulas de Java.
