defmodule FlintUI do
  @moduledoc """
  TODO: !!!!!!!!!
  """

  defmacro __using__(_opts) do
    quote do
      import FlintUI.{
        Accordion,
        VisuallyHidden
      }
    end
  end
end
