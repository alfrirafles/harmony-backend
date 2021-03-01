defmodule Harmony.Parser do

  alias Harmony.Conversation

  @moduledoc """
  Parser module for http request
  """

  @doc """
  Parses the request into a map that can be used for routing.
  """
  def parse(request) do
    [method, path, _http_version] =
      request
      |> String.split("\n", trim: true)
      |> Enum.at(0) # alternatively List.first(list)
      |> String.split(" ")
    %Conversation{method: method, path: path, response_body: "", status: nil}
  end
end