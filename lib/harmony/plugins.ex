defmodule Harmony.Plugins do

  alias Harmony.Conversation

  @moduledoc """
  Module for plugins feature for the server request's handler.
  """

  require Logger

  @doc """
  Tracks HTTP requests that returns 404 for debugging purposes.\n
  Other requests with other status than 404, will have no warning.
  """
  def track(%{status: 404, path: path} = conversation) do
    Logger.warn "Warning: User trying to access #{path}, where page not exists for such path."
    conversation
  end

  def track(%Conversation{} = conversation), do: conversation

  @doc """
  Rewrite the path of the requests to the available route in the server.\n
  /home -> /servers\n
  /slug?id= -> /slug/id

  """
  def rewrite_path(%{path: "/home"} = conversation) do
    %{conversation | path: "/servers"}
  end

  def rewrite_path(%{path: path} = conv) do
    regex = ~r{\/(?<slug>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path(%Conversation{} = conversation), do: conversation

  defp rewrite_path_captures(conversation, %{"slug" => slug, "id" => id}) do
    %{conversation | path: "/#{slug}/#{id}"}
  end

  defp rewrite_path_captures(conversation, nil), do: conversation

  @doc """
  Logs the parsed request for debugging purposes.
  """
  def log(%Conversation{} = conversation), do: IO.inspect conversation
end