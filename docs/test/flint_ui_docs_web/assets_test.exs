defmodule FlintUIDocsWeb.AssetsTest do
  use ExUnit.Case, async: false

  @color_prefixes ~w(--text-color- --background-color- --border-color- --divide-color- --ring-color- --outline-color- --color-)

  test "asset_path appends a cache-busting version when enabled" do
    previous = Application.get_env(:flint_ui_docs, :asset_version)
    Application.put_env(:flint_ui_docs, :asset_version, true)

    on_exit(fn ->
      if is_nil(previous) do
        Application.delete_env(:flint_ui_docs, :asset_version)
      else
        Application.put_env(:flint_ui_docs, :asset_version, previous)
      end
    end)

    assert FlintUIDocsWeb.asset_path("/assets/css/app.css") =~
             ~r{^/assets/css/app\.css\?v=[0-9a-f]+$}
  end

  test "asset_path is unchanged when disabled" do
    previous = Application.get_env(:flint_ui_docs, :asset_version)
    Application.delete_env(:flint_ui_docs, :asset_version)

    on_exit(fn ->
      if previous do
        Application.put_env(:flint_ui_docs, :asset_version, previous)
      end
    end)

    assert FlintUIDocsWeb.asset_path("/assets/css/app.css") == "/assets/css/app.css"
  end

  test "the docs Tailwind bridge maps every FlintUI color token" do
    bridge = FlintUI.Generator.tailwind_bridge_source()
    app_css = File.read!(Path.expand("../../assets/css/app.css", __DIR__))

    for declaration <- color_declarations(bridge) do
      assert app_css =~ declaration,
             "expected docs/assets/css/app.css to map #{declaration}"
    end
  end

  # The docs shell keeps Tailwind's own palette shades and layout scale, so the
  # comparison covers the color mappings only. Palette shades would retint the
  # shell whenever the reader switches palettes.
  defp color_declarations(bridge) do
    bridge
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&String.ends_with?(&1, ";"))
    |> Enum.filter(&String.starts_with?(&1, @color_prefixes))
    |> Enum.reject(&Regex.match?(~r/^--color-[a-z]+-\d+: /, &1))
  end
end
