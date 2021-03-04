defmodule Harmony.Api.ServerController do

  alias Harmony.Region
  alias Harmony.Conversation

  @content_type "application/json"

  def index(conversation) do
    body = Region.list_servers
           |> Poison.encode!
           |> Conversation.format(status: 200, content_type: @content_type, conversation: conversation)
  end
end