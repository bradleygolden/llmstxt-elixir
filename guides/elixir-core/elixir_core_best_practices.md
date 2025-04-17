# Elixir Core Best Practices

> **Scope**: Opinionated guidelines for pure Elixir projects that depend only on the standard library and OTP. Use this as a living document in your repository (e.g., `docs/best_practices/elixir_core.md`). Contributions through pull‑requests are welcome.

---

## 1. Coding Philosophy

1. **Write for Readability** – Favor clear, intention‑revealing code over clever one‑liners. Future maintainers should understand a function’s purpose in *seconds*.
2. **Embrace Immutability** – Treat data as immutable; prefer pure functions that return new values instead of mutating in place.
3. **Let the BEAM Do the Hard Work** – Rely on OTP primitives (processes, supervisors, monitors) instead of reinventing reliability or concurrency mechanisms.
4. **Test First, Iterate Often** – Lean on fast ExUnit tests (and property‑based tests) to pin behavior before refactoring.

---

## 2. Project Layout & Naming

| Layer | Folder | Guidelines |
|-------|--------|------------|
| Mix project | `mix.exs` | Keep dependencies minimal; document every extra compilation option. |
| Source | `lib/` | Top‑level modules should map 1‑to‑1 to bounded contexts or subsystems. |
| Tests  | `test/` | Mirror `lib/` folder structure; put helpers in `test/support`. |
| Docs   | `docs/` | Store design docs & this guide here. |

* **Modules**: use `PascalCase`, no abbreviations unless industry‑standard (`HTTP`).
* **Functions**: use `snake_case`, verb first (`create_user/2`, not `user_create/2`).
* **Private functions**: suffix with `_` when name collision is unavoidable (`parse_/1`).

---

## 3. Style & Formatting

1. **`mix format` is canonical**. Commit a shared `.formatter.exs` and run it in CI.
2. Follow the community *Elixir Style Guide* for whitespace, line breaks, and pipeline indentation.
3. Limit lines to **100 columns**; wrap pipelines after `|>` when they exceed.
4. Prefer explicit `do:` one‑liners only for trivial guards; otherwise use multiline `do ... end` blocks.

---

## 4. Functions & Modules

### 4.4 Metaprogramming

* Keep macros minimal and focused. Avoid injecting runtime data at compile time, which creates wide recompilation graphs and surprising coupling.
* Prefer functions over macros unless you need compile‑time code generation or DSLs that truly improve ergonomics.

### 4.1 Single Responsibility

* A module should expose one public API (cohesive theme). If it grows beyond ~250 LOC or >10 public functions, break it apart.
* Encapsulate data by exposing *smart constructors* (`new/1`) and operating functions; avoid exposing raw `%Struct{}` internals.

### 4.2 Pattern Matching & Guard Clauses

* Prefer multi‑clause functions rather than case statements inside a single clause.

```elixir
def handle_event(%{type: :login} = event), do: do_login(event)
def handle_event(%{type: :logout} = event), do: do_logout(event)
```

* Use **guards** (`when`) for type constraints; keep guards simple and pure.

### 4.3 Pipelines

* Use pipelines (`|>`) for linear data transformation where each step shares a common data shape.
* Avoid pipelines for control flow; keep conditional branching outside the pipe for clarity.

---

## 5. Documentation & Commenting

1. Every public module/function **must** have `@moduledoc` / `@doc`.
2. Provide minimal, compilable `iex>` examples (doctests) where practical.
3. Reserve inline code comments for *why*, not *what*.
4. Generate HTML docs with `mix docs` and publish to HexDocs or GitHub Pages.

---

## 6. Testing Strategy

* Use **ExUnit** for unit tests; keep each test < 100ms.
* Adopt **property‑based testing** with `stream_data` for critical algorithms.
* Mock sparingly; prefer passing dependencies as module arguments (behaviours) to enable *explicit* test doubles.

```elixir
defmodule MyApp.Counter do
  @callback now() :: non_neg_integer()
  def increment(counter, clock \\ System), do: %{counter | value: counter.value + clock.now()}
end
```

---

## 7. Static Typing Strategy (Optional)

