defmodule FlintUI.Styled.AvatarGroupTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    avatar = FlintUI.Generator.component_source(:avatar)

    wrapper =
      compile_wrapper!(
        :avatar_group,
        avatar <>
          "\n" <>
          ~S'''
          def defaults(assigns) do
            ~H"""
            <.avatar_group>
              <.avatar alt="Jane Doe" />
              <.avatar alt="John Smith" />
            </.avatar_group>
            """
          end

          def custom(assigns) do
            ~H"""
            <.avatar_group
              size={@size}
              overlap={@overlap}
              ring={@ring}
              label={@label}
              class={@class}
            >
              <.avatar alt="Jane Doe" />
            </.avatar_group>
            """
          end
          '''
      )

    %{wrapper: wrapper}
  end

  test "maps the default treatment onto the data hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :avatar_group)) == ["span"]
    assert attr(document, :avatar_group, "data-avatar_group") == [""]
    assert attr(document, :avatar_group, "data-size") == ["md"]
    assert attr(document, :avatar_group, "data-overlap") == ["md"]
    assert attr(document, :avatar_group, "data-ring") == []

    text =
      document
      |> LazyHTML.query(~s([data-element="avatar"] [data-part="fallback"]))
      |> LazyHTML.text()

    assert text =~ "JD"
    assert text =~ "JS"
  end

  test "maps size, overlap, ring, label, and class", %{wrapper: wrapper} do
    document =
      render(wrapper, :custom, %{
        size: "lg",
        overlap: "xl",
        ring: true,
        label: "Members",
        class: "extra"
      })

    assert attr(document, :avatar_group, "data-size") == ["lg"]
    assert attr(document, :avatar_group, "data-overlap") == ["xl"]
    assert attr(document, :avatar_group, "data-ring") == [""]
    assert attr(document, :avatar_group, "aria-label") == ["Members"]
    assert attr(document, :avatar_group, "role") == ["group"]
    assert attr(document, :avatar_group, "class") == ["extra"]
  end
end
