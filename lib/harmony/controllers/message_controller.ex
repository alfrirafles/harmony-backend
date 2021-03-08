defmodule MessageController do
  alias Harmony.Message
  alias Harmony.Server
  alias Harmony.Region
  alias Harmony.MessageView
  alias Harmony.Conversation

  @content_type "text/html"

  def create(conversation, %{"message" => message, "serverId" => id, "sender" => sender}) do
    Message.append(id, message, sender)
    Server.get_messages(id)
    |> Enum.sort(&Message.order_by_date_created/2)
    |> MessageView.create(Region.get_server(String.to_integer(id)))
    |> Conversation.format(status: 201, content_type: @content_type, conversation: conversation)
  end
end
