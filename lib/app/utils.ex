defmodule App.Utils do
  def normalize(name) when is_binary(name) do
    name
    |> String.trim()
    |> String.downcase()
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def only_numbers(value) when is_binary(value) do
    String.replace(value, ~r/\D/, "")
  end
end
