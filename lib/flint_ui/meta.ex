defmodule FlintUI.Meta do
  @moduledoc """
  FlintUI component metadata.
  """

  defmodule Event do
    @moduledoc """
    FlintUI component event metadata.
    """

    @type source :: :client | :server

    @type t :: %__MODULE__{
            name: String.t(),
            source: source(),
            required: boolean(),
            doc: String.t()
          }

    @enforce_keys [:name, :source, :doc]
    defstruct [:name, :source, :doc, required: false]
  end

  defmodule PartAttr do
    @moduledoc """
    Describes a single HTML/data attribute that is applied to a component part's
    root element via `build_attrs/1` or managed by the component's JavaScript hook.
    """

    @type t :: %__MODULE__{
            name: String.t(),
            value: String.t() | nil,
            description: String.t() | nil
          }

    @enforce_keys [:name]
    defstruct [:name, :value, :description]
  end

  defmodule CSSVar do
    @moduledoc """
    Describes a CSS custom property emitted by a component, typically set by the
    component's JavaScript hook for use in animations or layout calculations.
    """

    @type t :: %__MODULE__{name: String.t(), description: String.t() | nil}

    @enforce_keys [:name]
    defstruct [:name, :description]
  end

  # Meta

  @type type :: :data | :overlay | :input | :button | :feedback | :misc

  @type t :: %__MODULE__{
          name: String.t(),
          type: type(),
          since: String.t(),
          status: :stable | :draft | :deprecated
        }

  @enforce_keys [:name, :type, :since, :status]
  defstruct [:name, :type, :since, :status]
end
