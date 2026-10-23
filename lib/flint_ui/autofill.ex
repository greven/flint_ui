defmodule FlintUI.Autofill do
  @moduledoc """
  Opt-out attributes for browser and password-manager autofill.

  Password managers draw their fill icon from their own heuristics, and the
  standard `autocomplete="off"` is not enough for most of them. Use
  `ignore_attributes/0` on fields where autofill makes no sense, such as
  preview controls, API keys, or search boxes:

      <input type="text" {FlintUI.Autofill.ignore_attributes()} />

  Keeper opts out with a class instead of a `data-*` attribute, so merge
  `ignore_class/0` into the element's class list:

      <input type="text" class={["field", FlintUI.Autofill.ignore_class()]} ... />

  A few managers, and the browser's own autofill, may still show their icon;
  there is no cross-vendor standard for opting out.
  """

  @ignore_attributes %{
    autocomplete: "off",
    "data-1p-ignore": true,
    "data-op-ignore": true,
    "data-lpignore": "true",
    "data-bwignore": "true",
    "data-protonpass-ignore": "true",
    "data-form-type": "other"
  }

  @ignore_class "keeper-ignore"

  @doc """
  Returns the attributes that ask password managers to ignore a field.

  Spread them onto the input:

      <input type="text" {FlintUI.Autofill.ignore_attributes()} />
  """
  @spec ignore_attributes() :: map()
  def ignore_attributes, do: @ignore_attributes

  @doc """
  Returns the class that asks Keeper to ignore a field.
  """
  @spec ignore_class() :: String.t()
  def ignore_class, do: @ignore_class
end
