defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """
  # String -> 
    # compute MD5 hash of string ->
      # List of numbers from string ->
        # Pick color ->
          # Build grid of squares ->
            # convert grid into image ->
              # save image

  def main(input) do
    input
    |> hash_input
    |> set_rgb
    |> build_grid
    |> filter_out_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
  Hashes the `input` value to md5, 
  converts to binary list of hexidecimal values, 
  and assigns to value of hex struct
  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
  Pull first 3 values out and store in struct `color: {r,g,b}`
  """
  def set_rgb(image) do
    %Identicon.Image{hex: [r,g,b | _rest_of_list] } = image
    
    %Identicon.Image{image | color: {r,g,b}}
  end

  @doc """
  Build grid from hex value
  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid = 
      hex
      # chunk the list by 3's
      |> Enum.chunk(3)
      # map over all the chunked lists with mirror_row helper method
      |> Enum.map(&mirror_row/1)
      # flatten all the lists
      |> List.flatten
      # give each element an index
      |> Enum.with_index
    # store newly created grid data in struct `grid`
    %Identicon.Image{image | grid: grid}
  end

  @doc """
  Takes in a single row (list) and mirrors it on the third element
  """
  def mirror_row(row) do
    [first, second | _rest_of_list] = row
    row ++ [second, first]
  end

  @doc """
  
  """
  def filter_out_odd_squares(%Identicon.Image{grid: grid} = image) do
    # filter `grid` elements with funtcion
    grid = Enum.filter grid, fn({code, _index}) -> 
      # check if `rem`(remainder) of code, divided by 2 is equal to 0
      rem(code, 2) == 0
    end

    # store even grid values in struct
    %Identicon.Image{image | grid: grid}
  end

  @doc """
  
  """
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      # horizontal coordinate
      h = rem(index, 5) * 50
      # vertical coordinate
      v = div(index, 5) * 50
      # top left coordinate
      top_left = {h, v}
      # bottom right coordinate
      bottom_right = {h + 50, v + 50}
      # complete square coordinate
      {top_left, bottom_right}
    end

    # store pixel map values in struct
    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
  Doc for EGD library -- http://www1.erlang.org/doc/man/egd.html
  """
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250,250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.jpg", image)
  end

end
