defmodule Harmony.Conversation do

  @moduledoc """
  Module that provides type safety for request -> response conversation in the server.
  """

  defstruct [
    method: "",
    path: "",
    status: nil,
    request_headers: %{},
    request_params: %{},
    response_headers: %{
      "Content-Type" => "",
      "Content-Length" => 0
    },
    response_body: ""
  ]

  @doc """
  Return the string required by the response for a request that explains about the status.
  """
  def full_status(conversation) do
    "#{conversation.status} #{status_reason(conversation.status)}"
  end

  def content_type(conversation) do
    "#{conversation.response_headers["Content-Type"]}"
  end

  def content_length(conversation) do
    "#{conversation.response_headers["Content-Length"]}"
  end

  def format(body, [status: status, content_type: content_type, conversation: conversation]) do
    %{
      conversation |
      status: status,
      response_headers: %{
        "Content-Type" => content_type,
        "Content-Length" => byte_size(body)
      },
      response_body: body
    }
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end