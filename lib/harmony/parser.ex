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
    %Conversation{
      method: method,
      path: path,
      request_headers: request_headers
                       |> parse_headers(%{}),
      request_params: List.to_string(request_body)
                      |> parse_params,
      response_body: "",
      status: nil
    }
  end

  defp parse_headers([line | headers_remain], header_params) do
    [key, value] = line
                   |> String.split(": ")
    updated_header_params = Enum.into(header_params, %{key => value})
    parse_headers(headers_remain, updated_header_params)
  end

  defp parse_headers([], header_params), do: header_params

  defp parse_params(request_body) when request_body != "" do
    request_params = request_body
                     |> String.slice(0, String.length(request_body) - 1)
                     |> URI.decode_query
  end

  defp parse_params(""), do: %{}
end