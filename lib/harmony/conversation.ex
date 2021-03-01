defmodule Harmony.Conversation do

  alias Harmony.Conversation

  defstruct [method: "", path: "", status: nil, response_body: ""]

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