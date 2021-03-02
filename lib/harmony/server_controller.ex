defmodule Harmony.ServerController do

  alias Harmony.Region
  alias Harmony.Server

  @templates_path Path.expand("web/templates/servers", File.cwd!)

  def index(conversation) do
    server_list = Region.list_servers
                   |> Enum.sort(&Server.order_by_name_asc/2)

    content =
      @templates_path
      |> Path.join("index.eex")
      |> EEx.eval_file(servers: server_list)

    %{conversation | status: 200, response_body: content}
  end

  def show(conversation, %{"id" => id} = params) do
    server = Region.get_server(id)
    %{conversation | status: 200, response_body: "<h1>#{server.name}</h1><br>#{server.description}"}
  end

  def create(conversation, %{"name" => name, "description" => description} = server) do
    %{
      conversation |
      status: 201,
      response_body: "Created a new server called #{name}\nDescription: #{description}"
    }
  end

  def delete(conversation, server_id) do
    %{conversation | status: 403, response_body: "Insufficient user privileges to delete the server."}
  end

  defp server_list_html(server) do
    "  <li>#{server.name} - #{server.description}</li>\n"
  end
end