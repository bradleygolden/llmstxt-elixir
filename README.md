# Elixir llms.txt Repository

This repository contains `llms.txt` files focused on Elixir programming best practices, core concepts, and common libraries.

These files are designed to provide context and guidance to Large Language Models (LLMs) when working with Elixir codebases.

**Usage Recommendation:**

The index files (`llms.txt`, `core/llms.txt`, `libs/llms.txt`) contain direct raw GitHub URLs to the specific topic/library files.

These URLs can be utilized in several ways:
*   **Direct Fetching:** Use tools capable of fetching content from URLs, such as the [Fetch MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/fetch), to dynamically load the relevant `llms.txt` content into your LLM context based on the URLs found in the index files.
*   **Local Integration:** Use tools like [mcpdoc](https://github.com/langchain-ai/mcpdoc) to manage and integrate the repository's content locally within your LLM workflows.

## Structure

*   `/core`: Contains `llms.txt` files related to core Elixir language features and principles.
*   `/libs`: Contains `llms.txt` files specific to popular Elixir libraries and frameworks.