defmodule FlintUI.Field do
  @moduledoc false

  use Phoenix.Component

  # Shared plumbing for form fields: error translation, the ids that link a
  # hint or description and its errors, `aria-describedby` assembly, the
  # decorative error icon, and the small attribute helpers every field uses. The
  # component modules keep the markup and the field-specific state derivation.

  @doc """
  The decorative warning icon that precedes every field error.

  The icon is inline SVG, so field errors never depend on an icon set. The
  message text carries the error, so the icon is hidden from assistive
  technology. Pass the field's `error_icon` part attributes as `attrs`.
  """
  attr :attrs, :map, default: %{}

  def error_icon(assigns) do
    ~H"""
    <svg
      {@attrs}
      viewBox="0 0 24 24"
      width="16"
      height="16"
      fill="currentColor"
      focusable="false"
    >
      <path
        fill-rule="evenodd"
        d="M10.93 5.32Q12 3.4 13.07 5.32L20.33 18.28Q21.4 20.2 19.2 20.2H4.8Q2.6 20.2 3.67 18.28ZM11.1 8.4H12.9V14H11.1ZM12 15.7A1 1 0 1 0 12 17.7A1 1 0 1 0 12 15.7Z"
      />
    </svg>
    """
  end

  @doc """
  Translates a list of errors into strings.

  Binary messages pass through. Raw `{message, options}` tuples are handed to
  the configured translator, or interpolated with the same `%{key}` syntax as
  the `translate_error/1` that `phx.new` generates.
  """
  def translate_errors(errors) when is_list(errors), do: Enum.map(errors, &translate_error/1)
  def translate_errors(_errors), do: []

  defp translate_error(message) when is_binary(message), do: message

  defp translate_error({message, opts}) when is_binary(message) and is_list(opts) do
    case Application.get_env(:flint_ui, :translate_error) do
      {module, function} when is_atom(module) and is_atom(function) ->
        apply(module, function, [{message, opts}])

      {module, function, args} when is_atom(module) and is_atom(function) and is_list(args) ->
        apply(module, function, [{message, opts} | args])

      function when is_function(function, 1) ->
        function.({message, opts})

      _ ->
        interpolate(message, opts)
    end
  end

  defp translate_error(other), do: to_string(other)

  defp interpolate(message, opts) do
    Enum.reduce(opts, message, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  @doc """
  The stable id of an error message, or `nil` when the field has no id.
  """
  def error_id(id, index) when is_binary(id), do: "#{id}-error-#{index}"
  def error_id(_id, _index), do: nil

  @doc """
  The ids of every error message, in order.
  """
  def error_ids(id, errors) do
    if present?(id) do
      errors
      |> Enum.with_index(1)
      |> Enum.map(fn {_message, index} -> error_id(id, index) end)
    else
      []
    end
  end

  @doc """
  The id of a field's hint, or `nil` when there is nothing to link.
  """
  def hint_id(id, hint) do
    if present?(id) and present?(hint), do: "#{id}-hint"
  end

  @doc """
  The id of a field's description, or `nil` when there is nothing to link.
  """
  def description_id(id, description) do
    if present?(id) and present?(description), do: "#{id}-description"
  end

  @doc """
  Joins a caller-supplied `aria-describedby` with the generated ids.
  """
  def described_by(rest, ids) do
    [rest_attr(rest, :"aria-describedby"), ids]
    |> List.flatten()
    |> Enum.reject(&blank?/1)
    |> Enum.join(" ")
  end

  @doc """
  Reads an attribute from a `:global` attribute map, accepting atom or string
  keys.
  """
  def rest_attr(rest, key) when is_map(rest) do
    Map.get(rest, key) || Map.get(rest, Atom.to_string(key))
  end

  def rest_attr(_rest, _key), do: nil

  @doc """
  Puts a value into a map unless it is absent.
  """
  def put_present(map, _key, value) when value in [nil, false, ""], do: map
  def put_present(map, key, value), do: Map.put(map, key, value)

  @doc """
  Merges class values, dropping blanks. Returns `nil` when nothing is left.
  """
  def class_list(values) do
    case values |> Enum.flat_map(&List.wrap/1) |> Enum.reject(&blank?/1) do
      [] -> nil
      classes -> classes
    end
  end

  @doc """
  Whether a value is present: not `nil`, `false`, or an empty string.
  """
  def present?(value), do: value not in [nil, false, ""]

  @doc """
  Whether a value is absent: `nil`, `false`, or an empty string.
  """
  def blank?(value), do: value in [nil, false, ""]

  @doc """
  Compares a current value with the value a checkbox submits.

  A list matches when any member matches, so a checkbox can derive its checked
  state from a selected-values list.
  """
  def matches?(values, expected) when is_list(values) do
    Enum.any?(values, &matches?(&1, expected))
  end

  def matches?(value, expected), do: to_string(value) == to_string(expected)
end
