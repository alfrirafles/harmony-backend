defmodule Harmony.Parser do

  alias Harmony.Conversation

  @moduledoc """
  Parser module for http request
  """

  @doc """
  Parses the request into a map that can be used for routing.
  """
  def parse(request) do
    [request_method | request_headers] = request
                                         |> String.split("\r\n", trim: true)
    [method, path, _http_version] =
      request_method
      |> String.split(" ", trim: true)
    headers = request_headers
              |> parse_headers(method)
    conversation = %Conversation{
      method: method,
      path: path,
      request_headers: headers,
      response_body: "",
      status: nil
    }
    if method == "POST" do
      params = request_headers
               |> Enum.take(-1)
               |> List.first
               |> parse_params(headers["Content-Type"])
      %{conversation | request_params: params}
    else
      conversation
    end
  end

  def parse_headers(header_list, "GET") do
    Enum.reduce(header_list, %{}, fn header, acc ->
        [key, value] = String.split(header, ": ")
        Map.put(acc, key, value)
      end)
  end

  def parse_headers(header_list, "POST") do
    header_list
    |> Enum.take(length(header_list) - 1)
    |> parse_headers("GET")
  end

  def parse_headers(header_list, "DELETE") do
    parse_headers(header_list, "GET")
  end

  def parse_params(request_body, "application/x-www-form-urlencoded") when request_body != "" do
    request_body
    |> String.slice(0, String.length(request_body) - 1)
    |> URI.decode_query
  end

  def parse_params(request_body, "application/json") when request_body != "" do
    request_body
    |> Poison.Parser.parse!(%{})
  end

  def parse_params(_request_body, nil), do: %{}
end