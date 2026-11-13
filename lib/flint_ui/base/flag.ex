defmodule FlintUI.Base.Flag do
  @moduledoc """
  Renders a flag from a country or region code.

  The `code` is the flag's ISO 3166-1 alpha-2 code (or another code from the
  installed flag set), and `shape` selects the asset:

    * `regular` (the default) uses the 4:3 SVG.
    * `square` uses the 1:1 SVG.
    * `round` uses the 1:1 SVG and, in the styled wrapper, a full radius.

  The component builds the image URL from `code` and `shape`, so the code can be
  dynamic. Nothing needs to appear literally in source, which means the same
  call works with Tailwind and with plain CSS:

      <.flag code="pt" />
      <.flag code={@country_code} shape="round" label={@country_name} />

  `mix flint.icons flags --assets` copies the Flag Icons SVGs into
  `priv/static/images/flags` as `<code>.svg` and `<code>-square.svg`. That path
  is already served by the default Phoenix `Plug.Static` allowlist. The base URL
  is `/images/flags`; override it globally with

      config :flint_ui, flag_path: "/images/flags"

  or per instance with the `path` attribute. The styled wrapper owns the box,
  size scale, radius, overlay, border, and shadow; the copied SVG is used as the
  root's background image.

  The generated `flag-*` classes still exist for direct use when a set is
  installed with `--tailwind` or `--css`, but this component does not depend on
  them.

  ## Accessibility

  A flag is decorative by default and hidden from assistive technology. When it
  conveys meaning on its own, pass `label` to expose it as an image with an
  accessible name:

      <.flag code="pt" label="Portugal" />

  A flag is not a language. Use a text label for a language and only use a flag
  when it represents the country or region itself.

  ## Keyboard

  The flag is not interactive and adds no keyboard behavior.
  """

  use FlintUI.Component

  @shape_values ~w(regular square round)
  @code_format ~r/^[a-z0-9-]+$/
  @default_path "/images/flags"

  @impl true
  def meta do
    %Meta{
      name: :flag,
      type: :element,
      since: "0.1",
      status: :draft
    }
  end

  @impl true
  def parts_attrs do
    [
      root: [
        %Meta.PartAttr{
          name: "[data-element]",
          value: "flag",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
        },
        %Meta.PartAttr{
          name: "[data-name]",
          value: "flag-<code> or flag-<code>-square",
          description: "The resolved flag name."
        },
        %Meta.PartAttr{
          name: "[data-shape]",
          value: "regular",
          description: "The resolved flag shape."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(_assigns) do
    %{
      root: %{
        "data-element" => "flag",
        "data-part" => "root"
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :code, :string,
    required: true,
    doc:
      "The flag code, usually an ISO 3166-1 alpha-2 code such as `\"pt\"` or `\"us\"`. Applied case-insensitively."

  attr :shape, :string,
    values: @shape_values,
    default: "regular",
    doc:
      "The flag shape. `regular` is 4:3, `square` is 1:1, and `round` uses the square asset with a full radius."

  attr :path, :string,
    default: nil,
    doc:
      "The base URL for the copied flag SVGs. Defaults to the `:flint_ui, :flag_path` config, then `/flags`."

  attr :class, :any,
    default: nil,
    doc: "Additional classes for the flag root."

  attr :label, :string,
    default: nil,
    doc: "An accessible name. When set, the flag is exposed as a labeled image."

  attr :rest, :global, doc: "Additional HTML attributes."

  @impl true
  def render(assigns) do
    code = normalize_code(assigns.code)
    shape = normalize_shape(assigns.shape)
    {name, file} = flag_name_and_file(code, shape)
    style = flag_style(assigns, file)

    assigns =
      assigns
      |> assign(:rest, Map.delete(assigns.rest, :style))
      |> assign(:resolved_name, name)
      |> assign(:flag_style, style)
      |> assign(:shape, shape)

    ~H"""
    <span
      {@rest}
      class={@class}
      data-name={@resolved_name}
      data-shape={@shape}
      style={@flag_style}
      aria-hidden={is_nil(@label) && "true"}
      role={@label && "img"}
      aria-label={@label}
      {@flint_parts[:root]}
    />
    """
  end

  defp normalize_code(code) do
    code = code |> String.trim() |> String.downcase()

    if Regex.match?(@code_format, code) do
      code
    else
      raise ArgumentError, "invalid flag code: #{inspect(code)}"
    end
  end

  defp normalize_shape(shape) when shape in @shape_values, do: shape
  defp normalize_shape(_shape), do: "regular"

  defp flag_name_and_file(code, shape) do
    suffix = if shape in ["square", "round"], do: "-square", else: ""
    {"flag-#{code}#{suffix}", "#{code}#{suffix}.svg"}
  end

  defp flag_style(assigns, file) do
    base =
      assigns[:path] || Application.get_env(:flint_ui, :flag_path, @default_path) || @default_path

    url = "#{String.trim_trailing(base, "/")}/#{file}"
    user_style = assigns.rest[:style]
    user_style = if is_list(user_style), do: Enum.join(user_style, "; "), else: user_style

    [~s|background-image: url("#{url}")|, user_style]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("; ")
  end
end
