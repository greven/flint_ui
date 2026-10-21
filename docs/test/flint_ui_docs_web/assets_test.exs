defmodule FlintUIDocsWeb.AssetsTest do
  use ExUnit.Case, async: false

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
end
