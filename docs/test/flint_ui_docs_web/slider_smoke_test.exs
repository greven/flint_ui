defmodule FlintUIDocsWeb.SliderSmokeTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "slider page renders the basic example and controls", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/slider")

    assert has_element?(
             view,
             "#usage-slider-basic [data-element='slider'][data-slider][data-size='md'][data-color='primary']"
           )

    assert has_element?(view, "#usage-slider-basic label", "Volume")
    assert has_element?(view, "#usage-slider-basic [data-part='sublabel']", "Optional")

    assert has_element?(
             view,
             "#usage-slider-basic input[type='range'][id='slider-basic-volume-input'][name='volume'][value='40']"
           )

    view
    |> element("#usage-slider-basic-controls")
    |> render_change(%{"size" => "lg", "color" => "danger"})

    assert has_element?(
             view,
             "#usage-slider-basic [data-element='slider'][data-size='lg'][data-color='danger']"
           )
  end

  test "range example renders two named thumbs and its tooltips", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/slider")

    assert has_element?(view, "#usage-slider-range [data-element='slider'][data-range]")

    assert has_element?(
             view,
             "#usage-slider-range input[type='range'][data-thumb='min'][name='price[]'][value='200'][aria-label='Price range minimum']"
           )

    assert has_element?(
             view,
             "#usage-slider-range input[type='range'][data-thumb='max'][name='price[]'][value='800'][aria-label='Price range maximum']"
           )

    assert has_element?(
             view,
             "#usage-slider-range [data-part='tooltip'][data-thumb='min'][aria-hidden='true']",
             "200"
           )

    assert has_element?(
             view,
             "#usage-slider-range [data-part='tooltip'][data-thumb='max'][aria-hidden='true']",
             "800"
           )
  end

  test "markers, vertical layout, and validation render their states", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/slider")

    assert has_element?(
             view,
             "#usage-slider-tooltip [data-element='slider'][data-show-markers][data-show-tooltip]"
           )

    assert has_element?(
             view,
             "#usage-slider-tooltip [data-part='marker'][style='--_fl-slider-offset: 0.1']"
           )

    assert has_element?(
             view,
             "#usage-slider-orientation [data-element='slider'][data-orientation='vertical']"
           )

    assert has_element?(
             view,
             "#usage-slider-validation [data-element='slider'][data-invalid] input[type='range'][aria-invalid='true']"
           )

    assert has_element?(
             view,
             "#usage-slider-validation [data-part='error']",
             "is above the alarm threshold"
           )
  end

  test "read-only and field examples render their attributes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/components/slider")

    assert has_element?(
             view,
             "#usage-slider-readonly [data-element='slider'][data-readonly] input[type='range'][aria-readonly='true']"
           )

    assert has_element?(
             view,
             "#usage-slider-readonly [data-element='slider'][data-disabled] input[type='range'][disabled]"
           )

    assert has_element?(view, "#slider-field-form input[type='range'][name='settings[volume]']")
  end
end
