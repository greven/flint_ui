defmodule FlintUI.FieldTest do
  # The configured translator lives in the application environment, so this
  # module must not run alongside the async component tests that render fields.
  use ExUnit.Case, async: false

  alias FlintUI.Field

  def translate_tuple({message, _opts}), do: "translated " <> message

  def translate_with_args({message, opts}, prefix), do: prefix <> message <> inspect(opts)

  setup do
    previous = Application.get_env(:flint_ui, :translate_error)

    on_exit(fn ->
      if previous do
        Application.put_env(:flint_ui, :translate_error, previous)
      else
        Application.delete_env(:flint_ui, :translate_error)
      end
    end)

    :ok
  end

  test "passes binary messages through unchanged" do
    assert Field.translate_errors(["is invalid", "is taken"]) == ["is invalid", "is taken"]
  end

  test "interpolates raw error tuples by default" do
    assert Field.translate_errors([{"should be at most %{count} characters", [count: 5]}]) == [
             "should be at most 5 characters"
           ]
  end

  test "uses a configured module and function" do
    Application.put_env(:flint_ui, :translate_error, {__MODULE__, :translate_tuple, []})

    assert Field.translate_errors([{"raw", []}]) == ["translated raw"]
  end

  test "supports a configured module with extra arguments" do
    Application.put_env(:flint_ui, :translate_error, {__MODULE__, :translate_with_args, ["> "]})

    assert Field.translate_errors([{"raw", [count: 2]}]) == ["> raw[count: 2]"]
  end

  test "supports a configured function" do
    Application.put_env(:flint_ui, :translate_error, fn {message, _opts} -> "fn " <> message end)

    assert Field.translate_errors([{"raw", []}]) == ["fn raw"]
  end

  test "stringifies non-binary, non-tuple errors" do
    assert Field.translate_errors([:invalid]) == ["invalid"]
  end

  test "returns an empty list for a non-list" do
    assert Field.translate_errors(nil) == []
  end
end
