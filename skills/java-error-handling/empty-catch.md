# Empty Catch

A method declares a checked exception, the IDE generates the `catch`, the developer accepts it, and an empty block reaches the repository with no explanation.

An empty catch is not neutral. To the next reader it raises an immediate question: forgotten bug, or deliberate decision? The exception is discarded, execution continues as if nothing happened, and the failure can resurface somewhere with no apparent link to the cause.

Sometimes ignoring *is* correct — closing a `FileInputStream` after the read already completed, for instance. The file state has not changed and there is nothing to recover. The problem is not the decision; it is leaving it unrecorded. **An intentional silent catch looks exactly like an accident.**

```java
// AVOID
} catch (NotDirectoryException e) {
}

// USE
} catch (NotDirectoryException ignored) {
    // Directory does not exist -> no logs to return
}
```

Two gestures turn ambiguity into documentation:

1. **Rename the variable to `ignored`.** It declares the discard is intentional, and many IDEs and linters recognize the convention and stop flagging the block.
2. **Add a CONDITION -> EFFECT comment.** What situation this covers, and what the program does as a result.

If you cannot explain why you are ignoring it, do not ignore it.

## Red flags

- `catch (...) { }` with no comment
- A catch containing only `// TODO` or `// should not happen`
- `catch` variable named `e` in a block that does nothing with it
- An exception ignored because handling it was inconvenient, not because there is nothing to recover
