defmodule Harmony.Handler do

  @moduledoc """
  Handler for HTTP requests.
  """

  alias Harmony.Conversation
  alias Harmony.ServerController

  import Harmony.Plugins, only: [track: 1, rewrite_path: 1, log: 1]
  import Harmony.Parser, only: [parse: 1]
  import Harmony.FileHandler, only: [handle_file: 2]

  @pages_path Path.expand("web/pages", File.cwd!)

  @doc """
  Transforms HTTP request into response
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  @doc """
  Handles routing for specific path in the request. Routes available:\n
  /servers/new - return the register.html file content\n
  /info/<page_name> - return <page_name>.html file content\n
  /servers - returns the list of available servers.\n
  /servers/id - returns specific server welcome page message.\n

  In any case the request contain path to unavailable page, returns 404.
  """
  def route(%Conversation{method: "GET", path: "/servers", response_body: ""} = conversation) do
    ServerController.index(conversation)
  end

  def route(%Conversation{method: "GET", path: "/servers/new", response_body: ""} = conversation) do
    @pages_path
    |> Path.join("register.html")
    |> File.read
    |> handle_file(conversation)
  end

  def route(%Conversation{method: "GET", path: "/servers/" <> id, response_body: ""} = conversation) do
    params = Map.put(conversation.request_params, "id", id)
    ServerController.show(conversation, params)
  end

  def route(%Conversation{method: "POST", path: "/servers", request_params: params} = conversation) do
    ServerController.create(conversation, params)
  end

  def route(%Conversation{method: "DELETE", path: "/servers/" <> id, response_body: ""} = conversation) do
    ServerController.delete(conversation, id)
  end

  def route(%Conversation{method: "GET", path: "/info/" <> page, response_body: ""} = conversation) do
    @pages_path
    |> Path.join(page <> ".html")
    |> File.read
    |> handle_file(conversation)
  end

  def route(%Conversation{path: path} = conversation) do
    %{conversation | status: 404, response_body: "Page not found."}
  end

  @doc """
  Format the response according to the parsed map.
  """
  def format_response(%Conversation{} = conversation) do
    """
    HTTP/1.1 #{Conversation.full_status(conversation)}
    Content-Type: text/html
    Content-Length: #{byte_size(conversation.response_body)}

    #{conversation.response_body}
    """
  end

  defp emojify(%Conversation{status: 200, response_body: body} = conversation) do
    %{conversation | response_body: "👍" <> body <> "👍"}
  end

  defp emojify(%Conversation{} = conversation), do: conversation
end

