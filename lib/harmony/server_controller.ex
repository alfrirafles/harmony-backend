defmodule Harmony.ServerController do

  alias Harmony.Region
  alias Harmony.Server
  alias Harmony.ServerView

  def index(conversation) do
    server_list = Region.list_servers()
                  |> Enum.sort(&Server.order_by_name_asc/2)
    %{conversation | status: 200, response_body: ServerView.index(server_list)}
  end

  def show(conversation, %{"id" => id}) do
    server = Region.get_server(id)
    %{conversation | status: 200, response_body: ServerView.show(server)}
  end

  def create(conversation, %{"name" => name, "description" => description}) do
    %{
      conversation |
      status: 201,
      response_body: "Created a new server called #{name}\nDescription: #{description}"
    }
  end

  def delete(conversation, server_id) do
    server = Region.get_server(server_id)
    %{conversation | status: 403, response_body: "Insufficient user privileges to delete the server: #{server.name}."}
  end

  # deprecated function; reason: optimization
  #  defp render_page(conversation, template_name, bindings \\ []) do
  #    content = @templates_path
  #              |> Path.join(template_name)
  #              |> EEx.eval_file(bindings)
  #    %{conversation | status: 200, response_body: content}
  # end
end