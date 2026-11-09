defmodule FlintUIDocsWeb.AvatarSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "avatar page renders the image, initials, and controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/avatar")

    assert has_element?(
             view,
             "#usage-avatar-basic [data-element='avatar'][data-size='md'][data-shape='circle']"
           )

    assert has_element?(view, "#usage-avatar-basic [data-part='fallback']", "CK")

    assert has_element?(
             view,
             "#usage-avatar-basic [data-part='fallback'] [data-element='icon'].lucide-user"
           )

    assert has_element?(
             view,
             "#usage-avatar-basic [data-element='avatar'][style*='--fl-avatar-color']"
           )

    view
    |> element("#usage-avatar-basic-controls")
    |> render_change(%{"size" => "lg", "shape" => "square", "radius" => "md"})

    assert has_element?(
             view,
             "#usage-avatar-basic [data-element='avatar'][data-size='lg'][data-shape='square'][data-radius='md']"
           )

    assert has_element?(view, "#api")
    assert has_element?(view, "#setup")
  end

  test "avatar group page renders overlapping avatars and controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/avatar_group")

    assert has_element?(
             view,
             "#usage-avatar-group-basic [data-element='avatar_group'][data-overlap='md'][aria-label='Project members']"
           )

    assert has_element?(
             view,
             "#usage-avatar-group-basic [data-element='avatar_group'] [data-part='fallback']",
             "CM"
           )

    view
    |> element("#usage-avatar-group-basic-controls")
    |> render_change(%{"overlap" => "xl", "ring" => "true", "size" => "lg"})

    assert has_element?(
             view,
             "#usage-avatar-group-basic [data-element='avatar_group'][data-overlap='xl'][data-ring][data-size='lg']"
           )
  end
end
