defmodule FlintUI.Base.Avatar do
  @moduledoc """
  Shows a person or entity as an image, falling back to initials, fixed text,
  or custom content.

  ## Examples

      <.avatar src={@user.avatar_url} alt={@user.name} />

      <.avatar alt="Jane Doe" />

      <.avatar alt="Jane Doe" text="JD" />

      <.avatar alt="3 more members" text="+3" />

      <.avatar src={@user.avatar_url} alt="" />

  The image is rendered when `src` is set. If the URL is missing or the image
  fails to load, the fallback is shown instead. While a set image loads, the
  fallback stays behind it, so initials, text, or a custom fallback act as the
  placeholder until the image paints over them. With no `src`, the fallback is
  server-rendered; a failed URL needs the bundled `flint.js`, which watches the
  image and reveals the fallback on error. Without the bundle, the browser's
  broken-image UI remains.

  Pass `alt` to render initials: the first grapheme of the first and last
  whitespace-separated parts. Pass `text` to replace the initials with fixed
  content, such as `+3` for an overflow avatar. The styled wrapper draws a
  generic user icon when neither `alt` nor `text` is available. Pass a
  `:fallback` slot to replace all of them with your own content.

  `class` applies to the avatar root. `rest` applies to the `<img>`, so any
  image attribute such as `loading`, `decoding`, `fetchpriority`, `srcset`, or
  `sizes` is supported. Image attributes have no target when `src` is not set.

  ## Accessibility

  The image gets `alt`; pass `alt=""` for a decorative avatar. `alt` is also the
  avatar's accessible name: it labels the fallback and is its title. When `alt`
  is omitted, `text` labels the fallback instead. While an image loads, its
  fallback is a visual placeholder and stays out of the accessibility tree; the
  image's `alt` is the accessible name. If the image fails, the fallback is
  revealed to assistive technology when it has a label. The fallback label is
  also its title, and the fallback is exposed as an image only when that label
  is present. Initials alone are not a useful accessible name, so give the
  avatar an `alt` label when it conveys identity.

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
    [
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
          description: "The image alternative text from `alt`."
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
          value: ~s("initials" | "text" | "slot" | "none"),
          description: "What the fallback is rendering."
        },
        %Meta.PartAttr{
          name: "title",
          value: "string",
          description: "The `alt` text, or the `text` when alt is not set."
        },
        %Meta.PartAttr{
          name: "role",
          value: ~s("img"),
          description: "Present when the fallback has an accessible label."
        },
        %Meta.PartAttr{
          name: "aria-label",
          value: "string",
          description: "The accessible label, taken from `alt` or `text`."
        },
        %Meta.PartAttr{
          name: "hidden",
          value: "boolean",
          description: "Set by the bundled script once the image loads, hiding the placeholder."
        }
      ]
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "loading",
        description: "The image is loading.",
        selector: ~s([data-element="avatar"][data-status="loading"])
      },
      %Meta.State{
        name: "loaded",
        description: "The image has loaded.",
        selector: ~s([data-element="avatar"][data-status="loaded"])
      },
      %Meta.State{
        name: "error",
        description: "The image failed to load.",
        selector: ~s([data-element="avatar"][data-status="error"])
      },
      %Meta.State{
        name: "fallback",
        description: "The fallback is rendered because no image source was provided.",
        selector: ~s([data-element="avatar"][data-status="fallback"])
      }
    ]
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
      "The image alternative text and the avatar's accessible name. Initials are derived from it. Pass `\"\"` for a decorative avatar."

  attr :text, :string,
    default: nil,
    doc:
      "Fallback text shown instead of initials, such as `\"+3\"` for an overflow avatar. Labels the fallback when `alt` is not set."

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
      "Custom fallback content. Takes precedence over `text` and initials. The styled wrapper supplies a user icon when both `alt` and `text` are blank."

  @impl true
  def render(assigns) do
    label = fallback_label(assigns)
    initials = initials(assigns.alt)
    text = fallback_text(assigns)

    assigns =
      assigns
      |> assign(:initials, initials)
      |> assign(:fallback_text, text)
      |> assign(:fallback_label, label)
      |> assign(:fallback_kind, fallback_kind(assigns, initials, text))

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
        {render_slot(@fallback) || @fallback_text || @initials}
      </span>
      <img
        :if={image?(@src)}
        {@flint_parts[:image]}
        src={@src}
        alt={@alt || ""}
        {@rest}
      />
    </span>
    """
  end

  defp image?(src), do: src not in [nil, ""]

  defp fallback_label(assigns) do
    case assigns.alt do
      nil -> fallback_text(assigns)
      "" -> nil
      alt -> alt
    end
  end

  defp fallback_text(%{text: text}) when is_binary(text) do
    if String.trim(text) == "", do: nil, else: text
  end

  defp fallback_text(_assigns), do: nil

  defp fallback_kind(assigns, initials, text) do
    cond do
      Map.get(assigns, :fallback, []) != [] -> "slot"
      not is_nil(text) -> "text"
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
