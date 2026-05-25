---
name: qa-engineer
description: QA engineering skill. Use when writing, reviewing, or fixing tests. Covers test structure, naming, assertions, mocking, coverage, and test-driven workflow.
metadata:
  type: skill
  trigger: manual
---

## Principles

- **Test behavior, not implementation.** If refactoring breaks the test, the test is wrong.
- **One thing per test.** One concept, one assertion path. Don't chain unrelated checks.
- **Fast and isolated.** No network, no filesystem, no database. Mock at the boundary.
- **Deterministic.** Same result every run. No `Date.now()`, no random, no shared state.

## Structure (AAA)

```text
Arrange  →  set up data and dependencies
Act      →  call the thing under test (one call)
Assert   →  verify the outcome
```

No setup in `beforeEach` unless it's truly shared boilerplate. Inline setup beats hidden setup.

## Naming

```text
<method>_<scenario>_<expected>
```

| Good | Bad |
|---|---|
| `transfer_fails_when_balance_insufficient` | `test_transfer_1` |
| `parse_returns_null_for_empty_input` | `test_parse_error` |

## Assertions

- **Precise.** `assertEquals(expected, actual)`, not `assertTrue(actual.contains("foo"))`.
- **One assert per concept.** Multiple `assertEquals` on the same result object is fine; asserting on three unrelated things is not.
- **Assert the positive AND the negative.** Test what happens AND what doesn't happen.

## Mocking

- **Mock your adapters, not third-party code.** Wrap external deps in your own interface, mock that.
- **Only mock what you own.** `EmailSender` → yes. `smtplib.SMTP` → no.
- **Verify behavior, not calls.** Prefer asserting the outcome over `verify(emailSender).send()`. Use call verification only when there's no visible side effect.
- **Don't over-mock.** Value objects and pure functions never need mocking.

## Coverage

- **Every branch, not every line.** Focus on decision points: `if`, `switch`, `catch`, `||`, `&&`, `??`.
- **Happy path first**, then: null/empty inputs, boundary values, error paths, concurrent access.
- **Untestable code is a design smell.** If you can't test it, the interface is wrong — refactor the code, not the test.

## Anti-Patterns

- **Testing the mock.** Asserting `mock.method()` was called without checking the actual outcome.
- **Mocking the subject under test.** Testing a partial mock returns its own stubs.
- **Testing the framework.** Don't test that `express.get()` registers routes or `@Autowired` injects.
- **Assertion-free tests.** "It doesn't throw" is not a test.
- **Sleep in tests.** `await sleep(1000)` is flaky. Use fake timers or event-driven assertions.
