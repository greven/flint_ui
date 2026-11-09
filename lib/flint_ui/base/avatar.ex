defmodule FlintUI.Base.Avatar do
  @moduledoc """
  Shows a person or entity as an image, falling back to initials or custom
  content.

  ## Examples

      <.avatar src={@user.avatar_url} name={@user.name} />

      <.avatar name="Jane Doe" />

      <.avatar src={@user.avatar_url} alt="" />

  The image is rendered when `src` is set. If the URL is missing or the image
  fails to load, the fallback is shown instead. While a set image loads, the
  fallback stays behind it, so initials or a custom fallback act as the
  placeholder until the image paints over them. With no `src`, the fallback is
  server-rendered; a failed URL needs the bundled `flint.js`, which watches the
  image and reveals the fallback on error. Without the bundle, the browser's
  broken-image UI remains.

  Pass `name` to render initials: the first grapheme of the first and last
  whitespace-separated parts. The styled wrapper draws a generic user icon when
  no name is available. Pass a `:fallback` slot to replace both with your own
  content.

  `class` applies to the avatar root. `rest` applies to the `<img>`, so any
  image attribute such as `loading`, `decoding`, `fetchpriority`, `srcset`, or
  `sizes` is supported. Image attributes have no target when `src` is not set.

  ## Accessibility

  The image gets `alt`, which defaults to `name`; pass `alt=""` for a decorative
  avatar. While an image loads, its fallback is a visual placeholder and stays
  out of the accessibility tree; the image's `alt` is the accessible name. If
  the image fails, the fallback is revealed to assistive technology when it has
  a label. The fallback uses the same text as its accessible label and title, and
  is exposed as an image only when that label is present. Initials alone are
  not a useful accessible name, so give the avatar a name or an alt label when
  it conveys identity.

  ## Keyboard

  The avatar is not interactive and adds no keyboard behavior.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :avatar,
      type: :element,
      since: "0.1",
      status: :draft
    }
  end

  @impl true
  def parts_attrs do
    %{
      root: [
        %Meta.PartAttr{
          name: "[data-element]",
          value: "avatar",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
        },
        %Meta.PartAttr{
          name: "[data-status]",
          value: ~s("loading" | "loaded" | "error" | "fallback"),
          description:
            "The image state. `fallback` is server-rendered when `src` is absent; the bundled script updates the others."
        }
      ],
      image: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "image",
          description: "Identifies the image element."
        },
        %Meta.PartAttr{
          name: "src",
          value: "string",
          description: "The image URL."
        },
        %Meta.PartAttr{
          name: "alt",
          value: "string",
          description: "The image alternative text, defaulting to `name`."
        }
      ],
      fallback: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "fallback",
          description: "Identifies the fallback element."
        },
        %Meta.PartAttr{
          name: "[data-fallback]",
          value: ~s("initials" | "slot" | "none"),
          description: "What the fallback is rendering."
        },
        %Meta.PartAttr{
          name: "title",
          value: "string",
          description: "The alt text, or the name when alt is not set."
        },
        %Meta.PartAttr{
          name: "role",
          value: ~s("img"),
          description: "Present when the fallback has an accessible label."
        },
        %Meta.PartAttr{
          name: "aria-label",
          value: "string",
          description: "The accessible label, taken from alt or name."
        },
        %Meta.PartAttr{
          name: "hidden",
          value: "boolean",
          description: "Set by the bundled script once the image loads, hiding the placeholder."
        }
      ]
    }
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "avatar",
        "data-part" => "root",
        "data-status" => if(image?(assigns.src), do: "loading", else: "fallback")
      },
      image: %{"data-part" => "image"},
      fallback: %{"data-part" => "fallback"}
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :src, :string,
    default: nil,
    doc: "The image URL. When it is missing or fails to load, the fallback is shown."

  attr :alt, :string,
    default: nil,
    doc:
      "The image alternative text. Defaults to `name`; pass `\"\"` for a decorative avatar. Also used as the fallback title."

  attr :name, :string,
    default: nil,
    doc:
      "The name used to render initials and, in the styled wrapper, to derive a color when `color=\"initials\"`."

  attr :class, :any,
    default: nil,
    doc: "Additional classes for the avatar root. `rest` applies to the image instead."

  attr :root_attrs, :map, default: %{}, doc: false

  attr :root_style, :string, default: nil, doc: false

  attr :rest, :global,
    include: ~w(loading decoding fetchpriority crossorigin referrerpolicy sizes srcset usemap
         ismap width height),
    doc:
      "Additional HTML attributes, forwarded to the image. Image attributes have no target when `src` is not set."

  slot :fallback,
    doc:
      "Custom fallback content. Takes precedence over initials. The styled wrapper supplies a user icon when `name` is blank."

  @impl true
  def render(assigns) do
    label = fallback_label(assigns)
    initials = initials(assigns.name)

    assigns =
      assigns
      |> assign(:initials, initials)
      |> assign(:fallback_label, label)
      |> assign(:fallback_kind, fallback_kind(assigns, initials))

    ~H"""
    <span {@flint_parts[:root]} {@root_attrs} class={@class} style={@root_style}>
      <span
        {@flint_parts[:fallback]}
        data-fallback={@fallback_kind}
        title={@fallback_label}
        role={@fallback_label && "img"}
        aria-label={@fallback_label}
        aria-hidden={fallback_aria_hidden(@src, @fallback_label)}
      >
        {render_slot(@fallback) || @initials}
      </span>
      <img
        :if={image?(@src)}
        {@flint_parts[:image]}
        src={@src}
        alt={@fallback_label || ""}
        {@rest}
      />
    </span>
    """
  end

  defp image?(src), do: src not in [nil, ""]

  defp fallback_label(assigns) do
    value = if is_nil(assigns.alt), do: assigns.name, else: assigns.alt

    case value do
      nil -> nil
      "" -> nil
      value -> value
    end
  end

  defp fallback_kind(assigns, initials) do
    cond do
      Map.get(assigns, :fallback, []) != [] -> "slot"
      not is_nil(initials) -> "initials"
      true -> "none"
    end
  end

  defp fallback_aria_hidden(_src, nil), do: "true"

  defp fallback_aria_hidden(src, _label), do: image?(src) && "true"

  @doc false
  def initials(nil), do: nil

  def initials(name) when is_binary(name) do
    words = name |> String.trim() |> String.split(~r/\s+/u, trim: true)

    case words do
      [] ->
        nil

      [single] ->
        single |> first_grapheme() |> String.upcase()

      [first | rest] ->
        (first_grapheme(first) <> first_grapheme(List.last(rest))) |> String.upcase()
    end
  end

  def initials(_name), do: nil

  defp first_grapheme(word) do
    case String.graphemes(word) do
      [] -> ""
      [grapheme | _rest] -> grapheme
    end
  end
end
