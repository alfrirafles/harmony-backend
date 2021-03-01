defmodule Harmony.Conversation do

  @moduledoc """
  Module that provides type safety for request -> response conversation in the server.
  """

  alias Harmony.Conversation

  defstruct [method: "", path: "", status: nil, response_body: ""]

  @doc """
  Return the string required by the response for a request that explains about the status.
  """
  def full_status(conversation) do
    "#{conversation.status} #{status_reason(conversation.status)}"
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