* Elixir v1.17 introduced **gradual set‑theoretic types** that automatically infer patterns and guards, letting the compiler surface many type errors without manual `@spec`s. ([elixir-lang.org](https://elixir-lang.org/blog/2024/06/12/elixir-v1-17-0-released/?utm_source=chatgpt.com), [elixirforum.com](https://elixirforum.com/t/elixir-v1-17-0-released/64151?utm_source=chatgpt.com))
* Because the native type checker is still evolving and syntax for explicit annotations may change, treat specs as **optional**. Keep them only where they add real clarity to a public API. ([elixir-lang.org](https://elixir-lang.org/blog/2023/06/22/type-system-updates-research-dev/?utm_source=chatgpt.com), [elixirforum.com](https://elixirforum.com/t/jose-valim-elixir-is-officially-a-gradually-typed-language/60850?utm_source=chatgpt.com))
* **** remains valuable for legacy codebases or libraries that must interoperate with Erlang, but you can disable it in green‑field projects if the compiler’s gradual typing warnings meet your needs. ([elixirmerge.com](https://elixirmerge.com/p/understanding-elixirs-gradual-typing?utm_source=chatgpt.com))
* Re‑evaluate once typed‑struct syntax and wider pattern coverage land (see *What’s New in Elixir Types* – ElixirConf EU 2024). ([elixirconf.eu](https://www.elixirconf.eu/talks/whats-new-in-elixir-types/?utm_source=chatgpt.com))

---

## 8. Concurrency & OTP

* Model long‑running, stateful processes with **GenServer** or **GenStateMachine**.
* Always pair processes with the right **Supervisor** strategy (`one_for_one` by default).
* Link processes for fail‑fast semantics; rely on supervision trees for recovery.
* Avoid global process registration unless necessary; prefer per‑process naming via `Registry`.
* **Prefer plain modules over processes** – Don’t spin up a `GenServer` just to read configuration or perform stateless transformations. Extra processes add latency and contention without benefits.

---

## 9. Logging & Error Handling

* Raise exceptions only for *unexpected* conditions; return tagged tuples (`{:error, reason}`) for recoverable errors.
* **Avoid dynamic atom creation** – Never call `String.to_atom/1` on user or external input; use `String.to_existing_atom/1` or keep strings. Dynamic atoms are not garbage‑collected and can crash the VM.
* **Use tagged tuples, not exceptions, for normal control flow** – Reserve `raise/1` (or `throw/1`) for truly exceptional, unrecoverable situations.
* Use `Logger` at appropriate levels: `debug` for noisy dev details, `info` for startup/shutdown, `warn` for recoverable issues, `error` for crashes.
* Add structured metadata (`Logger.metadata/1`) for actionable logs (e.g., `:request_id`).

---

## 10. Configuration & Environment Management

* Prefer **compile‑time** config (`config/*.exs`) for dependency wiring and module injection.
* Use **runtime** config (`config/runtime.exs`) for secrets and environment‑specific settings (e.g., DB URLs).
* Validate required env vars on boot to fail fast.

---

## 11. Performance & Optimization

1. **Benchmark before optimizing** – use `Benchee` and `:timer.tc/1` for microbenchmarks.
2. Choose appropriate data structures (e.g., `MapSet` for membership checks).
3. Avoid deep recursion on large lists; prefer tail‑recursive functions or `Enum.reduce/3`.
4. Keep ETS tables isolated to specific modules; wrap access in functions.

---

## 12. Tooling & CI Recommendations

| Tool | Purpose |
|------|---------|
| `mix format` | Auto code formatting |
| **Credo** | Static analysis & code smells |
| **ExCoveralls** | Test coverage reporting |
| **Benchee** | Benchmarking |

Automate with GitHub Actions: run formatter check, Credo, , tests, and docs generation on every PR.

---

## 13. Release & Deployment

* Build releases using `mix release`; commit `rel/overlays` for custom runtime configs.
* Use `runtime.exs` to read environment variables at boot.
* Tag Docker images with `git sha` + semantic version.

---

## 14. Security

* Sanitize external input; rely on pattern matching & validation.
* Keep Elixir/Erlang versions up‑to‑date (security patches).
* Run `mix hex.audit` in CI to catch vulnerable transitive deps (if added).

---

## 15. How to Contribute

1. Open a GitHub issue describing the change.
2. Submit a PR with updated guidelines & rationale.
3. Ensure CI passes and relevant examples or references are updated.

---

## 16. References & Further Reading

* Elixir School – OTP Guides
* Official Elixir Library Guidelines
* Credo README (Code Smells)
* AppSignal Blog – Advanced 
* Thinking Elixir Course – Pattern Matching
* Blog posts on configuration and logging best practices
