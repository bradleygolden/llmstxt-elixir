# AI Agent Contribution Guide for Elixir llms.txt

**Objective:** To maintain a high-quality, structured collection of `llms.txt` files providing context about Elixir for Large Language Models (LLMs).

**Core Principles:**
*   **Focus:** All content must be specific to the Elixir language, its core libraries, or widely used community libraries/frameworks.
*   **Accuracy:** Information must be factually correct and reflect current Elixir best practices.
*   **Conciseness:** Provide information clearly and succinctly. Use bullet points or short paragraphs.
*   **Structure:** Adhere strictly to the established directory structure.
*   **Specification Adherence:** All `llms.txt` files MUST strictly follow the structure and formatting rules defined in the official specification at https://llmstxt.org/.

**File Structure Overview:**
*   `/core`: Contains `llms.txt` files for fundamental Elixir language features, concepts, and standard library modules (e.g., `Enum`, `Map`, OTP concepts like `GenServer`).
    *   Each topic should reside in its own subdirectory (e.g., `/core/processes/`, `/core/data_structures/`).
    *   The main index for core topics is `/core/llms.txt`.
*   `/libs`: Contains `llms.txt` files for specific external libraries or frameworks (e.g., `Ecto`, `Phoenix`, `Absinthe`).
    *   Each library should reside in its own subdirectory (e.g., `/libs/ecto/`, `/libs/phoenix/`).
    *   The main index for libraries is `/libs/llms.txt`.
*   `/`: The root directory contains general project files like this guide and `README.md`. The root `llms.txt` may serve as a top-level index.

**Contribution Workflow:**

1.  **Identify Scope:** Determine if the contribution relates to a core Elixir concept or a specific library.
2.  **Locate/Create Directory:**
    *   **Core Concept:** Check if a relevant subdirectory exists under `/core`. If not, create a new, appropriately named subdirectory (e.g., `/core/new_concept/`).
    *   **Library:** Check if a relevant subdirectory exists under `/libs`. If not, create a new, appropriately named subdirectory (e.g., `/libs/new_library/`).
3.  **Create/Modify `llms.txt`:**
    *   Inside the target directory, create or modify the `llms.txt` file according to the `llmstxt.org` specification:
        *   Start with a clear `# H1 Title` for the topic.
        *   Add a concise `> Blockquote summary` providing essential context.
        *   **Add Inline Guidance (Before H2):** In the section *before* any `## H2` headings, add concise, high-value guidance using Markdown lists, bold text, and code blocks. Focus on:
            *   **Key Signatures/Callbacks:** Essential function/callback signatures with brief descriptions.
            *   **Idiomatic Patterns:** Short code snippets or descriptions of common usage patterns.
            *   **Common Pitfalls:** Brief mentions of frequent mistakes or anti-patterns.
            *   **Configuration Examples:** Minimal, relevant config snippets if applicable.
            *   **Important:** Do *not* use H2 or lower headings for this inline guidance section. Keep it focused and directly relevant to improving code generation.
        *   **Add Resources Section:** Create a `## Resources` section.
        *   **Research & Link:** Find relevant URLs (preferring official Hexdocs pages, then official guides) for the topic.
        *   **Format Links:** List these URLs under `## Resources` using the specified format: `* [Link Title](URL): Brief description`.
4.  **Update Index Files (Crucial):**
    *   If you added a new subdirectory under `/core`, add a reference or link to `/core/new_concept/llms.txt` within `/core/llms.txt`.
    *   If you added a new subdirectory under `/libs`, add a reference or link to `/libs/new_library/llms.txt` within `/libs/llms.txt`.
    *   Maintain the formatting and structure of the index files.

**Example `llms.txt` Content (Inline Guidance + Links):**

```
# Phoenix Routing

> Defines how incoming HTTP requests are matched to controller actions in Phoenix applications. Covers defining routes, using helpers, resources, and pipelines.

**Key Module:** `Phoenix.Router`

**Common Patterns:**
*   Use `resources "/users", UserController` for standard CRUD routes.
*   Group related routes under a `scope "/admin"` block.
*   Define pipelines in the `:browser` or `:api` scope to apply plugs.

**Common Pitfalls:**
*   Forgetting to import `Phoenix.Router.Helpers` in views/controllers for path helpers.
*   Creating overly complex, deeply nested scopes.

## Resources
*   [Phoenix.Router](https://hexdocs.pm/phoenix/Phoenix.Router.html): Official Hexdocs documentation for the main routing module.
*   [Phoenix Routing Guide](https://hexdocs.pm/phoenix/routing.html): Comprehensive guide covering all aspects of routing in Phoenix.
*   [Plug.Router](https://hexdocs.pm/plug/Plug.Router.html): Documentation for the underlying Plug router used by Phoenix.
```

**Final Check:** Ensure your changes adhere to the principles and structure outlined above before completing the contribution.