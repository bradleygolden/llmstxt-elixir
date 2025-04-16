# AI Agent Contribution Guide for Elixir llms.txt

**Objective:** To maintain a high-quality, structured collection of `llms.txt` files providing context about Elixir for Large Language Models (LLMs).

**Core Principles:**
*   **Focus:** All content must be specific to the Elixir language, its core libraries, or widely used community libraries/frameworks.
*   **Accuracy:** Information must be factually correct and reflect current Elixir best practices.
*   **Conciseness:** Provide information clearly and succinctly. Use bullet points or short paragraphs.
*   **Structure:** Adhere strictly to the established directory structure.

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
    *   Inside the target directory, create or modify the `llms.txt` file.
    *   Populate it with concise, accurate information, best practices, and potentially small, illustrative code snippets relevant to the topic/library. Focus on information useful for an LLM to understand context or generate better Elixir code.
4.  **Update Index Files (Crucial):**
    *   If you added a new subdirectory under `/core`, add a reference or link to `/core/new_concept/llms.txt` within `/core/llms.txt`.
    *   If you added a new subdirectory under `/libs`, add a reference or link to `/libs/new_library/llms.txt` within `/libs/llms.txt`.
    *   Maintain the formatting and structure of the index files.

**Example `llms.txt` Content (Conceptual):**

```
# /core/pattern_matching/llms.txt

## Elixir Pattern Matching

- Fundamental feature in Elixir used for destructuring data types.
- Used in function heads, `case`, `cond`, `with`, and variable assignment.
- The `=` operator is the match operator, not assignment in the traditional sense.
- `_` ignores a value during matching.
- Pin operator `^` allows matching against an existing variable's value rather than rebinding.

# Example: Function Heads
def handle_reply({:ok, data}), do: {:ok, process(data)}
def handle_reply({:error, reason}), do: {:error, log(reason)}

# Example: Case Statement
case user do
  %{name: name, age: age} when age > 18 -> IO.puts "#{name} is an adult."
  %{name: name} -> IO.puts "#{name} is a minor or age unknown."
  _ -> IO.puts "Unknown user structure."
end
```

**Final Check:** Ensure your changes adhere to the principles and structure outlined above before completing the contribution.