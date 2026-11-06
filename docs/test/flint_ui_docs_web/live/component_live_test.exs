defmodule FlintUIDocsWeb.ComponentLiveTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "components index renders a section per component type", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components")

    assert has_element?(view, "h1", "Components")

    for {type, components} <- FlintUI.Docs.grouped_components() do
      assert has_element?(view, "#components-#{type}", FlintUIDocsWeb.Nav.type_label(type))

      assert has_element?(
               view,
               "#components-#{type} h2 a[href='#components-#{type}']"
             )

      for name <- components do
        assert has_element?(view, "#components-#{type} a[href='/components/#{name}']")
      end
    end
  end

  test "the components section link points at the landing page", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#section-components[href='/components']")
  end

  test "the header badges carry status, type, and since icons", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(
             view,
             "header [data-element='badge'][data-color='info'] .lucide-badge-check"
           )

    assert has_element?(view, "header [data-element='badge'] .lucide-mouse-pointer-click")
    assert has_element?(view, "header [data-element='badge'] .lucide-calendar-days")

    {:ok, view, _html} = live(conn, ~p"/components/toggle")

    assert has_element?(
             view,
             "header [data-element='badge'][data-color='warning'] .lucide-pencil-ruler"
           )
  end

  test "component page defaults to the styled tab", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#component-sections-tab-styled[aria-selected='true']")
    assert has_element?(view, "#component-sections-tab-base[aria-selected='false']")
    assert has_element?(view, "#component-sections-panel-styled")
    assert has_element?(view, "#usage-button-basic")
    assert has_element?(view, "#usage-button-basic [data-element='button']")
    assert has_element?(view, "#api")
    assert has_element?(view, "#setup")
    assert has_element?(view, "#usage")
    assert has_element?(view, "#component-sections-panel-base[hidden]")
  end

  test "the component sections are a FlintUI tab list", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#component-sections[data-element='tabs'][data-part='root']")
    assert has_element?(view, "#component-sections[phx-hook='FlintUI.Tabs']")
    assert has_element?(view, "#component-sections [role='tablist']")

    assert has_element?(
             view,
             "#component-sections-tab-base[role='tab'][aria-selected='false'][aria-controls='component-sections-panel-base']"
           )

    assert has_element?(
             view,
             "#component-sections-tab-base[data-tabs-trigger][data-element='button'][data-part='tab'][data-phx-link='patch']"
           )

    assert has_element?(
             view,
             "#component-sections-panel-base[role='tabpanel'][aria-labelledby='component-sections-tab-base']"
           )
  end

  test "the base tab renders the selected moduledoc sections", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button?tab=base")

    assert has_element?(view, "#component-sections-tab-base[aria-selected='true']")
    assert has_element?(view, "#component-sections-panel-base")
    assert has_element?(view, "#overview h2[data-toc='section']", "Overview")
    assert has_element?(view, "#examples h2[data-toc='section']", "Examples")
    assert has_element?(view, "#accessibility h2[data-toc='section']", "Accessibility")
    assert has_element?(view, "#keyboard h2[data-toc='section']", "Keyboard")
    assert has_element?(view, "#api")
    assert has_element?(view, "#data-attributes")
    assert has_element?(view, "#css-variables")
    assert has_element?(view, "#component-sections-panel-styled[hidden]")
  end

  test "section headings link to their anchors", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#api h2 a[href='#api']", "API")
    assert has_element?(view, "#api #attributes h3 a[href='#attributes']", "Attributes")

    {:ok, base, _html} = live(conn, ~p"/components/button?tab=base")

    assert has_element?(base, "#accessibility h2 a[href='#accessibility']", "Accessibility")
    assert has_element?(base, "#keyboard h2 a[href='#keyboard']", "Keyboard")
  end

  test "the css tab holds the styled contract tables", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible?tab=css")

    assert has_element?(view, "#component-sections-tab-css[aria-selected='true']")
    assert has_element?(view, "#component-sections-panel-css")
    assert has_element?(view, "#css-variables")
    assert has_element?(view, "#selectors")
    assert has_element?(view, "#theme")
    assert has_element?(view, "#css-variables code", "--fl-collapsible-duration")
    refute has_element?(view, "#styling-contract")
    refute has_element?(view, "#setup")
  end

  test "the css tab lists the component's state hooks", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button?tab=css")

    assert has_element?(view, "#selectors code", ~s|[data-element="button"][data-disabled]|)
    assert has_element?(view, "#selectors code", ~s|[data-element="button"][data-loading]|)
    assert has_element?(view, "#selectors code", ~s|[data-element="button"][data-pending-submit]|)
  end

  test "legacy tabs land on the styled tab", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button?tab=styled")

    assert has_element?(view, "#component-sections-tab-styled[aria-selected='true']")
    assert has_element?(view, "#component-sections-panel-styled")

    {:ok, view, _html} = live(conn, ~p"/components/button?tab=api")

    assert has_element?(view, "#component-sections-tab-styled[aria-selected='true']")
    assert has_element?(view, "#component-sections-panel-styled")
  end

  test "the styled tab merges the generated component API", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#api #attributes")
    assert has_element?(view, "#api #slots")
    refute has_element?(view, "#api #events")
    assert has_element?(view, "#attributes code", "variant")
    assert has_element?(view, "#attributes code", "disabled")
    refute has_element?(view, "#api code", "data-variant")
    assert has_element?(view, "#api a[href='/components/button?tab=base#data-attributes']")
    refute has_element?(view, "#theme")
  end

  test "the styled API documents text and icon", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#attributes code", "text")
    assert has_element?(view, "#attributes code", "icon")
  end

  test "text and icon shortcuts render in the usage preview", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#icon [data-element='button'] .lucide-save")
    assert has_element?(view, "#icon [aria-label='More']")
    assert has_element?(view, "#icon", "Save")
  end

  test "the API table folds defaults into descriptions and tooltips values", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#attributes thead th", "Attr")
    assert has_element?(view, "#attributes thead th", "Type")
    assert has_element?(view, "#attributes thead th", "Description")
    refute has_element?(view, "#attributes thead th", "Layer")
    refute has_element?(view, "#attributes thead th", "Default")

    assert has_element?(view, "#attributes tbody tr", "Default:")
    assert has_element?(view, "#attributes tbody tr", "Values:")
    refute has_element?(view, "#attributes tbody tr", "true, false")
    refute has_element?(view, "#attributes tbody tr", "Data attribute:")
    assert has_element?(view, "#attributes tbody tr code", "variant")
    assert has_element?(view, "#attributes tbody tr", "subtle")
    assert has_element?(view, "#attributes tbody tr", "button")
    assert has_element?(view, "#attributes tbody tr", "submit")
    assert has_element?(view, "#attributes tbody tr", "reset")
    assert has_element?(view, "#attributes tbody tr code", "boolean")
    refute has_element?(view, "#attributes tbody tr code", "'true'")
    refute has_element?(view, "#attributes tbody tr code", "string —")
  end

  test "the base tab documents base-specific content", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button?tab=base")

    assert has_element?(view, "#examples")
    assert has_element?(view, "#accessibility")
    assert has_element?(view, "#keyboard")
    assert has_element?(view, "#data-attributes")
    assert has_element?(view, "#data-attributes code", "data-element")
    assert has_element?(view, "#data-attributes code", "data-part")
    refute has_element?(view, "#data-attributes code", "[data-element]")
    refute has_element?(view, "#data-attributes code", "[data-part]")
    assert has_element?(view, "#component-sections-panel-base #attributes code", "disabled")
    refute has_element?(view, "#component-sections-panel-base #attributes code", "variant")
  end

  test "base moduledoc examples render code", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button?tab=base")

    assert has_element?(view, "#examples pre.highlight")
    assert has_element?(view, "#keyboard code", "Enter")
    assert has_element?(view, "#keyboard code", "Space")
  end

  test "the keyboard section renders the metadata table without repeating the moduledoc list",
       %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button?tab=base")

    assert has_element?(view, "#keyboard table")
    assert has_element?(view, "#keyboard thead th", "Keys")
    assert has_element?(view, "#keyboard tbody tr", "Activates an action button or a link")
    refute has_element?(view, "#keyboard ul")
  end

  test "a component without keyboard metadata renders its moduledoc prose", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/group?tab=base")

    assert has_element?(view, "#keyboard p", "adds no keyboard interaction of its own")
    refute has_element?(view, "#keyboard table")
  end

  test "collapsible playground wires the hook and disables the trigger", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible")

    assert has_element?(view, "#main-collapsible [data-element='collapsible']")
    assert has_element?(view, "#main-collapsible .border-dashed")

    view
    |> element("#main-collapsible-controls")
    |> render_change(%{"disabled" => "true"})

    assert has_element?(view, "#main-collapsible [data-part='trigger'][disabled]")
  end

  test "card page renders the generated card", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/card")

    assert has_element?(
             view,
             "#main-card [data-element='card'][data-variant='solid'][data-body='seamless'][data-orientation='vertical'][data-spacing='md'][data-outline]"
           )

    assert has_element?(view, "#main-card [data-part='title']", "Starred repositories")
  end

  test "card body control changes the body treatment", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/card")

    assert has_element?(view, "#main-card [data-element='card'][data-body='seamless']")

    view
    |> element("#main-card-controls")
    |> render_change(%{"body" => "inset"})

    assert has_element?(view, "#main-card [data-element='card'][data-body='inset']")
  end

  test "boolean controls render as true/false selects", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/card")

    assert has_element?(
             view,
             "#main-card-controls select[name='outline'] option[value='true']"
           )

    assert has_element?(
             view,
             "#main-card-controls select[name='outline'] option[value='false']"
           )

    refute has_element?(view, "#main-card-controls button[phx-value-key]")
  end

  test "card shadow control toggles the default", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/card")

    assert has_element?(view, "#main-card [data-element='card'][data-shadow]")

    view
    |> element("#main-card-controls")
    |> render_change(%{"shadow" => "false"})

    assert has_element?(view, "#main-card [data-element='card']:not([data-shadow])")
  end

  test "icon page renders a FlintUI icon", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/icon")

    assert has_element?(view, "#main-icon [data-element='icon']")
  end

  test "loading page renders a FlintUI loading indicator", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/loading")

    assert has_element?(view, "#main-loading [data-element='loading']")
  end

  test "toggle page renders a FlintUI toggle", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/toggle")

    assert has_element?(view, "#main-toggle [data-element='toggle'][aria-pressed='false']")

    view
    |> element("#main-toggle-controls")
    |> render_change(%{"pressed" => "true"})

    assert has_element?(view, "#main-toggle [data-element='toggle'][aria-pressed='true']")
  end

  test "tabs playground can disable the whole list", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/tabs")

    assert has_element?(view, "#main-tabs [data-element='tabs']:not([data-disabled])")
    assert has_element?(view, "#main-tabs [role='tablist'] > [role='tab'][tabindex='0']")

    view
    |> element("#main-tabs-controls")
    |> render_change(%{"disabled" => "true"})

    assert has_element?(view, "#main-tabs [data-element='tabs'][data-disabled]")
    refute has_element?(view, "#main-tabs [role='tab']:not([aria-disabled='true'])")
    refute has_element?(view, "#main-tabs [role='tablist'] > [role='tab'][tabindex='0']")
    assert has_element?(view, "#main-tabs-code", "disabled")
  end

  test "collapsible page documents keyboard interactions on the base tab", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible?tab=base")

    assert has_element?(view, "#keyboard")
    assert has_element?(view, "#keyboard code", "Enter")
    assert has_element?(view, "#keyboard code", "Space")
  end

  test "the button page exposes its section controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#usage-button-variant-controls select[name='variant']")
    assert has_element?(view, "#usage-button-color-controls select[name='color']")
    assert has_element?(view, "#usage-button-radius-controls select[name='radius']")
    assert has_element?(view, "#disabled [data-element='button']")
    assert has_element?(view, "#disabled a[data-element='button'][aria-disabled='true']")
    assert has_element?(view, "#loading [data-element='button'][data-loading]")
  end

  test "preview controls opt out of password-manager autofill", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/icon")

    selector =
      "#main-icon-controls input[name='name']" <>
        "[autocomplete='off'][data-1p-ignore][data-form-type='other'][class*='keeper-ignore']"

    assert has_element?(view, selector)
  end

  test "the loading playground exposes its controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/loading")

    assert has_element?(view, "#main-loading-controls select[name='variant']")
    assert has_element?(view, "#main-loading-controls select[name='color']")
    assert has_element?(view, "#main-loading-controls select[name='size']")
    assert has_element?(view, "#main-loading-controls input[name='duration']")
    assert has_element?(view, "#main-loading-controls input[name='weight']")
  end

  test "the preview canvas is solid and glues its controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#usage-button-variant [data-preview-canvas].border-solid")
    refute has_element?(view, "#usage-button-variant [data-preview-canvas].border-dashed")
    assert has_element?(view, "#usage-button-variant [data-preview-canvas].rounded-t-lg")
    refute has_element?(view, "#usage-button-variant [data-preview-controls].rounded-b-lg")
    refute has_element?(view, "#usage-button-variant [data-preview-controls].mt-3")
    assert has_element?(view, "#usage-button-variant [data-preview-code].rounded-b-lg")
  end

  test "switching tabs resets the playground to its defaults", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    view
    |> element("#usage-button-variant-controls")
    |> render_change(%{"variant" => "solid"})

    assert has_element?(view, "#usage-button-variant [data-variant='solid']")

    view |> element("#component-sections-tab-base") |> render_click()

    assert has_element?(view, "#component-sections-panel-base")
    refute has_element?(view, "#usage-button-variant [data-variant='solid']")

    view |> element("#component-sections-tab-styled") |> render_click()

    assert has_element?(view, "#usage-button-variant [data-variant='outline']")
  end

  test "the playground code block reflects the current props", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#usage-button-variant-code", "<.button")

    view
    |> element("#usage-button-variant-controls")
    |> render_change(%{"variant" => "solid"})

    assert has_element?(view, "#usage-button-variant-code", ~s(variant="solid"))
  end

  test "the playground code block offers a copy button", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#usage-button-variant-copy[phx-hook]")
    assert has_element?(view, "#usage-button-variant-copy .lucide-copy")
    assert has_element?(view, "#usage-button-variant-copy .lucide-check")
  end

  test "select and number controls update the preview", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/loading")
    assert has_element?(view, "#main-loading [data-element='loading']")

    view
    |> element("#main-loading-controls")
    |> render_change(%{"variant" => "dots-fade"})

    assert has_element?(
             view,
             "#main-loading [data-element='loading'][data-variant='dots-fade']"
           )
  end

  test "code blocks are syntax highlighted", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/collapsible")

    assert has_element?(view, "#setup pre.highlight code span")
  end

  test "the code panel is a collapsible disclosure", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    # The interactions example starts collapsed to keep the page compact.
    assert has_element?(view, "#example-button-interactions-code-collapse[data-state='closed']")
    assert has_element?(view, "#example-button-interactions-code-header", "Expand Code")

    assert has_element?(
             view,
             "#example-button-interactions-code-collapse [data-part='trigger'][aria-expanded='false']"
           )

    assert has_element?(
             view,
             "#example-button-interactions-code-collapse [data-part='content'][hidden]"
           )

    # A default preview starts expanded.
    assert has_element?(view, "#usage-button-basic-code-collapse[data-state='open']")

    assert has_element?(
             view,
             "#usage-button-basic-code-collapse [data-part='trigger'][aria-expanded='true']"
           )

    refute has_element?(
             view,
             "#usage-button-basic-code-collapse [data-part='content'][hidden]"
           )

    assert has_element?(
             view,
             "#icon-code-close[data-code-close][phx-click]",
             "Close Code"
           )

    refute has_element?(view, "#usage-button-basic-code-close")
  end

  test "preview code flavors switch with accessible tabs", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#example-button-interactions-code-tabs[role='tablist']")

    assert has_element?(
             view,
             "#example-button-interactions-code-tab-0[role='tab'][aria-selected='true'][tabindex='0']"
           )

    assert has_element?(
             view,
             "#example-button-interactions-code-tab-1[role='tab'][aria-selected='false'][tabindex='-1']"
           )

    assert has_element?(
             view,
             "#example-button-interactions-code-tabpanel[role='tabpanel'][aria-labelledby='example-button-interactions-code-tab-0']"
           )

    view |> element("#example-button-interactions-code-tab-1") |> render_click()

    assert has_element?(view, "#example-button-interactions-code-tab-1[aria-selected='true']")

    assert has_element?(
             view,
             "#example-button-interactions-code-tabpanel[aria-labelledby='example-button-interactions-code-tab-1']"
           )

    assert has_element?(view, "#example-button-interactions-code", "def handle_event")
  end

  test "a CSS flavor renders as its own code tab", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#example-button-custom_color-code-tabs[role='tablist']")
    assert has_element?(view, "#example-button-custom_color-code-tab-1", "CSS")

    view |> element("#example-button-custom_color-code-tab-1") |> render_click()

    assert has_element?(
             view,
             "#example-button-custom_color-code",
             ~s([data-element="button"][data-variant="subtle"])
           )
  end

  test "the component page shows a section and type breadcrumb", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    breadcrumb = "nav[aria-label='Breadcrumb']"
    assert has_element?(view, "#{breadcrumb} a[href='/components']", "Components")
    assert has_element?(view, "#{breadcrumb} span", "Action")
  end

  test "component sections and subsections feed the on-this-page outline", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/button")

    assert has_element?(view, "#on-this-page", "On this page")
    assert has_element?(view, "#api h2[data-toc='section']", "API")
    assert has_element?(view, "#api #attributes h3[data-toc='subsection']", "Attributes")

    {:ok, base, _html} = live(conn, ~p"/components/button?tab=base")

    assert has_element?(base, "#accessibility h2[data-toc='section']", "Accessibility")
  end

  test "the components index has no breadcrumb", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components")

    refute has_element?(view, "nav[aria-label='Breadcrumb']")
  end

  test "unknown component redirects to the components index", %{conn: conn} do
    assert {:error, {:live_redirect, %{to: "/components"}}} = live(conn, ~p"/components/nope")
  end

  test "every component renders its styled, base, and css tabs", %{conn: conn} do
    for name <- FlintUI.components() do
      {:ok, docs, _html} = live(conn, ~p"/components/#{name}")
      assert has_element?(docs, "#component-sections-panel-styled")
      refute has_element?(docs, "#component-sections-panel-styled[hidden]")
      assert has_element?(docs, "#component-sections-panel-base[hidden]")
      assert has_element?(docs, "[data-preview]")
      assert has_element?(docs, "[data-preview] [data-element]")
      assert has_element?(docs, "#api")
      assert has_element?(docs, "#setup")

      {:ok, base, _html} = live(conn, ~p"/components/#{name}?tab=base")
      assert has_element?(base, "#component-sections-panel-base")
      refute has_element?(base, "#component-sections-panel-base[hidden]")
      assert has_element?(base, "#component-sections-panel-styled[hidden]")
      assert has_element?(base, "#accessibility")
      assert has_element?(base, "#api")
      refute has_element?(base, "[data-preview]")

      {:ok, css, _html} = live(conn, ~p"/components/#{name}?tab=css")
      assert has_element?(css, "#component-sections-panel-css")
      refute has_element?(css, "#component-sections-panel-css[hidden]")
      assert has_element?(css, "#theme")
      assert has_element?(css, "#css-variables")
    end
  end
end
