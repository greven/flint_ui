defmodule FlintUI.WrapperProbe do
  @moduledoc false
  use FlintUI.Component

  @impl true
  def meta do
    %FlintUI.Meta{name: :wrapper_probe, type: :misc, since: "0.1.0", status: :draft}
  end

  @impl true
  def build_attrs(assigns) do
    %{root: %{"data-count" => assigns.count}}
  end

  attr(:count, :integer, default: 0)
  attr(:label, :string, default: "")
  slot(:body)

  @impl true
  def render(assigns) do
    ~H"""
    <div {@flint_parts[:root]}>
      <span>{@label}</span>
      {render_slot(@body, @flint_parts[:root])}
    </div>
    """
  end
end

defmodule FlintUI.WrapperProbeTest.Wrapper do
  @moduledoc false
  use Phoenix.Component
  require FlintUI.API
  FlintUI.API.component(:wrapper_probe)
end

defmodule FlintUIApiTest do
  use ExUnit.Case, async: true

  defp render(changed) do
    FlintUI.WrapperProbeTest.Wrapper.wrapper_probe(%{
      count: 1,
      label: "hello",
      body: [%{__slot__: :body, inner_block: fn _changed, _arg -> "BODY" end}],
      __changed__: changed
    })
  end

  test "re-renders the part spread and slots when an input changed" do
    [_root, _label, slot] = render(%{count: true}).dynamic.(true)

    assert slot != nil
  end

  test "prunes the part spread and slots when no input changed" do
    [_root, _label, slot] = render(%{}).dynamic.(true)

    assert slot == nil
  end

  test "prunes unrelated dynamics when only another assign changed" do
    [_root, label, slot] = render(%{count: true}).dynamic.(true)

    assert slot != nil
    assert label == nil
  end

  test "recomputes non-slot dynamics when they did change" do
    [_root, label, _slot] = render(%{label: true}).dynamic.(true)

    assert label != nil
  end
end
