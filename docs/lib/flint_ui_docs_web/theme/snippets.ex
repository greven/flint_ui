defmodule FlintUIDocsWeb.Theme.Snippets do
  @moduledoc false

  def snippet(:how) do
    """
    :root {
      color-scheme: light dark;

      /* A palette hue owns its scale and tone set. */
      --fl-color-pink-600: oklch(59.2% 0.249 0.584);
      --fl-color-pink: var(--fl-color-pink-600);
      --fl-color-pink-on: oklch(100% 0 0);

      /* A semantic role aliases a hue. */
      --fl-color-primary: var(--fl-color-pink);
      --fl-color-primary-on: var(--fl-color-pink-on);
      --fl-color-primary-on-soft: light-dark(
        var(--fl-color-pink-800),
        var(--fl-color-pink-300)
      );
    }
    """
  end

  def snippet(:surfaces) do
    """
    :root {
      --fl-surface-ink: light-dark(
        var(--fl-color-gray-950),
        var(--fl-color-gray-50)
      );

      --fl-color-surface: light-dark(white, var(--fl-color-gray-900));
      --fl-color-background: light-dark(
        var(--fl-color-gray-50),
        var(--fl-color-gray-950)
      );

      --fl-color-surface-subtle: color-mix(
        in oklab,
        var(--fl-surface-ink) 3%,
        var(--fl-color-surface)
      );
      --fl-color-surface-strong: color-mix(
        in oklab,
        var(--fl-surface-ink) 5.5%,
        var(--fl-color-surface)
      );
      --fl-color-surface-raised: light-dark(
        white,
        color-mix(in oklab, var(--fl-surface-ink) 5%, var(--fl-color-surface))
      );

      --fl-disabled-opacity: 0.5;
      --fl-tint-opacity: 0.9;
    }
    """
  end

  def snippet(:borders) do
    """
    :root {
      --fl-color-border-subtle: color-mix(
        in oklab,
        var(--fl-surface-ink) 7%,
        var(--fl-color-surface)
      );
      --fl-color-border: color-mix(
        in oklab,
        var(--fl-surface-ink) 10%,
        var(--fl-color-surface)
      );
      --fl-color-border-strong: color-mix(
        in oklab,
        var(--fl-surface-ink) 18%,
        var(--fl-color-surface)
      );
    }
    """
  end

  def snippet(:text) do
    """
    :root {
      --fl-color-text-highlighted: light-dark(
        var(--fl-color-gray-900),
        white
      );
      --fl-color-text: light-dark(
        var(--fl-color-gray-700),
        var(--fl-color-gray-200)
      );
      --fl-color-text-toned: light-dark(
        var(--fl-color-gray-600),
        var(--fl-color-gray-300)
      );
      --fl-color-text-muted: light-dark(
        color-mix(
          in oklab,
          var(--fl-color-gray-500) 90%,
          var(--fl-color-gray-600)
        ),
        var(--fl-color-gray-400)
      );
      --fl-color-text-dimmed: light-dark(
        var(--fl-color-gray-400),
        var(--fl-color-gray-500)
      );
    }
    """
  end

  def snippet(:colors) do
    """
    /* A role aliases one palette hue's five-token tone set. Primary is the
     * brand slot; unbranded, it follows the neutral ink. */
    --fl-color-primary: var(--fl-color-neutral);
    --fl-color-primary-on: var(--fl-color-neutral-on);
    --fl-color-primary-on-soft: var(--fl-color-neutral-on-soft);
    --fl-color-primary-soft: var(--fl-color-neutral-soft);
    --fl-color-primary-soft-border: var(--fl-color-neutral-soft-border);

    /* Neutral is the page's opposite: dark in light, light in dark. */
    --fl-color-neutral: light-dark(
      var(--fl-color-gray-900),
      var(--fl-color-gray-200)
    );
    --fl-color-neutral-on: light-dark(
      var(--fl-color-gray-50),
      var(--fl-color-gray-950)
    );
    --fl-color-neutral-on-soft: light-dark(
      var(--fl-color-gray-900),
      var(--fl-color-gray-200)
    );

    /* The other roles point at palette hues. */
    --fl-color-secondary: var(--fl-color-gray);
    --fl-color-info: var(--fl-color-blue);
    --fl-color-success: var(--fl-color-green);
    --fl-color-warning: var(--fl-color-amber);
    --fl-color-error: var(--fl-color-red);

    /* A hue owns the fill, label, on-soft text, and tint pair. */
    --fl-color-pink: var(--fl-color-pink-600);
    --fl-color-pink-on: oklch(100% 0 0);
    --fl-color-pink-on-soft: light-dark(
      var(--fl-color-pink-800),
      var(--fl-color-pink-300)
    );
    --fl-color-pink-soft: light-dark(
      color-mix(in oklab, var(--fl-color-pink) 12%, var(--fl-color-surface)),
      color-mix(in oklab, var(--fl-color-pink) 18%, var(--fl-color-surface))
    );
    """
  end

  def snippet(:tone_hooks) do
    """
    /* `data-color` sets the base tone; `data-active-color` sets the toggled
     * tone. Components read `--fl-tone*` and `--fl-active-tone*`. */
    :where([data-color="primary"]) {
      --fl-tone: var(--fl-color-primary);
      --fl-tone-on: var(--fl-color-primary-on);
      --fl-tone-on-soft: var(--fl-color-primary-on-soft);
      --fl-tone-soft: var(--fl-color-primary-soft);
      --fl-tone-soft-border: var(--fl-color-primary-soft-border);
    }

    :where([data-color="rose"]) {
      --fl-tone: var(--fl-color-rose);
      --fl-tone-on: var(--fl-color-rose-on);
      --fl-tone-on-soft: var(--fl-color-rose-on-soft);
      --fl-tone-soft: var(--fl-color-rose-soft);
      --fl-tone-soft-border: var(--fl-color-rose-soft-border);
    }
    """
  end

  def snippet(:palettes) do
    """
    <!-- Pick a palette; clear the attribute for the default. -->
    <html data-palette="natural">

    <!-- Palettes, themes, and schemes compose. -->
    <html data-theme="modern" data-palette="bright" data-color-scheme="dark">
    """
  end

  def snippet(:absolute) do
    """
    /* Absolute tones do not follow the color scheme. They alias the neutral
     * extremes, so retinting the neutral ramp retints them too. A theme can
     * override the fill and label pair directly. */
    --fl-color-dark: var(--fl-color-gray-900);
    --fl-color-dark-on: var(--fl-color-gray-50);
    --fl-color-dark-on-soft: light-dark(
      var(--fl-color-gray-900),
      var(--fl-color-gray-200)
    );
    --fl-color-dark-soft: var(--fl-color-gray-soft);
    --fl-color-dark-soft-border: var(--fl-color-gray-soft-border);

    --fl-color-light: var(--fl-color-gray-50);
    --fl-color-light-on: var(--fl-color-gray-900);
    --fl-color-light-on-soft: light-dark(
      var(--fl-color-gray-700),
      var(--fl-color-gray-50)
    );
    --fl-color-light-soft: var(--fl-color-gray-soft);
    --fl-color-light-soft-border: var(--fl-color-gray-soft-border);
    """
  end

  def snippet(:brand_css) do
    """
    /* assets/css/app.css */
    @import "./flint.css";

    :root {
      --fl-color-primary: var(--fl-color-purple);
      --fl-color-primary-on: var(--fl-color-purple-on);
      --fl-color-primary-on-soft: var(--fl-color-purple-on-soft);
      --fl-color-primary-soft: var(--fl-color-purple-soft);
      --fl-color-primary-soft-border: var(--fl-color-purple-soft-border);
    }
    """
  end

  def snippet(:token_override) do
    """
    /* assets/css/app.css, after the flint.css import. */
    :root {
      --fl-radius: 0.375rem;
      --fl-duration-base: 240ms;
      --fl-color-primary: var(--fl-color-violet);
      --fl-color-primary-on: var(--fl-color-violet-on);
      --fl-color-primary-on-soft: var(--fl-color-violet-on-soft);
      --fl-color-primary-soft: var(--fl-color-violet-soft);
      --fl-color-primary-soft-border: var(--fl-color-violet-soft-border);
    }
    """
  end

  def snippet(:palette_colors) do
    """
    <.button color="rose">Rose</.button>
    <.button color="emerald">Emerald</.button>
    <.button variant="solid" color="sky">Sky</.button>
    """
  end

  def snippet(:custom_hues_config) do
    """
    # config/config.exs
    config :flint_ui, extra_hues: [:brand]
    """
  end

  def snippet(:custom_hues) do
    """
    mix flint.palette brand --from "#8b5cf6" --write assets/css/flint-brand.css
    """
  end

  def snippet(:custom_hues_use) do
    """
    <.button color="brand">Brand</.button>
    """
  end

  def snippet(:focus) do
    """
    /* Pick a geometry once for the whole document, or any subtree. */
    <html data-focus="ring">      /* default: edge ring */
    <html data-focus="outline">   /* 2px gap */
    <html data-focus="inset">     /* inside the edge */

    :root {
      --fl-focus-ring-color: var(--fl-color-primary);
      --fl-focus-ring-alpha: 50%;
      --fl-focus-border-color: var(--fl-focus-ring-color);
      --fl-focus-color-error: var(--fl-color-error);
    }
    """
  end

  def snippet(:depth) do
    """
    /* Depth and press are shared control tokens. A preset can flatten every
     * control for the whole site: */
    [data-theme="flat"] {
      --fl-control-depth: 0; /* no highlight or inner line */
      --fl-control-press: none; /* no press movement */
    }

    /* Hover/active are an in-border currentColor overlay. Retune per theme: */
    [data-theme="quiet"] {
      --fl-control-hover-opacity: 0.02;
      --fl-control-active-opacity: 0.05;
    }

    /* Shadows are independent of depth. Remove them per theme or instance: */
    .my-shadowless-button {
      --fl-control-shadow: 0 0 #0000;
    }
    """
  end

  def snippet(:shadows) do
    """
    :root {
      --fl-shadow-base: 0 1px 2px 0 light-dark(#0000000d, #0000004d);
      --fl-shadow-sm: 0 1px 3px 0 rgb(0 0 0 / 10%),
        0 1px 2px -1px rgb(0 0 0 / 10%);
      --fl-shadow-md: 0 4px 6px -1px rgb(0 0 0 / 10%),
        0 2px 4px -2px rgb(0 0 0 / 10%);

      /* Shared control depth. */
      --fl-control-depth: 1;
      --fl-control-shadow: var(--fl-shadow-base);
      --fl-control-press: translateY(1px);
    }
    """
  end

  def snippet(:neutral_palette) do
    """
    /* app.css, after the flint.css import. A cool neutral. */
    :root {
      --fl-color-gray-50: var(--color-slate-50);
      /* … 100 through 900 … */
      --fl-color-gray-950: var(--color-slate-950);
    }
    """
  end

  def snippet(:palette_css) do
    """
    /* app.css, after the flint.css import. Remap rose to a brand scale. */
    :root {
      --fl-color-rose-50: var(--color-brand-50);
      /* … 100 through 900 … */
      --fl-color-rose-950: var(--color-brand-950);
    }

    /* The derived tokens follow the ramp automatically: */
    /* --fl-color-rose: var(--fl-color-rose-600);
     * --fl-color-rose-on, -on-soft, -soft, -soft-border … */
    """
  end

  def snippet(:radius) do
    """
    :root {
      --fl-radius: 0.25rem; /* base unit */
      --fl-control-radius: var(--fl-radius-md);
    }

    /* All controls square */
    :root {
      --fl-control-radius: 0;
    }

    /* All controls pill */
    :root {
      --fl-control-radius: var(--fl-radius-full);
    }

    /* A component-specific exception stays in the theme */
    [data-theme="sharp"] [data-element="badge"] {
      border-radius: var(--fl-radius-sm);
    }
    """
  end

  def snippet(:typography) do
    """
    :root {
      --fl-font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI",
        Roboto, sans-serif;
      --fl-font-mono: ui-monospace, SFMono-Regular, Menlo, Monaco,
        Consolas, monospace;

      --fl-font-size-sm: 0.875rem;
      --fl-font-size-md: 1rem;
      --fl-font-size-lg: 1.125rem;

      --fl-line-height-sm: 1.25rem;
      --fl-line-height-md: 1.5rem;
      --fl-line-height-lg: 1.75rem;

      --fl-font-weight-medium: 500;
      --fl-font-weight-semibold: 600;
      --fl-font-tracking-tight: -0.025em;
    }
    """
  end

  def snippet(:spacing) do
    """
    :root {
      --fl-spacing: 0.25rem; /* base unit */
      --fl-spacing-sm: calc(var(--fl-spacing) * 2);
      --fl-spacing-md: calc(var(--fl-spacing) * 3);
      --fl-spacing-lg: calc(var(--fl-spacing) * 4);

      --fl-breakpoint-md: 48rem;
      --fl-container-md: 28rem;
    }
    """
  end

  def snippet(:transitions) do
    """
    :root {
      --fl-duration-fast: 150ms;
      --fl-duration-base: 200ms;
      --fl-duration-slow: 300ms;

      --fl-ease-out: cubic-bezier(0, 0, 0.2, 1);
      --fl-ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
    }
    """
  end

  def snippet(:scaling) do
    """
    :root {
      --fl-spacing: 0.25rem; /* base unit */
      --fl-radius: 0.25rem; /* base unit */

      --fl-font-size-md: 1rem;
      --fl-font-weight-medium: 500;
      --fl-shadow-md: 0 4px 6px -1px rgb(0 0 0 / 10%);
      --fl-duration-fast: 150ms;

      /* Shared across form controls */
      --fl-control-height-md: 2rem;
      --fl-control-font-size-md: 0.875rem;

      /* Text fields want a little more inline padding than a button. */
      --fl-field-padding-x-md: 0.875rem;
    }
    """
  end

  def snippet(:override_css) do
    """
    /* Give this instance a custom accent without adding a color token. */
    .danger-lite {
      --fl-control-color: var(--fl-color-red-600);
      --fl-control-color-content: var(--fl-color-red-on);
    }
    """
  end

  def snippet(:override_heex) do
    """
    <.button color="secondary" class="danger-lite">Delete</.button>

    <!-- or inline, for a one-off -->
    <.button color="secondary" style="--fl-control-color: var(--fl-color-red-600)">
      Delete
    </.button>
    """
  end

  def snippet(:presets) do
    """
    <!-- Pick a shipped preset -->
    <html data-theme="modern">
    """
  end

  def snippet(:light_dark) do
    """
    <!-- Force a scheme, independent of the preset -->
    <html data-color-scheme="dark">
    """
  end

  def snippet(:custom) do
    """
    /* assets/css/app.css, after the flint.css import */
    [data-theme="brand"] {
      --fl-color-primary: var(--fl-color-purple);
      --fl-color-primary-on: var(--fl-color-purple-on);
      --fl-color-primary-on-soft: var(--fl-color-purple-on-soft);
      --fl-color-primary-soft: var(--fl-color-purple-soft);
      --fl-color-primary-soft-border: var(--fl-color-purple-soft-border);
      --fl-radius: 0.375rem;
    }
    """
  end

  def snippet(:tailwind) do
    """
    @theme inline {
      /* Each utility family gets its own token. */
      --text-color-default: var(--fl-color-text);
      --background-color-surface: var(--fl-color-surface);
      --border-color-default: var(--fl-color-border);
      --text-color-primary: var(--fl-color-primary-on-soft);
      --background-color-primary: var(--fl-color-primary);

      /* Palette shades are available as utilities too. */
      --color-pink-500: var(--fl-color-pink-500);
      --color-gray-900: var(--fl-color-gray-900);
      --radius-md: var(--fl-radius-md);
    }
    """
  end
end
