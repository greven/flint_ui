defmodule FlintUI.TestingContractTest do
  @moduledoc """
  Enforces the testing contract that a normal assertion cannot catch.

  The rules live in `AGENTS.md` and `docs/AGENTS.md`; this test fails when a
  test starts asserting raw markup, inline style order, or shared global state
  again.
  """

  use ExUnit.Case, async: true

  @component_tests Path.wildcard("test/{base,styled}/**/*_test.exs")
  @docs_live_tests Path.wildcard("docs/test/flint_ui_docs_web/live/**/*_test.exs")
  @self __ENV__.file

  test "component tests parse inline styles instead of asserting their text" do
    for path <- @component_tests, source = File.read!(path) do
      refute Regex.match?(~r/"style"\)\s*==\s*\[(?!\])/, source),
             """
             #{path} asserts an inline style string.

             Parse it with `FlintUI.TestDOM.style_vars/2` and assert the
             individual custom properties instead.
             """
    end
  end

  test "component tests do not read generated component CSS" do
    for path <- @component_tests, source = File.read!(path) do
      refute source =~ "File.read!(FlintUI.Generator.part_path",
             """
             #{path} reads a generated component stylesheet.

             Selector and token coverage belongs in `test/theme/contract_test.exs`
             and `test/theme/css_test.exs`.
             """
    end
  end

  test "component tests do not compare raw HTML fragments" do
    for path <- @component_tests, source = File.read!(path) do
      refute Regex.match?(~r/LazyHTML\.to_html\([^)]*\)\s*==\s*"</, source),
             """
             #{path} compares raw HTML.

             Query the semantic part and assert emptiness with
             `FlintUI.TestDOM.empty?/2`.
             """
    end
  end

  test "component tests do not assert raw markup substrings" do
    for path <- @component_tests, source = File.read!(path) do
      refute Regex.match?(~r/=~\s*~s?\(?["']</, source),
             """
             #{path} asserts a raw markup fragment.

             Query the semantic part and assert its tag, text, or attributes.
             """
    end
  end

  test "async tests do not mutate the application environment" do
    for path <- all_test_files(), source = File.read!(path), async_file?(source) do
      refute source =~ "Application.put_env",
             """
             #{path} is async but mutates the application environment.

             Move the test to an `async: false` module and restore the previous
             value in `on_exit/1`.
             """
    end
  end

  test "tests use ExUnit's tmp_dir instead of shared temporary paths" do
    for path <- all_test_files(), source = File.read!(path) do
      refute source =~ "System.tmp_dir!",
             """
             #{path} uses a shared temporary directory.

             Tag the test with `@tag :tmp_dir` and read the per-test `:tmp_dir`
             from the context instead.
             """
    end
  end

  test "docs live tests assert DOM and text, not raw HTML" do
    for path <- @docs_live_tests, source = File.read!(path) do
      refute Regex.match?(~r/=~\s*~s?\(?["']</, source),
             """
             #{path} asserts raw HTML.

             Query the element by ID or `data-*` hook and assert its text.
             """
    end
  end

  defp all_test_files do
    Enum.reject(Path.wildcard("test/**/*_test.exs"), &(Path.expand(&1) == @self))
  end

  defp async_file?(source) do
    Regex.match?(~r/use (?:ExUnit\.Case|FlintUI\.StyledCase), async: true/, source)
  end
end
