defmodule App.Utils do
  def normalize(name) when is_binary(name) do
    name
    |> String.trim()
    |> String.downcase()
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
