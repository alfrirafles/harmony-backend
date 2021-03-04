defmodule Harmony.ServerController do

  alias Harmony.Region
  alias Harmony.Server
  alias Harmony.ServerView
  alias Harmony.Conversation

  @content_type "text/html"

  def index(conversation) do
    body = Region.list_servers()
                  |> Enum.sort(&Server.order_by_name_asc/2) |> ServerView.index
    %{conversation | status: 200, response_headers: %{"Content-Type" => @content_type, "Content-Length" => byte_size(body)}, response_body: body}
  end

  def show(conversation, %{"id" => id}) do
    body = Region.get_server(id) |> ServerView.show
    %{conversation | status: 200, response_headers: %{"Content-Type" => @content_type, "Content-Length" => byte_size(body)}, response_body: body}
  end

  def create(conversation, %{"name" => name, "description" => description}) do
    body = "Created a new server called #{name}\nDescription: #{description}"
    %{
      conversation |
      status: 201,
      response_headers: %{"Content-Type" => @content_type, "Content-Length" => byte_size(body)},
      response_body: body
    }
  end

  def delete(conversation, server_id) do
    server = Region.get_server(server_id)
    body = "Insufficient user privileges to delete the server: #{server.name}."
    %{
      conversation |
      status: 403,
      response_headers: %{"Content-Type" => @content_type, "Content-Length" => byte_size(body)},
      response_body: body
    }
  end

  # deprecated function; reason: optimization
  #  defp render_page(conversation, template_name, bindings \\ []) do
  #    content = @templates_path
  #              |> Path.join(template_name)
  #              |> EEx.eval_file(bindings)
  #    %{conversation | status: 200, response_body: content}
  # end
end