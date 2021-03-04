defmodule Harmony.ServerController do

  alias Harmony.Region
  alias Harmony.Server
  alias Harmony.ServerView
  alias Harmony.Conversation

  @content_type "text/html"

  def index(conversation) do
    body = Region.list_servers()
           |> Enum.sort(&Server.order_by_name_asc/2)
           |> ServerView.index
           |> Conversation.format(status: 200, content_type: @content_type, conversation: conversation)
  end

  def show(conversation, %{"id" => id}) do
    body = Region.get_server(id)
           |> ServerView.show
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

  # deprecated function; reason: optimization
  #  defp render_page(conversation, template_name, bindings \\ []) do
  #    content = @templates_path
  #              |> Path.join(template_name)
  #              |> EEx.eval_file(bindings)
  #    %{conversation | status: 200, response_body: content}
  # end
end