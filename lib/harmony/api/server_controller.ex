defmodule Harmony.Api.ServerController do

  alias Harmony.Region
  alias Harmony.Conversation

  @content_type "application/json"

  def index(conversation) do
    body = Region.list_servers
           |> Poison.encode!
           |> Conversation.format(status: 200, content_type: @content_type, conversation: conversation)
  end

  def create(conversation) do
    body = "Server LearnDevOps/Server to learn DevOps created!"
           |> Conversation.format(status: 201, content_type: "text/html", conversation: conversation)
  end
end