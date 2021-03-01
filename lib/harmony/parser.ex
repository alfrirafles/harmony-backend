defmodule Harmony.Parser do

  alias Harmony.Conversation

  @moduledoc """
  Parser module for http request
  """

  @doc """
  Parses the request into a map that can be used for routing.
  """
  def parse(request) do
    [request_header | request_body] = request
                                      |> String.split("\n\n", trim: true)
    [method, path, _http_version] =
      request_header
      |> String.split("\n", trim: true)
      |> Enum.at(0) # alternatively List.first(list)
      |> String.split(" ")
    %Conversation{
      method: method,
      path: path,
      request_params: List.to_string(request_body)
                      |> parse_params,
      response_body: "",
      status: nil
    }
  end

  defp parse_params(request_body) when request_body != "" do
    request_params = request_body
                     |> String.slice(0, String.length(request_body) - 1)
                     |> URI.decode_query
  end

  defp parse_params(""), do: %{}
end