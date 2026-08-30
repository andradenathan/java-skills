# Java Skills

Skills de Java para agentes de código, derivadas das **Pílulas de Java do mestre Wanderlei Souza**.

Todo o conteúdo técnico — os problemas, os exemplos de código, as regras práticas — vem dessa série. Este repositório apenas reorganiza esse material no formato de skill: comprimido, roteado por sintoma e otimizado para custo de contexto.

## Estrutura

```
skills/
  <familia>/
    SKILL.md        # roteador: frontmatter + tabela sintoma -> arquivo
    <topico>.md     # conteúdo, carregado sob demanda
```

Apenas os `SKILL.md` são descobertos pelo agente, e só a `description` de cada um entra em toda conversa. Os arquivos de tópico são lidos quando o roteador aponta para eles. Por isso as pílulas são agrupadas por família em vez de virarem uma skill cada: 11 descriptions carregadas em vez de 55.

| Skill | Cobre |
|---|---|
| `java-functional-style` | stream vs loop, Predicate/Function/Supplier/Consumer, `@FunctionalInterface`, boxing, Collectors, Optional |
| `java-enums` | herança, EnumMap/EnumSet, comportamento na constante, serialização |
| `java-object-methods` | `equals`, `hashCode`, `toString`, `compareTo` |
| `java-oo-design` | interfaces, herança vs composição, modelo anêmico, DI, builders, imutabilidade, visibilidade |
| `java-error-handling` | captura, tradução, `finally`, Result, retry, exceções em contexto assíncrono |
| `java-generics` | invariância e PECS, `@SuppressWarnings`, container heterogêneo tipado |
| `java-concurrency` | race conditions, composição assíncrona, thread pools do Spring, virtual thread pinning |
| `java-memory-and-resources` | vazamento de recursos, coleções sem limite, referências fracas, alocação |
| `java-test-data` | fixtures de lista, Datafaker + Instancio |
| `java-deserialization` | serialização nativa, gadget chains, `ObjectInputFilter` |
| `marker-annotation-aop` | auditoria com marker annotation e Spring AOP |

## Como o texto foi comprimido

O post existe para convencer; a skill existe para o agente decidir. Toda frase que serve só para persuadir é token gasto. O que sobra:

- **gatilho** — a `description`, escrita como sintoma ("um objeto sumiu do HashSet"), nunca como resumo do conteúdo
- **regra** — tabela de decisão sempre que a prosa já era uma lista
- **contra-exemplo** — o código AVOID/USE, com comentário só onde ele diz o *porquê*
- **red flags** — o que procurar num diff

Cortado sistematicamente: definições de API que o modelo já sabe, evidência que só argumenta prevalência, perguntas de engajamento, e o segundo exemplo quando ele repete a forma do primeiro.

Os arquivos estão em inglês por custo de token, não por preferência.

## Acréscimos

Alguns arquivos trazem pontos que não estavam nos posts originais — limites de regra, modos de falha silenciosa e armadilhas vizinhas. Alguns exemplos:

- `record` não é automaticamente imutável: campo `List` precisa de `List.copyOf`
- `reversed()` inverte a cadeia inteira de um `Comparator`, não a última chave
- retry em escrita não idempotente pode cobrar duas vezes
- `@Enumerated` no default é `ORDINAL` e quebra ao reordenar constantes
- `ThreadPoolTaskExecutor` só cresce quando a fila enche
- hoistar `SimpleDateFormat` para `static final` troca alocação por corrupção de dados

Eles são marcados no texto quando alteram a leitura da regra original.

## Crédito

Conteúdo original: **Wanderlei Souza** — Pílulas de Java.
