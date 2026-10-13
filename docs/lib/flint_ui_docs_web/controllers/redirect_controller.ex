defmodule FlintUIDocsWeb.RedirectController do
  @moduledoc """
  Redirects a section root to its first page.
  """
  use FlintUIDocsWeb, :controller

  def getting_started(conn, _params) do
    redirect(conn, to: "/getting-started/introduction")
  end

  def guides(conn, _params) do
    redirect(conn, to: "/guides/theming")
  end
end
