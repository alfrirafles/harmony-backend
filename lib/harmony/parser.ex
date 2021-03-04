defmodule Harmony.Parser do

  alias Harmony.Conversation

  @moduledoc """
  Parser module for http request
  """

  @doc """
  Parses the request into a map that can be used for routing.
  """
  def parse(request) do
    [request_raw | request_body] = request
                                   |> String.split("\n\n", trim: true)
    [request_method | request_headers] = request_raw
                                         |> String.split("\n", trim: true)
    [method, path, _http_version] =
      request_method
      |> String.split(" ", trim: true)
    headers = request_headers
              |> parse_headers
    %Conversation{
      method: method,
      path: path,
      request_headers: headers,
      request_params: List.to_string(request_body)
                      |> parse_params(headers["Content-Type"]),
      response_body: "",
      status: nil
    }
  end

  defp parse_headers(header_list) do
    Enum.reduce(header_list, %{}, fn header, acc ->
        [key, value] = String.split(header, ": ")
        Map.put(acc, key, value)
      end
    )
  end

  defp parse_params(request_body, "application/x-www-form-urlencoded") when request_body != "" do
    request_body
    |> String.slice(0, String.length(request_body) - 1)
    |> URI.decode_query
  end

  defp parse_params(request_body, "application/json") when request_body != "" do
    request_body
    |> Poison.Parser.parse!(%{})
  end

  defp parse_params("", nil), do: %{}
end