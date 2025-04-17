#!/usr/bin/env elixir

# Install dependencies
Mix.install([{:req, "~> 0.4"}])

# scripts/validate_urls.exs

defmodule ValidateUrls do
  @moduledoc """
  Validates URLs found in Markdown links within `llms.txt` files under specific headings using the Req library.
  """

  @resource_headings_regex ~r/^##\s+(Resources|Documentation)/
  @markdown_link_regex ~r/\[.*?\]\((.*?)\)/

  # Entry point
  def main(args) do
    target_dir = List.first(args) || "."
    IO.puts("🔍 Searching for llms.txt files in #{Path.expand(target_dir)}...")

    # Find files, extract URLs, and validate concurrently
    invalid_urls =
      find_llms_files(target_dir)
      |> Task.async_stream(&process_file/1,
        ordered: false,
        max_concurrency: System.schedulers_online() * 2
      )
      # Flatten results, ignore errors during processing
      |> Stream.flat_map(fn
        {:ok, results} -> results
        # Ignore {:error, reason} from process_file if any step fails catastrophically
        _ -> []
      end)
      # Keep only errors from URL validation
      |> Enum.filter(&match?({:error, _, _, _}, &1))

    # Report results
    report_results(invalid_urls)
  end

  # Recursively find llms.txt files
  defp find_llms_files(dir) do
    dir
    |> Path.expand()
    |> File.ls!()
    |> Enum.flat_map(fn entry ->
      full_path = Path.join(dir, entry)

      cond do
        String.ends_with?(entry, "llms.txt") && File.regular?(full_path) ->
          [full_path]

        File.dir?(full_path) ->
          # Recurse into directories
          find_llms_files(full_path)

        true ->
          []
      end
    end)
  end

  # Process a single llms.txt file
  defp process_file(file_path) do
    IO.puts("📄 Processing #{file_path}...")
    content = File.read!(file_path)
    urls = extract_urls_from_content(content)

    # Validate URLs for this file concurrently
    results =
      urls
      # Limit concurrency per file
      |> Task.async_stream(&validate_url(&1, file_path), ordered: false, max_concurrency: 5)
      |> Enum.map(fn
        {:ok, result} -> result
        # Catch exits from the Task
        {:exit, reason} -> {:error, "Task Exit", inspect(reason), file_path}
      end)

    results
  end

  # Extract URLs under specific headings
  defp extract_urls_from_content(content) do
    lines = String.split(content, "\n")

    Enum.reduce(lines, {[], false}, fn line, {acc, current_in_section} ->
      cond do
        Regex.match?(@resource_headings_regex, line) ->
          # Entering a relevant section
          extract_links_from_line(line, acc, true)

        String.starts_with?(line, "## ") ->
          # Entering another section, stop collecting
          extract_links_from_line(line, acc, false)

        current_in_section ->
          # Inside a relevant section
          extract_links_from_line(line, acc, true)

        true ->
          # Outside relevant sections
          {acc, false}
      end
    end)
    # We only need the accumulator part from the reduce state
    |> elem(0)
    # Avoid checking the same URL multiple times per file
    |> Enum.uniq()
  end

  # Helper to extract links from a line and update state
  defp extract_links_from_line(line, acc, current_in_section) do
    new_urls =
      if current_in_section do
        Regex.scan(@markdown_link_regex, line, capture: :all_but_first)
        # [[url1], [url2]] -> [url1, url2]
        |> List.flatten()
      else
        []
      end

    # Return updated accumulator and state
    {acc ++ new_urls, current_in_section}
  end

  # Validate a single URL using Req
  defp validate_url(url, file_path) do
    # Basic check for common non-HTTP URLs or placeholders
    if String.starts_with?(url, ["http://", "https://"]) do
      IO.puts("    🔗 Checking #{url}...")
      # Try HEAD request first
      case Req.request(method: :head, url: url, receive_timeout: 15_000, retry: false) do
        {:ok, %Req.Response{status: status_code}} ->
          handle_status_code(status_code, url, file_path)

        # Handle HEAD errors (including timeout)
        {:error, head_reason} ->
          # Check if it was specifically a timeout at runtime
          if is_struct(head_reason) and head_reason.__struct__ == Req.TimeoutError do
            # If HEAD times out, try GET
            IO.puts("    ⚠️ HEAD timed out for #{url}, trying GET...")

            case Req.request(method: :get, url: url, receive_timeout: 15_000, retry: false) do
              {:ok, %Req.Response{status: status_code}} ->
                handle_status_code(status_code, url, file_path)

              # Handle GET errors
              {:error, get_reason} ->
                {:error, url, format_req_error_reason(get_reason), file_path}
            end
          else
            # Handle other HEAD errors (DNS, connection refused, SSL errors etc.)
            {:error, url, format_req_error_reason(head_reason), file_path}
          end
      end
    else
      IO.puts("    ⚠️ Skipping non-HTTP URL: #{url}")
      # Mark as skipped, not an error
      {:skipped, url, "Non-HTTP(S) URL", file_path}
    end
  end

  # Check status code validity (remains the same)
  defp handle_status_code(status_code, url, file_path)
       when status_code >= 200 and status_code < 400 do
    IO.puts("    ✅ #{status_code} OK: #{url}")
    {:ok, url, status_code, file_path}
  end

  defp handle_status_code(status_code, url, file_path) do
    IO.puts("    ❌ #{status_code} Error: #{url}")
    {:error, url, "Status #{status_code}", file_path}
  end

  # Format Req error reasons for better readability
  defp format_req_error_reason(reason) do
    case reason do
      %{__struct__: struct_name}
      when struct_name in [
             Req.TimeoutError,
             Req.ConnectionError,
             Req.HTTPError,
             Req.DNSError,
             Req.SSLError,
             Req.TooManyRedirectsError,
             Req.RequestError
           ] ->
        case struct_name do
          Req.TimeoutError -> "Request timed out"
          Req.ConnectionError -> "Connection error: #{inspect(reason.reason)}"
          Req.HTTPError -> "HTTP error status: #{inspect(reason.response.status)}"
          Req.DNSError -> "DNS resolution error: #{inspect(reason.reason)}"
          Req.SSLError -> "SSL/TLS error: #{inspect(reason.reason)}"
          Req.TooManyRedirectsError -> "Too many redirects"
          Req.RequestError -> "Request setup error: #{inspect(reason.reason)}"
        end

      other ->
        "Unknown error: #{inspect(other)}"
    end
  end

  # Report the final results (remains the same)
  defp report_results([]) do
    IO.puts("\n🎉 All URLs validated successfully!")
  end

  defp report_results(invalid_urls) do
    count = Enum.count(invalid_urls)
    IO.puts("\n🚨 Found #{count} invalid URL(s):")

    Enum.each(invalid_urls, fn {:error, url, reason, file_path} ->
      IO.puts("  - File: #{file_path}")
      IO.puts("    URL: #{url}")
      IO.puts("    Reason: #{reason}\n")
    end)

    # Exit with non-zero status if errors found
    System.halt(1)
  end
end

# Run the main function
ValidateUrls.main(System.argv())
