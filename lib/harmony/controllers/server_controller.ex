defmodule Harmony.ServerController do

  alias Harmony.Region
  alias Harmony.Server
  alias Harmony.Message
  alias Harmony.ServerView
  alias Harmony.Conversation

  @content_type "text/html"

  def index(conversation) do
    body = Region.list_servers(source: "file")
           |> Enum.sort(&Server.order_by_name_asc/2)
           |> ServerView.index
           |> Conversation.format(status: 200, content_type: @content_type, conversation: conversation)
  end

  def show(conversation, %{"id" => id}) do
    messages = Server.get_messages(id)
               |> Enum.sort(&Message.order_by_date_created/2)
    body = Region.get_server(id)
           |> ServerView.show(messages)
           |> Conversation.format(status: 200, content_type: @content_type, conversation: conversation)
  end

  def create(conversation, %{"name" => name, "description" => description}) do
    body = "Created a new server called #{name}\nDescription: #{description}"
           |> Conversation.format(status: 201, content_type: @content_type, conversation: conversation)
  end

  def delete(conversation, server_id) do
    body = "Insufficient user privileges to delete the server: #{Region.get_server(server_id).name}."
           |> Conversation.format(status: 403, content_type: @content_type, conversation: conversation)
  end

  def time_out(conversation) do
    %{path: "/down/" <> duration} = conversation
    :timer.sleep(String.to_integer(duration))
    body = "Server timed out for #{duration}"
           |> Conversation.format(status: 200, content_type: @content_type, conversation: conversation)
  end

  # deprecated function; reason: optimization
  #  defp render_page(conversation, template_name, bindings \\ []) do
  #    content = @templates_path
  #              |> Path.join(template_name)
  #              |> EEx.eval_file(bindings)
  #    %{conversation | status: 200, response_body: content}
  # end
end