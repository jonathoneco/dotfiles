# 07-instrumentation.md

Use when the work changes runtime behavior, ownership boundaries, workflow state, deployment risk, or anything that future debugging needs to observe.

Include:

- product or operational questions the instrumentation must answer
- factual events to emit
- log fields and correlation identifiers
- metrics or counters, if useful
- derived reporting that must stay outside factual events
- dashboards, queries, or smoke evidence commands
- claims the package can make
- claims the package must not make
- absence assertions for boundaries the slice must not cross
- privacy and secret-handling constraints
- rollout/cutover evidence requirements
- instrumentation or validation facts to delete when temporary scaffolding is removed

Keep facts separate from policy and metrics. Events should record what happened; derived reporting can interpret whether that was good, bad, expected, or anomalous.

For pre-cutover work, explicitly separate validation facts from product facts. A temporary event or state can prove an internal lifecycle reached a boundary, but the evidence doc must say what it does not prove.

## Template

````md
# Instrumentation

## Questions to answer

- ...

## Events

| Event | When emitted | Required fields | Consumer |
| ----- | ------------ | --------------- | -------- |
| ...   | ...          | ...             | ...      |

## Logs

...

## Metrics and derived reporting

...

## Smoke evidence

```sh
...
```

## Claims

This package can claim:

- ...

This package cannot claim:

- ...

## Absence assertions

- <thing that must not happen>: <test/query/guard proving absence>
- ...

## Boundary guards

- subscriber behavior:
- provider or external calls:
- scheduled jobs:
- generated artifacts:

## Privacy constraints

...

## Temporary instrumentation to remove

...
````
