defmodule FlintUI.Sound do
  @moduledoc """
  Cue catalog and metadata for FlintUI's opt-in interface sounds.

  The audio itself is synthesized in the browser by `FlintUI.Sound`'s
  JavaScript hook — there are no audio assets. This module only describes the
  cues for documentation, pickers, and per-component defaults.

  Cue specs are adapted from [Foley](https://github.com/eakbulut/foley), MIT
  License, Copyright (c) 2026 eakbulut and Foley contributors. See
  `NOTICE.md`.

  ## Families

  Cues are grouped by the job they do, not by their timbre:

    * `:pointer` — grains and breaths for hover and focus
    * `:press` — weight for down-strokes and keys
    * `:toggle` — paired figures for binary state
    * `:feedback` — verdicts: lifted, flat, or blocked
    * `:notify` — bells and pings for the unasked-for
    * `:motion` — air and travel for transitions
    * `:state` — loading, ready, and the arrival
  """

  @families [
    %{
      id: :pointer,
      name: "Pointer",
      description: "Grains and breaths for hover and focus."
    },
    %{id: :press, name: "Press", description: "Weight for down-strokes and keys."},
    %{id: :toggle, name: "Toggle", description: "Paired figures for binary state."},
    %{id: :feedback, name: "Feedback", description: "Verdicts: lifted, flat, or blocked."},
    %{id: :notify, name: "Notify", description: "Bells and pings for the unasked-for."},
    %{id: :motion, name: "Motion", description: "Air and travel for transitions."},
    %{id: :state, name: "State", description: "Loading, ready, and the arrival."}
  ]

  @cues [
    %{name: "tick", family: :pointer, description: "A dry grain as the pointer crosses."},
    %{name: "hover", family: :pointer, description: "A barely-there breath of pitch."},
    %{name: "glide", family: :pointer, description: "A longer sweep for large targets."},
    %{name: "pop", family: :pointer, description: "A bubble bursting under the cursor."},
    %{name: "press", family: :press, description: "Weight on the down-stroke."},
    %{name: "release", family: :press, description: "A lighter spring on the way up."},
    %{name: "tap", family: :press, description: "A neutral, single click."},
    %{name: "thock", family: :press, description: "A lubed mechanical key."},
    %{name: "on", family: :toggle, description: "Two notes stepping upward."},
    %{name: "off", family: :toggle, description: "The same two notes, descending."},
    %{name: "switch", family: :toggle, description: "A hard snap between modes."},
    %{name: "latch", family: :toggle, description: "A low clunk that stays put."},
    %{name: "success", family: :feedback, description: "A small major lift."},
    %{name: "error", family: :feedback, description: "Two flat buzzes, no drama."},
    %{name: "warning", family: :feedback, description: "One note, stated twice."},
    %{name: "denied", family: :feedback, description: "A thud against a limit."},
    %{name: "chime", family: :notify, description: "A struck bar with its partials."},
    %{name: "ping", family: :notify, description: "One bright point of light."},
    %{name: "bell", family: :notify, description: "Rounder, and further away."},
    %{name: "bubble", family: :notify, description: "A message surfacing."},
    %{name: "swoosh", family: :motion, description: "Air moving forward."},
    %{name: "whoosh", family: :motion, description: "The same air, leaving."},
    %{name: "drop", family: :motion, description: "Something set down."},
    %{name: "rise", family: :motion, description: "Something lifting off."},
    %{name: "loading", family: :state, description: "Three patient ticks."},
    %{name: "ready", family: :state, description: "A warm open third."},
    %{name: "complete", family: :state, description: "An arpeggio, then a shimmer."},
    %{name: "sparkle", family: :state, description: "A handful of glitter."}
  ]

  @doc "All cue families, in documentation order."
  def families, do: @families

  @doc "All cues as maps with `:name`, `:family`, and `:description`."
  def cues, do: @cues

  @doc "The cue names in documentation order."
  def names, do: Enum.map(@cues, & &1.name)

  @doc "Fetches a cue by name."
  def get(name) when is_binary(name), do: Enum.find(@cues, &(&1.name == name))

  @doc "Cues grouped by family, in documentation order."
  def by_family do
    Enum.map(@families, fn family ->
      cues = Enum.filter(@cues, &(&1.family == family.id))
      Map.put(family, :cues, cues)
    end)
  end

  @doc """
  The default cue for an interaction, or `nil` when there is none.

      iex> FlintUI.Sound.default_for(:click)
      "tap"
      iex> FlintUI.Sound.default_for(:toggle_on)
      "on"
      iex> FlintUI.Sound.default_for(:unknown)
      nil
  """
  def default_for(kind) do
    case kind do
      :click -> "tap"
      :press -> "press"
      :release -> "release"
      :hover -> "tick"
      :type -> "thock"
      :enter -> "bubble"
      :exit -> "whoosh"
      :change -> "switch"
      :open -> "rise"
      :close -> "drop"
      :toggle_on -> "on"
      :toggle_off -> "off"
      :success -> "success"
      :error -> "error"
      :warning -> "warning"
      :loading -> "loading"
      :complete -> "complete"
      _ -> nil
    end
  end
end
