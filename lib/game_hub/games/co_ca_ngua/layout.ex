defmodule GameHub.Games.CoCaNgua.Layout do
  @moduledoc """
  Maps game positions to (row, col) coordinates on a 15x15 CSS grid, classic
  cross-shaped Cờ cá ngựa / Ludo board. Coordinates are 1-indexed, ready to use
  directly as `grid-row-start` / `grid-column-start`.
  """

  alias GameHub.Games.CoCaNgua.Board

  @grid_size 15
  @track_length Board.track_length()
  @finish_position Board.finish_position()

  # The full outer loop, 0-indexed {row, col}, in path order. Index 0 is red's
  # start square: the cell directly below the corner of red's yard, i.e. the
  # very first cell exiting the yard (not one cell further in).
  #
  # Every drawn cell is in here, including the four corner cells where two arms
  # meet ({6,6} {6,8} {8,8} {8,6}) — a horse steps on them like any other, so
  # the count a player sees on the board never skips a square.
  @main_track [
    {6, 0},
    {6, 1},
    {6, 2},
    {6, 3},
    {6, 4},
    {6, 5},
    {6, 6},
    {5, 6},
    {4, 6},
    {3, 6},
    {2, 6},
    {1, 6},
    {0, 6},
    {0, 7},
    {0, 8},
    {1, 8},
    {2, 8},
    {3, 8},
    {4, 8},
    {5, 8},
    {6, 8},
    {6, 9},
    {6, 10},
    {6, 11},
    {6, 12},
    {6, 13},
    {6, 14},
    {7, 14},
    {8, 14},
    {8, 13},
    {8, 12},
    {8, 11},
    {8, 10},
    {8, 9},
    {8, 8},
    {9, 8},
    {10, 8},
    {11, 8},
    {12, 8},
    {13, 8},
    {14, 8},
    {14, 7},
    {14, 6},
    {13, 6},
    {12, 6},
    {11, 6},
    {10, 6},
    {9, 6},
    {8, 6},
    {8, 5},
    {8, 4},
    {8, 3},
    {8, 2},
    {8, 1},
    {8, 0},
    {7, 0}
  ]

  @home_stretch %{
    red: [{7, 1}, {7, 2}, {7, 3}, {7, 4}, {7, 5}, {7, 6}],
    green: [{1, 7}, {2, 7}, {3, 7}, {4, 7}, {5, 7}, {6, 7}],
    yellow: [{7, 13}, {7, 12}, {7, 11}, {7, 10}, {7, 9}, {7, 8}],
    blue: [{13, 7}, {12, 7}, {11, 7}, {10, 7}, {9, 7}, {8, 7}]
  }

  @yard_slots %{
    red: [{1, 1}, {1, 4}, {4, 1}, {4, 4}],
    green: [{1, 10}, {1, 13}, {4, 10}, {4, 13}],
    yellow: [{10, 10}, {10, 13}, {13, 10}, {13, 13}],
    blue: [{10, 1}, {10, 4}, {13, 1}, {13, 4}]
  }

  @yard_bounds %{
    red: {0, 0},
    green: {0, 9},
    yellow: {9, 9},
    blue: {9, 0}
  }

  # Cell per color where finished horses cluster: the corner of the center hub
  # closest to that color's home stretch.
  @finish_area %{
    red: {6, 6},
    green: {6, 8},
    yellow: {8, 8},
    blue: {8, 6}
  }

  def grid_size, do: @grid_size

  def yard_bounds(color), do: shift(Map.fetch!(@yard_bounds, color))

  @doc "1-indexed {row, col} for background rendering of a main-track cell."
  def main_track_coord(idx) when idx in 0..(@track_length - 1)//1 do
    Enum.at(@main_track, idx) |> shift()
  end

  @doc "1-indexed {row, col} for background rendering of a color's home-stretch cell (0..5)."
  def home_stretch_bg_coord(color, idx) when idx in 0..5 do
    Map.fetch!(@home_stretch, color) |> Enum.at(idx) |> shift()
  end

  def colors, do: [:red, :green, :yellow, :blue]

  @doc "1-indexed {row, col} of the shared cell where a color's finished horses cluster."
  def finish_area_coord(color) do
    Map.fetch!(@finish_area, color) |> shift()
  end

  @doc "Grid coordinate ({row, col}, 1-indexed) for a piece given its color and relative position."
  def cell_coord(color, :home, piece_idx) do
    {row, col} = Map.fetch!(@yard_slots, color) |> Enum.at(piece_idx)
    {row + 1, col + 1}
  end

  def cell_coord(color, pos, _piece_idx) when is_integer(pos) and pos <= @track_length - 1 do
    abs_cell = Board.absolute_cell(color, pos)
    {row, col} = Enum.at(@main_track, abs_cell)
    {row + 1, col + 1}
  end

  def cell_coord(color, pos, _piece_idx) when is_integer(pos) and pos < @finish_position do
    stretch_idx = pos - @track_length
    {row, col} = Map.fetch!(@home_stretch, color) |> Enum.at(stretch_idx)
    {row + 1, col + 1}
  end

  def cell_coord(color, _finish_pos, _piece_idx), do: finish_area_coord(color)

  defp shift({row, col}), do: {row + 1, col + 1}
end
