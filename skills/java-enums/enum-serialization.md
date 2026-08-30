# Enum Names Are Not a Contract

Jackson serializes enums using `name()` by default. Rename a constant, change its casing, adjust an accent — and the payload changes. Clients stop recognizing values, and old stored data no longer deserializes.

These are invisible breaking changes: the code still compiles, local tests pass, production data stops making sense.

```java
// WRONG — the wire format depends on the constant's name
public enum Role { ADMIN, USER }

// RIGHT — a stable code as the external contract
public enum Role {
    ADMIN("A", "Administrator"),
    USER("U", "User");

    private final String code;
    private final String displayName;

    Role(String code, String displayName) {
        this.code = code;
        this.displayName = displayName;
    }

    @JsonValue
    public String getCode() { return code; }

    @JsonCreator
    public static Role fromCode(String code) {
        if (code == null) throw new IllegalArgumentException("Code cannot be null.");
        for (Role role : values()) {
            if (role.code.equals(code)) return role;
        }
        throw new IllegalArgumentException("Invalid code: " + code);
    }

    @Override
    public String toString() { return displayName; }   // display and logs only
}
```

Treat `code` as a stable, versioned external contract so the domain can evolve without breaking the API. The contract should reflect the domain, not the constant's name — you control the code, not who already consumes your JSON.

## The same bug in the database

`@Enumerated(EnumType.ORDINAL)` — the JPA default — stores the constant's *position*. Reorder the constants or insert one in the middle and every existing row now means something else. Always `@Enumerated(EnumType.STRING)`, or map an explicit `code` with a converter, which is the persistence twin of `@JsonValue`.

## Custom (de)serializers

When you want a wire format the constants cannot express — `"in-progress"` for `IN_PROGRESS`, say — a `JsonSerializer`/`JsonDeserializer` pair does it:

```java
public class StatusDeserializer extends JsonDeserializer<Status> {
    @Override
    public Status deserialize(JsonParser p, DeserializationContext ctxt) throws IOException {
        return switch (p.getText().toLowerCase()) {
            case "new" -> Status.NEW;
            case "in-progress" -> Status.IN_PROGRESS;
            case "completed" -> Status.COMPLETED;
            default -> throw new IllegalArgumentException("Unknown status: " + p.getText());
        };
    }
}

@JsonDeserialize(using = StatusDeserializer.class)
private Status status;
```

Prefer `@JsonValue`/`@JsonCreator` when you own the enum: the mapping lives on the constant, so adding one cannot be forgotten. A separate deserializer keeps the mapping in a second place that no compiler ties to the enum — reach for it when you do not own the type, or when the format needs logic beyond a lookup. Either way, reject unknown input explicitly rather than falling back to a default constant.

## Red flags

- An enum crossing an API or landing in a database with no explicit code
- `name()` or `valueOf` on a value that came from outside
- `@Enumerated` left at its default, or set to `ORDINAL`
- A renamed constant in a diff with no migration
- `toString()` used as the serialized form
- A custom deserializer whose switch silently drifts from the enum's constants
